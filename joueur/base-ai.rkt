(module base-ai racket
  (require "ansi-color-coder.rkt"
           "base-game.rkt"
           "base-game-object.rkt")
  (provide base-ai%)
  
  
  (define base-ai%
    (class object%
      (super-new)
      (init-field game)
      (field (name "Racket Player"))
      (define/public (get-name)
        name)
      (define/public (set-name new-name)
        (set! name new-name))
      (define/public (start)
        (~a "Implement me!"))
      (define/public (game-updated)
        (~a "Implement me!"))
      (define/public (invalid message)
        (printf "~a~a ~a~a~%"
                (ansi 'bold 'yellow 'default)
                "Invalid:"
                message
                (ansi 'none 'default 'default)))
      (define/public (ended won reason)
        (~a "Implement me!"))
      )
    )
  )
