(module bottle racket
  (require "game-object.rkt")
  (provide bottle%)


  (define bottle%
    (class game-object%
      (super-new)
      (inherit-field id
                     game-object-name
                     logs)
      (field [direction ""]
             [drunk-direction ""]
             [destroyed? false]
             [tile null]))))
