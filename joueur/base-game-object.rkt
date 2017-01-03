#lang racket/base

(require racket/class)

(provide base-game-object%)


(define base-game-object%
  (class object%
    (super-new)
    (init-field [id "0"])
    
    (define/public (get-id) id)))
