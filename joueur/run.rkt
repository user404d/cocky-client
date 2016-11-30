(module run racket
  (require "ansi-color-coder.rkt"
           "client.rkt"
           "handle-error.rkt")
  (provide run)


  (define (connected-to-lobby-message lobby-data)
    (printf "~a~a~a~%" (ansi 'none 'cyan 'default)
            (string-append "In lobby for game '" (hash-ref lobby-data 'gameName)
                           "' in session '" (hash-ref lobby-data 'gameSession))
            (ansi 'none 'default 'default)))


  (define (game-starting-message)
    (printf "~a~a~a~%" (ansi 'none 'green 'default) "Game is starting." (ansi 'none 'default 'default)))

  (define (split-by-colon str) (match (string-split str ":")
                                 [(list server) (values server "")]
                                 [(list server port) (values server port)]))
  
  
  (define Game (make-parameter null))
  (define AI (make-parameter null))
  
  
  (define (run args)
    (let*-values ([(server maybe-port) (split-by-colon (hash-ref args 'server))]
                  [(port) (if (non-empty-string? maybe-port) (values maybe-port)
                              (values (hash-ref args 'port)))])
      (send client connect server port args)
      (send client send-event "alias" (hash-ref args 'game-name))
      (let* ([game-name (send client wait-for-event "named")]
             [game-name-downcase (string-downcase game-name)]
             [module-str (string-append "games/" game-name-downcase "/" game-name-downcase ".rkt")])
        (with-handlers ([exn:fail? (lambda (err)
                                     (handle-error 'GAME_NOT_FOUND err
                                                   (string-append "Could not find the module for game " game-name)))])
          (Game (dynamic-require module-str 'Game))
          (AI (dynamic-require module-str 'AI)))
        (let* ([~password (hash-ref args 'password)]
               [session (hash-ref args 'session-name)]
               [game (Game)]
               [ai (AI)]
               [player-name (hash-ref args 'player-name)]
               [index (hash-ref args 'player-id)]
               [game-settings (hash-ref args 'game-settings)])
          (send client setup game ai)
          (send client send-event "play" (make-hash `((gameName . ,game-name)
                                                      (password . ,~password)
                                                      (requestedSession . ,session)
                                                      (clientType . "Scheme")
                                                      (playerName . ,player-name)
                                                      (playerIndex . ,index)
                                                      (gameSettings . ,game-settings))))
          (let ([lobby-data (send client wait-for-event "lobbied")])
            (connected-to-lobby-message lobby-data)
            (send client set-constants (hash-ref lobby-data 'constants)))
          (let ([start-data (send client wait-for-event "start")])
            (game-starting-message)
            (send client play (hash-ref start-data 'playerID))))))))
