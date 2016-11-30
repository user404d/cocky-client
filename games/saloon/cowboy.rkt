(module cowboy racket
  (require "../../joueur/client.rkt"
           "game-object.rkt")
  (provide cowboy%)


  (define cowboy%
    (class game-object%
      (super-new)
      (inherit-field id
                     game-object-name
                     logs)
      (field [can-move? false]
             [drunk-direction ""]
             [focus 0]
             [health 0]
             [dead? false]
             [drunk? false]
             [job ""]
             [owner null]
             [tile null]
             [tolerance 0]
             [turns-busy 0])

      (define/public (act on-tile [direction ""])
        (send client run-on-server this "act" (make-hash `((tile . ,on-tile)
                                                           (drunkDirection . ,direction)))))

      (define/public (move to-tile)
        (send client run-on-server this "move" (make-hash `((tile . ,to-tile)))))

      (define/public (play piano)
        (send client run-on-server this "play" (make-hash `((piano . ,piano))))))))
