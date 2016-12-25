#lang racket

(require "game-object.rkt")

(provide player%)


(define player%
  (class game-object%
    (super-new)
    (field [client-type ""]
           [cowboys (vector)]
           [kills 0]
           [lost false]
           [name ""]
           [opponent null]
           [reason-lost ""]
           [reason-won ""]
           [rowdiness 0]
           [score 0]
           [siesta 0]
           [time-remaining 0]
           [won false]
           [young-gun null])))
