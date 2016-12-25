#lang racket

(require "../../joueur/client.rkt"
         "game-object.rkt")

(provide young-gun%)


(define young-gun%
  (class game-object%
    (super-new)
    (field [call-in-tile null]
           [can-call-in false]
           [owner null]
           [tile null])

    (define/public (call-in job)
      (send client run-on-server this "callIn" (make-hash `((job . ,job)))))))
