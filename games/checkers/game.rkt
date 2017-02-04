;; Game: The simple version of American Checkers. An 8x8 board with 12 checkers on each side that must move diagonally to the opposing side until kinged.
#lang racket

;; DO NOT MODIFY THIS FILE
;; Never try to directly create an instance of this class, or modify its member variables.
;; Instead, you should only be reading its variables and calling its functions.

(require "../../joueur/client.rkt"
  "../../joueur/base-game.rkt"
  "checker.rkt"
  "game-object.rkt"
  "player.rkt"
)


(provide game%)


;; <<-- Creer-Merge: require -->> - Code you add between this comment and the end comment will be preserved between Creer re-runs.
;; you can add additional import(s) here
;; <<-- /Creer-Merge: require -->>

(define game%
    (class base-game%
      (super-new)
      ;; The class representing the Game in the Checkers game.
      ;; The simple version of American Checkers. An 8x8 board with 12 checkers on each side that must move diagonally to the opposing side until kinged.
      (field

        ;; int - The height of the board for the Y component of a checker.
        [board-height 8]

        ;; int - The width of the board for X component of a checker.
        [board-width 8]

        ;; Checker - The checker that last moved and must be moved because only one checker can move during each players turn.
        [checker-moved null]

        ;; bool - If the last checker that moved jumped, meaning it can move again.
        [checker-moved-jumped #f]

        ;; (vector Checker ... ) - All the checkers currently in the game.
        [checkers (vector)]

        ;; Player - The player whose turn it is currently. That player can send commands. Other players cannot.
        [current-player null]

        ;; int - The current turn number, starting at 0 for the first player's turn.
        [current-turn 0]

        ;; int - The maximum number of turns before the game will automatically end.
        [max-turns 100]

        ;; (vector Player ... ) - vector of all the players in the game.
        [players (vector)]

        ;; string - A unique identifier for the game instance that is being played.
        [session ""]
      )

    (set-field! game-object-classes this (make-hash `(
        ("Player" . ,player%)
        ("Checker" . ,checker%)
        ("GameObject" . ,game-object%)
    )))
))
