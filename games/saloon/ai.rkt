(module ai racket
  (require "../../joueur/base-ai.rkt")
  (provide ai%)

  (define ai%
    (class base-ai%
      (super-new)
      (inherit-field game)
      (field (player '()))
      (define/public (set-player new-player)
        (player new-player))
      (define/public (runTurn args)
        (print "running turn")
        (print "ending turn")
        #t))))
