(module tile racket
  (require "game-object.rkt")
  (provide tile%)


  (define tile%
    (class game-object%
      (super-new)
      (field [bottle null]
             [cowboy null]
             [furnishing null]
             [has-hazard false]
             [is-balcony false]
             [tile-east null]
             [tile-north null]
             [tile-south null]
             [tile-west null]
             [x 0]
             [y 0]
             [young-gun null]))))
