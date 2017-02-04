;; Player: A player in this game. Every AI controls one player.
#lang racket

;; DO NOT MODIFY THIS FILE
;; Never try to directly create an instance of this class, or modify its member variables.
;; Instead, you should only be reading its variables and calling its functions.

(require "../../joueur/client.rkt"
  "game-object.rkt"
  "../../joueur/base-game-object.rkt"
)


(provide player%)


;; <<-- Creer-Merge: require -->> - Code you add between this comment and the end comment will be preserved between Creer re-runs.
;; you can add additional import(s) here
;; <<-- /Creer-Merge: require -->>

(define player%
    (class game-object%
      (super-new)
      ;; The class representing the Player in the Checkers game.
      ;; A player in this game. Every AI controls one player.
      (field

        ;; (vector Checker ... ) - All the checkers currently in the game owned by this player.
        [checkers (vector)]

        ;; string - What type of client this is, e.g. 'Python', 'JavaScript', or some other language. For potential data mining purposes.
        [client-type ""]

        ;; bool - If the player lost the game or not.
        [lost #f]

        ;; string - The name of the player.
        [name "Anonymous"]

        ;; Player - This player's opponent in the game.
        [opponent null]

        ;; string - The reason why the player lost the game.
        [reason-lost ""]

        ;; string - The reason why the player won the game.
        [reason-won ""]

        ;; float - The amount of time (in ns) remaining for this AI to send commands.
        [time-remaining 0]

        ;; bool - If the player won the game or not.
        [won #f]

        ;; int - The direction your checkers must go along the y-axis until kinged.
        [y-direction 0]
      )

))
