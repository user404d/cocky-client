#lang racket/base

(require "ansi-color-coder.rkt"
         "client.rkt"
         "handle-error.rkt"
         (only-in racket/class
                  send)
         racket/match
         racket/string
         srfi/26)

(provide run)


(define (connected-to-lobby-message lobby-data)
  (printf "~a~a~a~%" (ansi #:text 'cyan)
          (string-append "In lobby for game '" (hash-ref lobby-data 'gameName)
                         "' in session '" (hash-ref lobby-data 'gameSession)
                         "'.")
          reset))


(define (game-starting-message)
  (printf "~a~a~a~%" (ansi #:text 'green) "Game is starting." reset))


(define (split-by-colon str)
  (match (string-split str ":")
    [(list server) (values server "")]
    [(list server port) (values server port)]))


(define Game null)
(define AI null)


(define (run args)
  (define-values (server maybe-port) (split-by-colon (hash-ref args 'server)))
  (define port
    (if (non-empty-string? maybe-port)
        maybe-port
        (hash-ref args 'port)))
  (send client connect server port args)
  (send client send-event "alias" (hash-ref args 'game-name))
  (define game-name (send client wait-for-event "named"))
  (define game-name-downcase (string-downcase game-name))
  (define module-str (string-append "games/" game-name-downcase "/main.rkt"))
  (with-handlers ([exn:fail? (cut module-not-found <> game-name)])
    (set! Game (dynamic-require module-str 'Game))
    (set! AI (dynamic-require module-str 'AI)))
  (define ~password (hash-ref args 'password))
  (define session (hash-ref args 'session-name))
  (define player-name
    (if (non-empty-string? (hash-ref args 'player-name))
        (hash-ref args 'player-name)
        (send AI get-name)))
  (define index (hash-ref args 'player-id))
  (define game-settings (hash-ref args 'game-settings))
  (send AI set-settings (hash-ref args 'ai-settings))
  (send client setup Game AI)
  (send client send-event "play" (make-hash `((gameName . ,game-name)
                                              (password . ,~password)
                                              (requestedSession . ,session)
                                              (clientType . "Racket")
                                              (playerName . ,player-name)
                                              (playerIndex . ,index)
                                              (gameSettings . ,game-settings))))
  (define lobby-data (send client wait-for-event "lobbied"))
  (connected-to-lobby-message lobby-data)
  (send client set-constants (hash-ref lobby-data 'constants))
  (define start-data (send client wait-for-event "start"))
  (game-starting-message)
  (send client play (hash-ref start-data 'playerID)))

;; Error Handler(s)

(define (module-not-found err game-name)
  (handle-error 'GAME_NOT_FOUND err
                (string-append "Could not find the module for game " game-name)))
