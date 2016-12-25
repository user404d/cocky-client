#lang racket

(require "../../joueur/base-game-object.rkt")

(provide game-object%)


(define game-object%
  (class base-game-object%
    (super-new)
    (field [game-object-name ""]
           [logs (vector)])))
