(module handle-error racket
  (require "ansi-color-coder.rkt")
  (provide handle-error)

  
  (define delimeter-color (ansi 'bold 'red 'default))
  (define error-color (ansi 'bold 'red 'default))
  (define basic-color (ansi 'none 'default 'default))

  (define (delimit-message message)
    (fprintf (current-error-port) "~a~a~%~a---~a~%"
            basic-color
            message
            delimeter-color
            basic-color))


  (define (spooky-message message)
    (fprintf (current-error-port) "~aSpooky error. ~a~a~%"
            (ansi 'blink 'green 'blue)
            message
            basic-color))

  
  (define error-codes
    (make-hash '((NONE . 0)
                 (INVALID_ARGS . 20)
                 (COULD_NOT_CONNECT . 21)
                 (DISCONNECTED_UNEXPECTEDLY . 22)
                 (CANNOT_READ_SOCKET . 23)
                 (DELTA_MERGE_FAILURE . 24)
                 (REFLECTION_FAILED . 25)
                 (UNKNOWN_EVENT_FROM_SERVER . 26)
                 (SERVER_TIMEOUT . 27)
                 (FATAL_EVENT . 28)
                 (GAME_NOT_FOUND . 29)
                 (MALFORMED_JSON . 30)
                 (UNAUTHENTICATED . 31)
                 (AI_ERRORED . 42))))


  (define (handle-error code-name err message)
    ;; handle errors and report them
    (fprintf (current-error-port) "~a---~%~aError:~a ~a~%~a---~a~%"
              delimeter-color
              error-color
              basic-color
              codeName
              delimeter-color
              basic-color)
      (if (null? message)
          (if (null? err)
              (spooky-message "<err and message were null>")
              (delimit-message err))
          (delimit-message message))
      (if (null? err)
          (spooky-message "<err was null>")
          (delimit-message (exn-message err)))
      (if (or (null? err) (null? (exn-continuation-marks err)))
          (error-value->string-handler)
          (delimit-message (exn-continuation-marks err)))
      (define error-code (hash-ref error-codes code-name #f))
      (flush-output)
      (flush-output (current-error-port))
      (if errorCode
          (exit errorCode)
          (exit 0))))
