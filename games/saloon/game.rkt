(module game racket
  (require "../../joueur/base-game.rkt"
           "bottle.rkt"
           "cowboy.rkt"
           "furnishing.rkt"
           "game-object.rkt"
           "player.rkt"
           "tile.rkt"
           "young-gun.rkt")
  (provide game%)


  (define game%
    (class base-game%
      (super-new)
      (field [name "Saloon"]
             [bartender-cooldown 0]
             [bottles #()]
             [brawler-damage 0]
             [cowboys #()]
             [current-player null]
             [current-turn 0]
             [furnishings #()]
             [jobs #()]
             [map-height 0]
             [map-width 0]
             [max-cowboys-per-job 0]
             [max-turns 0]
             [players #()]
             [rowdiness-to-siesta 0]
             [session ""]
             [sharpshooter-damage 0]
             [siesta-length 0]
             [tiles #()]
             [turns-drunk 0])
      (set-field! game-object-classes this (make-hash `(("Bottle" . ,bottle%)
                                                        ("Cowboy" . ,cowboy%)
                                                        ("Furnishing" . ,furnishing%)
                                                        ("GameObject" . ,game-object%)
                                                        ("Player" . ,player%)
                                                        ("Tile" . ,tile%)
                                                        ("YoungGun" . ,young-gun%)))))))
