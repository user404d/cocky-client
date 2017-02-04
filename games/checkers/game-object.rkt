;; GameObject: An object in the game. The most basic class that all game classes should inherit from automatically.
#lang racket

;; DO NOT MODIFY THIS FILE
;; Never try to directly create an instance of this class, or modify its member variables.
;; Instead, you should only be reading its variables and calling its functions.

(require "../../joueur/client.rkt"
  "../../joueur/base-game-object.rkt"
)


(provide game-object%)


;; <<-- Creer-Merge: require -->> - Code you add between this comment and the end comment will be preserved between Creer re-runs.
;; you can add additional import(s) here
;; <<-- /Creer-Merge: require -->>

(define game-object%
    (class base-game-object%
      (super-new)
      ;; The class representing the GameObject in the Checkers game.
      ;; An object in the game. The most basic class that all game classes should inherit from automatically.
      (field

        ;; string - String representing the top level Class that this game object is an instance of. Used for reflection to create new instances on clients, but exposed for convenience should AIs want this data.
        [game-object-name ""]

        ;; (vector string ... ) - Any strings logged will be stored here. Intended for debugging.
        [logs (vector)]
      )

    (define/public (log message)
    ;; Adds a message to this GameObject's logs. Intended for your own debugging purposes, as strings stored here are saved in the gamelog.

    ;; Args:
    ;; message (string): A string to add to this GameObject's log. Intended for debugging.
      (send client run-on-server this "log" (make-hash `(
        (message . ,message)
      ))))

))
