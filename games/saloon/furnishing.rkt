(module furnishing racket
  (require "game-object.rkt")
  (provide furnishing%)


  (define furnishing%
    (class game-object%
      (super-new)
      (inherit-field id
                     game-object-name
                     logs)
      (field [health 0]
             [destroyed? false]
             [piano? false]
             [playing? false]
             [tile null]))))
