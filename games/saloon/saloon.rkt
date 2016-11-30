(module saloon racket
  (require "ai.rkt"
           "game.rkt")
  (provide Game AI)


  (define Game (new game%))
  (define AI (new ai% [game Game])))
