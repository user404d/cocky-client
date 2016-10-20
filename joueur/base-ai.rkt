(module base-ai racket
  (require "ansi-color-coder.rkt"
           "base-game.rkt"
           "base-game-object.rkt")
  (provide base-ai%)
  
  
  (define base-ai%
    (class object%
      (init game)
      (super-new)
      (define _game game)
      (define _name "Racket Player")
      (define/public (get-name)
        _name)
      (define/public (set-name new-name)
        (set! _name new-name))
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
