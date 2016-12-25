#lang racket

(require "game-object.rkt")

(provide furnishing%)


(define furnishing%
  (class game-object%
    (super-new)
    (field [health 0]
           [is-destroyed false]
           [is-piano false]
           [is-playing false]
           [tile null])))
