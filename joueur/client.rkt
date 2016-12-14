(module client racket
  (require "ansi-color-coder.rkt"
           racket/date
           "game-manager.rkt"
           "handle-error.rkt"
           json
           "serializer.rkt"
           srfi/26)
  (provide client)


  (define EOT_CHAR (bytes 4))

  (struct Socket (send recv) #:mutable)

  ;; Splitting list based on function f

  (define (split-by lst f)
    (foldr (lambda (element next)
             (if (f element)
                 (cons empty next)
                 (cons (cons element (first next)) (rest next))))
           (list empty) lst))

  ;; Splitting list by EOT byte

  (define (split-by-eot total)
    (match (split-by total (lambda (x) (= x 4)))
      [(list a ... b) (values a b)]
      [(list c) (values null c)]))


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
        (with-handlers ([exn:fail? could-not-connect])
          (let-values ([(recv-t send-t) (tcp-connect/enable-break server port)])
            (file-stream-buffer-mode recv-t 'none)
            (file-stream-buffer-mode send-t 'none)
            (set-Socket-send! socket send-t)
            (set-Socket-recv! socket recv-t)))
        (set-field! connected this #t))


      (define/public (disconnect)
        (with-handlers ([exn:fail? (cut printf "~a~%" "Bad disconnect.")])
          (cond [connected (close-input-port (Socket-recv socket))
                           (close-output-port (Socket-send socket))
                           (set-field! connected this #f)])))

      ;; Prepare for new game

      (define/public (setup new-game ai-instance)
        (set-field! game this new-game)
        (set-field! ai this ai-instance)
        (set-field! game-manager this (new game-manager% [game game])))


      (define/public (set-constants constants)
        (send game-manager set-constants constants))

      ;; Sending data to server

      (define/private (send-raw bstr)
        (cond [print-io
               (printf "~a~a~a~a~%" (ansi #:text 'magenta)
                       "TO SERVER <-- " (bytes->string/locale bstr) reset)])
        (with-handlers ([exn:fail? disconnected-unexpectedly])
          (write-bytes bstr (Socket-send socket))))


      (define/public (send-event event data)
        (send-raw (bytes-append
                   (jsexpr->bytes (make-hash `((sentTime . ,(date->string (current-date)))
                                               (event . ,event)
                                               (data . ,(serialize data)))))
                   EOT_CHAR)))

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
              #:break (if (and (wait-for-new-events) (> (vector-length event-stack) 0))
                          (match-let ([(vector sent) (vector-take event-stack 1)])
                            (set-field! event-stack this (vector-drop event-stack 1))
                            (if (and event (string=? (hash-ref sent 'event) event))
                                (begin (set! data (hash-ref sent 'data)) #t)
                                (begin
                                  (auto-handle (hash-ref sent 'event) (hash-ref sent 'data))
                                  #f)))
                          #f))
          #t)
        data)


      (define/private (wait-for-new-events)
        (cond [(= (vector-length event-stack) 0)
               (with-handlers ([exn:fail:read? malformed-json]
                               [exn:fail? cannot-read-socket])
                 
                 (for ([_ (in-naturals)]
                       #:break
                       (let ([num-bytes-recvd (read-bytes-avail! recvd (Socket-recv socket))])
                         ;; TODO: fix this shit so it's nicer, see process-incoming-events
                         (if (> num-bytes-recvd 0)
                             (begin
                               (define new-bytes (subbytes recvd 0 num-bytes-recvd))
                               (define total (bytes-append recvd-buffer new-bytes))
                               (define-values (events partial) (split-by-eot (bytes->list total)))
                               (set-field! recvd-buffer this (list->bytes partial))
                               (cond [print-io (printf "~a~a~a~a~%"
                                                       (ansi #:text 'magenta)
                                                       "FROM SERVER --> "
                                                       events
                                                       reset)])
                               (set-field! event-stack this (build-vector
                                                             (length events)
                                                             (lambda (i)
                                                               (bytes->jsexpr (list->bytes (list-ref events i))))))
                               (> (vector-length event-stack) 0))
                             #f)))
                   #t))]
              [else #t]))


      (define/private (process-incoming-events num-bytes-recvd)
        (define new-bytes (subbytes recvd 0 num-bytes-recvd))
        (define total (bytes-append recvd-buffer new-bytes))
        (define-values (events partial)
          (split-by-eot (bytes->list total)))
        (set-field! recvd-buffer this (list->bytes partial))
        (cond [print-io (printf "~a~a~a~a~%"
                                (ansi #:text 'magenta)
                                "FROM SERVER --> "
                                events
                                reset)])
        (set-field! event-stack this
          (build-vector (length events)
            (lambda (i)
              (bytes->jsexpr (list->bytes (list-ref events i))))))
        (> (vector-length event-stack) 0))

      ;; Play game

      (define/public (play player-id)
        (with-handlers ([exn:fail? (cut ai-errored <> "AI errored when game initially started")])
          (send ai set-player player-id)
          (send ai start)
          (send ai game-updated))
        (wait-for-event #f))

      ;; Event Handlers

      (define/private (auto-handle event data)
        (with-handlers ([exn:fail? cannot-auto-handle])
          (dynamic-send this (string->symbol (string-append "auto-handle-" event)) data)))


      (define/public (auto-handle-order data)
        (define args (deserialize (hash-ref data 'args) game))
        (with-handlers ([exn:fail? (cut ai-errored <> (string-append "AI errored in order '"
                                                                     (hash-ref data 'name)
                                                                     "'.")) ])
          (define returned (dynamic-send ai (string->symbol (hash-ref data 'name)) args))
          (send-event "finished" (make-hash `((orderIndex . ,(hash-ref data 'index))
                                              (returned . ,returned))))))


      (define/public (auto-handle-delta delta)
        (define can-play? (null? get-field player ai))
        (with-handlers ([exn:fail? (cut delta-merge-failure <> "Error applying delta state.")])
          (send game-manager apply-delta-state delta))
        (cond [can-play (with-handlers ([exn:fail? (cut <> "AI errored in game-update after delta.")])
                          (send ai game-updated))]))


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
        (cond [(and (hash? data) (hash-has-key? data 'message))
               (printf "~a~a~a~%" (ansi #:text 'cyan) (hash-ref data 'message) reset)])
        (disconnect)
        (exit 0))

      ;;Error Handlers

      (define/private (disconnected-unexpectedly err)
        (disconnect)
        (handle-error 'DISCONNECTED_UNEXPECTEDLY err
                      "Could not send string through server."))


      (define/private (malformed-json err)
        (disconnect)
        (handle-error 'MALFORMED_JSON err "Error parsing json."))


      (define/private (cannot-read-socket err)
        (disconnect)
        (handle-error 'CANNOT_READ_SOCKET err "Error reading socket."))


      (define/private (could-not-connect err)
        (disconnect)
        (handle-error 'COULD_NOT_CONNECT err
                      (string-append "Could not connect to " server ":"
                                     remote-port ".")))


      (define/private (cannot-auto-handle err)
        (disconnect)
        (handle-error 'UNKNOWN_EVENT_FROM_SERVER err
                      (string-append "Cannot auto handle event '" event "'.")))


      (define/private (ai-errored err str)
        (disconnect)
        (handle-error 'AI_ERRORED err str))))

  (define client (new client%)))
