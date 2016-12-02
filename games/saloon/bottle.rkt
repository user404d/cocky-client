(module bottle racket
  (require "game-object.rkt")
  (provide bottle%)


  (define bottle%
    (class game-object%
      (super-new)
      (field [direction ""]
             [drunk-direction ""]
             [is-destroyed false]
             [tile null]))))
