(module handleError (handleError)
  (import chicken
          scheme
          (only extras format))
  (use ansiColorCoder
       lookup-table
       (only client <Client> disconnect)
       (only coops make))


  (define delimeter-color
    (ansi 'bold 'red 'default)
    )


  (define error-color
    (ansi 'bold 'red 'default)
    )


  (define basic-color
    (ansi 'none 'default 'default)
    )


  (define (delimit-message message)
    (format (current-error-port)
            "~A~A~%~A---~A~%"
            basic-color
            message
            delimeter-color
            basic-color)
    )


  (define (spooky-message message)
    (format (current-error-port)
            "~ASpooky error. ~A~A~%"
            (ansi 'blink 'green 'blue)
            message
            basic-color))

  
  (define errorCodes
    (alist->dict '((NONE 0)
                   (INVALID_ARGS 20)
                   (COULD_NOT_CONNECT 21)
                   (DISCONNECTED_UNEXPECTEDLY 22)
                   (CANNOT_READ_SOCKET 23)
                   (DELTA_MERGE_FAILURE 24)
                   (REFLECTION_FAILED 25)
                   (UNKNOWN_EVENT_FROM_SERVER 26)
                   (SERVER_TIMEOUT 27)
                   (FATAL_EVENT 28)
                   (GAME_NOT_FOUND 29)
                   (MALFORMED_JSON 30)
                   (UNAUTHENTICATED 31)
                   (AI_ERRORED 42)))
    )


  (define (handleError codeName err message)
    ;; handle errors and report them
    (begin
      (format (current-error-port)
              "~A---~%~AError:~A ~A~%~A---~A~%"
              delimeter-color
              error-color
              basic-color
              codeName
              delimeter-color
              basic-color
              )
      (if (null? message)
          (if (null? err)
              (spooky-message "<err and message were null>")
              (delimit-message err))
          (delimit-message message))
      (if (null? err)
          (spooky-message "<err was null>")
          (delimit-message ((condition-property-accessor 'exn 'message) err)))
      (if (or (null? err) (null? ((condition-property-accessor 'exn 'arguments) err)))
          (print-call-chain (current-error-port) 1)
          (delimit-message ((condition-property-accessor 'exn 'arguments) err)))
      (let ((client (make <Client>))
            (errorCode (dict-ref errorCodes codeName)))
        (begin
          (disconnect client)
          (flush-output)
          (flush-output (current-output-port))
          ;; (if errorCode
          ;; (exit (car errorCode))
          ;; (exit 0))
        )
      )
    )
  )
)
