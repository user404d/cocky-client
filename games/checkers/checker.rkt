;; Checker: A checker on the game board.
#lang racket

;; DO NOT MODIFY THIS FILE
;; Never try to directly create an instance of this class, or modify its member variables.
;; Instead, you should only be reading its variables and calling its functions.

(require "../../joueur/client.rkt"
  "game-object.rkt"
  "../../joueur/base-game-object.rkt"
)


(provide checker%)


;; <<-- Creer-Merge: require -->> - Code you add between this comment and the end comment will be preserved between Creer re-runs.
;; you can add additional import(s) here
;; <<-- /Creer-Merge: require -->>

(define checker%
    (class game-object%
      (super-new)
      ;; The class representing the Checker in the Checkers game.
      ;; A checker on the game board.
      (field

        ;; bool - If the checker has been kinged and can move backwards.
        [kinged #f]

        ;; Player - The player that controls this Checker.
        [owner null]

        ;; int - The x coordinate of the checker.
        [x 0]

        ;; int - The y coordinate of the checker.
        [y 0]
      )

    (define/public (is-mine )
    ;; Returns if the checker is owned by your player or not.
    ;; Returns:
    ;; bool: #t if it is yours, false if it is not yours.
      (send client run-on-server this "isMine" (make-hash `(
      ))))

    (define/public (move x y)
    ;; Moves the checker from its current location to the given (x, y).

    ;; Args:
    ;; x (int): The x coordinate to move to.
    ;; y (int): The y coordinate to move to.
    ;; Returns:
    ;; Checker: Returns the same checker that moved if the move was successful. null otherwise.
      (send client run-on-server this "move" (make-hash `(
        (x . ,x)
        (y . ,y)
      ))))

))
