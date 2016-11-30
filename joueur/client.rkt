(module client racket
  (require "ansi-color-coder.rkt"
           racket/date
           "game-manager.rkt"
           "handle-error.rkt"
           json
           "serializer.rkt")
  (provide client)


  (define EOT_CHAR (bytes 4))
  (define ready (string-append (ansi 'bold 'default 'blue) "R"
                               (ansi 'bold 'default 'magenta) "e"
                               (ansi 'bold 'default 'cyan) "a"
                               (ansi 'bold 'default 'yellow) "d"
                               (ansi 'bold 'default 'green) "y"
                               (ansi 'none 'default 'default)))
  (define done (string-append (ansi 'bold 'default 'blue) "D"
                              (ansi 'bold 'default 'magenta) "o"
                              (ansi 'bold 'default 'cyan) "n"
                              (ansi 'bold 'default 'yellow) "e"
                              (ansi 'bold 'default 'green) "~"
                              (ansi 'none 'default 'default)))
  (struct socket (send recv) #:mutable)


  (define (split-by lst f)
    (foldr (lambda (element next)
             (if (f element)
                 (cons empty next)
                 (cons (cons element (first next)) (rest next))))
           (list empty) lst))

  
  (define (split-by-eot total)
    (match (split-by total (lambda (x) (= x 4)))
      [(list a ... b) (values a b)]
      [(list c) (values null c)]))

  
  (define client%
    (class object%
      (super-new)
      (define _ai '())
      (define _connected #f)
      (define _event-stack (make-vector 0))
      (define _game '())
      (define _game-manager '())
      (define _port 0)
      (define _print-io #f)
      (define _recvd (make-bytes 1024 0))
      (define _recvd-buffer (make-bytes 0 0))
      (define _server (string))
      (define _socket (socket #f #f))

      (define/public (connected?)
        (values _connected (socket-send _socket) (socket-recv _socket)))

      (define/public (connect server port options)
        (begin
          (set! _server server)
          (set! _port (string->number port))
          (set! _print-io (hash-ref options "print-io" #f))
          (printf "~a~a~a~a~%" (ansi 'none 'cyan 'default) "Connecting to: "
                  (ansi 'none 'default 'default)
                  (string-append server ":" port))
          (with-handlers ([exn:fail?
                           (lambda (err)
                             (begin (disconnect)
                                    (handle-error 'COULD_NOT_CONNECT err
                                                  (string-append "Could not connect to "
                                                                 server ":" port "."))))])
            (let-values ([(recv-t send-t) (tcp-connect/enable-break _server _port)])
              (file-stream-buffer-mode recv-t 'none)
              (file-stream-buffer-mode send-t 'none)
              (set-socket-send! _socket send-t)
              (set-socket-recv! _socket recv-t)))
          (set! _connected #t)))
      
      (define/public (disconnect)
        (with-handlers ([exn:fail?
                         (lambda (err)
                           (printf "~a~%" "Bad disconnect."))])
          (cond [_connected (begin (close-input-port (socket-recv _socket))
                                   (close-output-port (socket-send _socket))
                                   (set! _connected #f))])))
      
      (define/public (setup new-game ai)
        (begin (set! _game new-game)
               (set! _ai ai)
               (set! _game-manager (new game-manager% [game new-game]))))

      (define/public (set-constants constants)
        (send _game-manager set-constants constants))

      (define/private (send-raw bstr)
        (begin
          (cond [_print-io
                 (printf "~a~a~a~a~%"
                         (ansi 'none 'magenta 'default)
                         "TO SERVER <-- " (bytes->string/locale bstr)
                         (ansi 'none 'default 'default))])
          (with-handlers ([exn:fail?
                           (lambda (err)
                             (begin (disconnect)
                                    (handle-error 'DISCONNECTED_UNEXPECTEDLY err
                                                  "Could not send string through server.")))])
            (write-bytes bstr (socket-send _socket)))))
      
      (define/public (send-event event data)
        (send-raw (bytes-append
                   (jsexpr->bytes (make-hash `((sentTime . ,(date->string (current-date)))
                                               (event . ,event)
                                               (data . ,(serialize data)))))
                   EOT_CHAR)))


      (define/public (run-on-server caller function-name args)
        (begin
          (send-event "run" (make-hash `((caller . ,caller)
                                         (funtionName . ,function-name)
                                         (args . ,args))))
          (let ([ran-data (wait-for-event "ran")])
            (deserialize ran-data))))


      (define/public (wait-for-event event)
        (let ([data null])
          (for ([i (in-naturals)]
                #:break (if (and (wait-for-new-events) (> (vector-length _event-stack) 0))
                            (match-let ([(vector sent) (vector-take-right _event-stack 1)])
                              (set! _event-stack (vector-drop-right _event-stack 1))
                              ;; (printf "~a~%~a~%" _event-stack sent)
                              (if (and event (string=? (hash-ref sent `event) event))
                                  (begin (set! data (hash-ref sent `data))
                                         ;; (printf "~a~%" data)
                                         #t)
                                  (begin
                                    (auto-handle (hash-ref sent 'event) (hash-ref sent 'data))
                                    #f)))
                            #f))
            #t)
          data))


      (define/private (wait-for-new-events)
        (cond [(= (vector-length _event-stack) 0)
               (with-handlers ([exn:fail:read? (lambda (err)
                                                 (begin (disconnect)
                                                        (handle-error 'MALFORMED_JSON err
                                                                      "Error parsing json.")))]
                               [exn:fail? (lambda (err)
                                            (begin (disconnect)
                                                   (handle-error 'CANNOT_READ_SOCKET err
                                                                 "Error reading socket.")))])
                 (for ([i (in-naturals)]
                       #:break (let ([num-bytes-recvd (read-bytes-avail! _recvd (socket-recv _socket))])
                                 (if (> num-bytes-recvd 0)
                                     (let*-values ([(total) (bytes->list (bytes-append _recvd-buffer
                                                                           (subbytes _recvd 0 num-bytes-recvd)))]
                                                   [(events partial) (split-by-eot total)])
                                       (set! _recvd-buffer (list->bytes partial))
                                       (cond [_print-io (printf "~a~a~a~a~%"
                                                                (ansi 'none 'magenta 'default)
                                                                "FROM SERVER --> " events
                                                                (ansi 'none 'default 'default))])
                                       (set! _event-stack (build-vector
                                                           (length events)
                                                           (lambda (i)
                                                             (bytes->jsexpr (list->bytes (list-ref events i))))))
                                       (> (vector-length _event-stack) 0))
                                     #f)))
                   #t))]
              [else #t]))


      (define/public (play player-id)
        (set-field! player _ai (send _game get-game-object player-id))

        (with-handlers ([exn:fail? (lambda (err)
                                     (handle-error 'AI_ERRORED err
                                                   "AI errored when game initially started"))])
          (send _ai start)
          (send _ai game-updated))
        (wait-for-event #f))


      (define/private (auto-handle event data)
        (with-handlers ([exn:fail? (lambda (err)
                                     (begin (disconnect)
                                            (handle-error 'UNKNOWN_EVENT_FROM_SERVER err
                                                          (string-append "Cannot auto handle event '"
                                                                         event
                                                                         "'."))))])
          (dynamic-send this (string->symbol (string-append "auto-handle-" event)) data)))


      (define/public (auto-handle-order data)
        (let ([args (deserialize (hash-ref data 'args) _game)])
          (with-handlers ([exn:fail? (lambda (err)
                                       (begin (disconnect)
                                              (handle-error 'AI_ERRORED err (string-append
                                                                             "AI errored in order '"
                                                                             (hash-ref data 'name)
                                                                             "'."))))])
            (let ([returned (dynamic-send _ai (string->symbol (hash-ref data 'name)) args)])
              (send-event "finished" (make-hash `((orderIndex . ,(hash-ref data 'index))
                                                  (returned . ,returned))))))))


      (define/public (auto-handle-delta delta)
        (let ([can-play (null? (get-field player _ai))])
          (with-handlers ([exn:fail? (lambda (err)
                                       (begin (disconnect)
                                              (handle-error 'DELTA_MERGE_FAILURE err
                                                            "Error applying delta state.")))])
            (send _game-manager apply-delta-state delta))
          (cond [can-play (with-handlers ([exn:fail? (lambda (err)
                                                       (begin (disconnect)
                                                              (handle-error 'AI_ERRORED err
                                                                            "AI errored in game-update after delta.")))])
                            (send _ai game-updated))])))

      
      (define/public (auto-handle-invalid data)
        (with-handlers ([exn:fail? (lambda (err)
                                     (begin (disconnect)
                                            (handle-error 'AI_ERRORED err "AI errored in invalid.")))])
          (send _ai invalid (hash-ref data 'message))))

      
      (define/public (auto-handle-fatal data)
        (begin (disconnect)
               (handle-error 'FATAL_EVENT (exn "" (current-continuation-marks))
                             (string-append "got fatal event from server: "
                                            (hash-ref data 'message)))))

      
      (define/public (auto-handle-over data)
        (let* ([player (get-field player _ai)]
               [won? (get-field won? player)]
               [reason (if won?
                           (get-field reason-won player)
                           (get-field reason-lost player))]
               [message (if won? "I Won!" "I Lost :C")])
          (printf "~a~a ~a ~a ~a~a~%" (ansi 'none 'green 'default)
                  "Game is over." message "because" reason
                  (ansi 'none 'default 'default))
          (with-handlers ([exn:fail? (lambda (err)
                                       (begin (disconnect)
                                              (handle-error 'AI_ERRORED err "AI errored in ended().")))])
            (send _ai ended won? reason))
          (cond [(and (hash? data) (hash-has-key? data 'message))
                 (printf "~a~a~a~%" (ansi 'none 'cyan 'default)
                         (hash-ref data 'message) (ansi 'none 'default 'default))])
          (disconnect)
          ;; (print "exiting with code 0")
          (exit 0)
          ))))

  (define client (new client%)))
