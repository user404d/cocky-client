#lang racket

(require "../../joueur/client.rkt"
         "game-object.rkt")

(provide cowboy%)


(define (get-tile dir tile)
  (dynamic-get-field (string->symbol (string-append "tile-" dir)) tile))

(define cowboy%
  (class game-object%
    (super-new)
    (field [can-move false]
           [drunk-direction ""]
           [focus 0]
           [health 0]
           [is-dead false]
           [is-drunk false]
           [job ""]
           [owner null]
           [tile null]
           [tolerance 0]
           [turns-busy 0])

    (define/public (neighbors)
      (vector-filter-not null? `#(,(get-tile "east" tile)
                                  ,(get-tile "west" tile)
                                  ,(get-tile "south" tile)
                                  ,(get-tile "north" tile))))

    (define/public (act on-tile [direction ""])
      (send client run-on-server this "act" (make-hash `((tile . ,on-tile)
                                                         (drunkDirection . ,direction)))))

    (define/public (move to-tile)
      (send client run-on-server this "move" (make-hash `((tile . ,to-tile)))))

    (define/public (play piano)
      (send client run-on-server this "play" (make-hash `((piano . ,piano)))))))
