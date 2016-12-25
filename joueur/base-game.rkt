#lang racket

(provide base-game%)


(define base-game%
  (class object%
    (super-new)
    (init-field [game-objects (make-hash)]
                [game-object-classes (make-hash)])
    
    (define/public (get-game-object id)
      (hash-ref game-objects id #f))
    
    (define/public (set-game-object id class-name)
      (hash-set! game-objects id (new (hash-ref game-object-classes class-name))))))
