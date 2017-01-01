#lang racket

(require "ansi-color-coder.rkt"
         racket/date
         "game-manager.rkt"
         "handle-error.rkt"
         json
         "serializer.rkt"
         srfi/26
         "utilities.rkt")

(provide client)


(define EOT-CHAR (bytes 4))
(struct Socket (send recv) #:mutable)


(define client%
  (class object%
    (super-new)
    (field [ai null]
           [connected #f]
           [event-stack (make-vector 0)]
           [game null]
           [game-manager null]
           [port 0]
           [print-io #f]
           [recvd (make-bytes 1024 0)]
           [recvd-buffer (make-bytes 0 0)]
           [server (string)]
           [socket (Socket #f #f)])

    ;; Connection to game server

    (define/public (connected?)
      (values connected (Socket-send socket) (Socket-recv socket)))


    (define/public (connect remote-server remote-port options)
      (set-field! server this remote-server)
      (set-field! port this (string->number remote-port))
      (set-field! print-io this (hash-ref options 'print-io #f))
      (printf "~a~a~a~a~%" (ansi #:text 'cyan) "Connecting to: " reset
              (string-append server ":" remote-port))
      (with-handlers ([exn:fail? (cut could-not-connect <> remote-port)])
        (let-values ([(recv-t send-t) (tcp-connect/enable-break server port)])
          (file-stream-buffer-mode recv-t 'none)
          (file-stream-buffer-mode send-t 'none)
          (set-Socket-send! socket send-t)
          (set-Socket-recv! socket recv-t)))
      (set-field! connected this #t))


    (define/public (disconnect)
      (with-handlers ([exn:fail? (cut printf "~a~%" "Bad disconnect.")])
        (when connected
          (close-input-port (Socket-recv socket))
          (close-output-port (Socket-send socket))
          (set-field! connected this #f))))

    ;; Prepare for new game

    (define/public (setup new-game ai-instance)
      (set-field! game this new-game)
      (set-field! ai this ai-instance)
      (set-field! game-manager this (new game-manager% [game game])))


    (define/public (set-constants constants)
      (send game-manager set-constants constants))

    ;; Sending data to server

    (define/private (send-raw bstr)
      (when print-io
        (printf "~a~a~a~a~%" (ansi #:text 'magenta)
                "TO SERVER <-- " (bytes->string/locale bstr) reset))
      (with-handlers ([exn:fail? disconnected-unexpectedly])
        (write-bytes bstr (Socket-send socket))))


    (define/public (send-event event data)
      (send-raw (bytes-append
                 (jsexpr->bytes (make-hash `((sentTime . ,(date->string (current-date)))
                                             (event . ,event)
                                             (data . ,(serialize data)))))
                 EOT-CHAR)))

    ;; Communicate ai actions

    (define/public (run-on-server caller function-name args)
      (send-event "run" (make-hash `((caller . ,caller)
                                     (functionName . ,function-name)
                                     (args . ,args))))
      (let ([ran-data (wait-for-event "ran")])
        (deserialize ran-data game)))

    ;; Process incoming events

    (define/public (wait-for-event event)
      (define data null)
      (for ([_ (in-naturals)]
            #:when (and (wait-for-new-events) (> (vector-length event-stack) 0)))
        (match/values (vector-split-at event-stack 1)
                      [((vector sent) rest)
                       (set-field! event-stack this rest)
                       (if (and event (string=? (hash-ref sent 'event) event))
                           (set! data (hash-ref sent 'data))
                           (auto-handle (hash-ref sent 'event)
                                        (hash-ref sent 'data)))])
        #:break (not (null? data)) #t)
      data)


    (define/private (wait-for-new-events)
      (with-handlers ([exn:fail:read? malformed-json]
                      [exn:fail? cannot-read-socket])
        (for ([_ (in-naturals)]
              #:break (> (vector-length event-stack) 0))
          (define num-bytes-recvd
            (read-bytes-avail! recvd (Socket-recv socket)))
          (when (> num-bytes-recvd 0)
            (process-incoming-events num-bytes-recvd)))))


    (define/private (process-incoming-events num-bytes-recvd)
      (define new-bytes (subbytes recvd 0 num-bytes-recvd))
      (define total (bytes-append recvd-buffer new-bytes))
      (define potential-events (regexp-match* #rx"([^\0\4]+)" total))
      (define-values (events partial)
        (if (= (bytes-ref recvd (sub1 num-bytes-recvd)) 4)
            (values potential-events (bytes))
            (values (drop-right potential-events 1) (last potential-events))))
      (set-field! recvd-buffer this partial)
      (when print-io
        (printf "~a~a~a~a~%"
                (ansi #:text 'magenta)
                "FROM SERVER --> " events
                reset))
      (set-field! event-stack this
                  (for/vector #:length (length events) ([event events])
                              (bytes->jsexpr event))))

    ;; Play game

    (define/public (play player-id)
      (with-handlers ([exn:fail? (cut ai-errored <> "AI errored when game initially started")])
        (send ai set-player player-id)
        (send ai start)
        (send ai game-updated))
      (wait-for-event #f))

    ;; Event Handlers

    (define/private (auto-handle event data)
      (with-handlers ([exn:fail? (cut cannot-auto-handle <> event)])
        (define handle (string->symbol (string-append "auto-handle-" event)))
        (dynamic-send this handle data)))


    (define/public (auto-handle-order data)
      (define args (deserialize (hash-ref data 'args) game))
      (with-handlers ([exn:fail? (cut ai-errored <> (string-append "AI errored in order '"
                                                                   (hash-ref data 'name)
                                                                   "'.")) ])
        (define order (string->symbol (camel-to-hyphen (hash-ref data 'name))))
        (define returned (dynamic-send ai order args))
        (send-event "finished" (make-hash `((orderIndex . ,(hash-ref data 'index))
                                            (returned . ,returned))))))


    (define/public (auto-handle-delta delta)
      (define can-play? (null? (get-field player ai)))
      (with-handlers ([exn:fail? (cut delta-merge-failure <> "Error applying delta state.")])
        (send game-manager apply-delta-state delta))
      (when can-play?
        (with-handlers ([exn:fail? (cut <> "AI errored in game-update after delta.")])
          (send ai game-updated))))


    (define/public (auto-handle-invalid data)
      (with-handlers ([exn:fail? (cut ai-errored <> "AI errored in invalid.")])
        (send ai invalid (hash-ref data 'message))))


    (define/public (auto-handle-fatal data)
      (disconnect)
      (handle-error 'FATAL_EVENT
                    (exn "" (current-continuation-marks))
                    (string-append "got fatal event from server: "
                                   (hash-ref data 'message))))


    (define/public (auto-handle-over data)
      (define player (get-field player ai))
      (define won? (get-field won player))
      (define-values (reason message)
        (if won?
            (values (get-field reason-won player) "I won! :D")
            (values (get-field reason-lost player) "I lost. :C")))
      (printf "~a~a ~a ~a ~a~a~%" (ansi #:text 'green)
              "Game is over." message "because" reason reset)
      (with-handlers ([exn:fail? (cut ai-errored <> "AI errored in (ended).")])
        (send ai ended won? reason))
      (when (and (hash? data) (hash-has-key? data 'message))
        (printf "~a~a~a~%" (ansi #:text 'cyan) (hash-ref data 'message) reset))
      (disconnect)
      (exit 0))

    ;; Error Handlers
    
    (define (disconnected-unexpectedly err)
      (disconnect)
      (handle-error 'DISCONNECTED_UNEXPECTEDLY err
                    "Could not send string through server."))


    (define (malformed-json err)
      (disconnect)
      (handle-error 'MALFORMED_JSON err "Error parsing json."))


    (define (cannot-read-socket err)
      (disconnect)
      (handle-error 'CANNOT_READ_SOCKET err "Error reading socket."))


    (define (could-not-connect err remote-port)
      (disconnect)
      (handle-error 'COULD_NOT_CONNECT err
                    (string-append "Could not connect to " server ":"
                                   remote-port ".")))


    (define (cannot-auto-handle err event)
      (disconnect)
      (handle-error 'UNKNOWN_EVENT_FROM_SERVER err
                    (string-append "Cannot auto handle event '" event "'.")))


    (define (ai-errored err str)
      (disconnect)
      (handle-error 'AI_ERRORED err str))

    
    (define (delta-merge-failure err str)
      (handle-error 'DELTA_MERGE_FAILURE err str))))

(define client (new client%))
