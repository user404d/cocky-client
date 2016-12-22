#lang racket

(require "ansi-color-coder.rkt"
         "base-game.rkt"
         "base-game-object.rkt")

(provide base-ai%)


(define base-ai%
  (class object%
    (super-new)
    (init-field game)
    (field [name "Racket Player"])
    
    (define/public (get-name) name)
    
    (define/public (set-name new-name)
      (set-field! name this new-name))
    
    (define/public (start)
      (printf "Implement me!~%"))
    
    (define/public (game-updated)
      (printf "Implement me!~%"))
    
    (define/public (invalid message)
      (printf "~a~a ~a~a~%" (ansi #:mod 'bold #:text 'yellow)
              "Invalid:" message reset))
    
    (define/public (ended won reason)
      (printf "Implement me!~%"))))
