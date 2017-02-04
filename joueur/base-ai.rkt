#lang racket/base

(require "ansi-color-coder.rkt"
         "base-game.rkt"
         "base-game-object.rkt"
         racket/class)

(provide base-ai%)


(define base-ai%
  (class object%
    (super-new)
    (init-field game)
    (field [name "Racket Player"]
           [settings (make-hash)])

    (define/private (set-settings ai-settings-str)
      (define settings-pairs
        (regexp-split "&" ai-settings-str))
      (for ([pair settings-pairs])
        (match (regexp-split "=" pair)
          [(list key value) (hash-set! settings key)])))
    
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
