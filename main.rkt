#lang racket

(require "joueur/run.rkt")


(define args (make-hash '((server . "localhost")
                          (port . "3000")
                          (player-name . "")
                          (player-id . 0)
                          (password . "")
                          (session-name . "*")
                          (game-settings . "")
                          (print-io . #f)
                          (game-name . ""))))


(run (command-line
      #:program "Racket Client"
      #:once-each
      [("-s" "--server") server
       "the url to the server you want to connect to e.g. localhost:3000"
       (hash-set! args 'server server)]
      [("-p" "--port") port
       "the port to connect to on the server. Can be defined on the server arg via server:port"
       (hash-set! args 'port port)]
      [("-n" "--name") player-name
       "the name you want to use as your AI's player name"
       (hash-set! args 'player-name player-name)]
      [("-i" "--index") player-id
       "the player number you want to be, with 0 being the first player"
       (hash-set! args 'player-id player-id)]
      [("-w" "--password") password
       "the password required for authentication on official servers"
       (hash-set! args 'password password)]
      [("-r" "--session") session-name
       "the requested game session you want to play on the server"
       (hash-set! args 'session-name session-name)]
      [("-g" "--gameSettings") game-settings
       "Any settings for the game server to force. Must be url parms formatted (key=value&otherKey=otherValue)"
       (hash-set! args 'game-settings game-settings)]
      [("-d" "--printIO") "(debugging) print IO through the TCP socket to the terminal"
       (hash-set! args 'print-io #t)]
      #:args (game-name) ; expect one command-line argument: <filename>
                                        ; return the argument as a filename to compile
      (begin
        (hash-set! args 'game-name game-name)
        args)))
