#lang racket

(require "../../joueur/base-ai.rkt"
         "../../joueur/utilities.rkt")

(provide ai%)


(define (not-pathable tile)
  (not (or (<: 'furnishing tile) (<: 'cowboy tile))))


(define (find-path initial target)
  (define from (make-hash '((,initial . null))))
  (let expand ([frontier (vector initial)])
    (match frontier
      [(app vector-length 0) (vector)]
      [(vector top rest ...)
       (define neighbors (send top neighbors))
       (cond [(vector-member target neighbors)
              (do ([step top (hash-ref from step)]
                   [steps null (cons step steps)])
                  [(null? (hash-ref from step)) (list->vector steps)])]
             [else
              (define added-neighbors
                (for/vector ([neighbor (vector-filter not-pathable neighbors)]
                             #:unless (hash-ref from neighbor #f))
                  (hash-set! from neighbor top)))
              (expand (vector-append (list->vector rest) added-neighbors))])])))


(define ai%
  (class base-ai%
    (super-new)
    (inherit-field game)
    (field [player null]
           [target null])
    
    (define/public (set-player player-id)
      (set-field! player this (send game get-game-object player-id)))

    (define/override (start)
      (for ([furniture (<: 'furnishings game)]
            #:break (cond [(<: 'is-piano furniture)
                           (set-field! target this (<: 'tile furniture))]
                          [else #f]))
        #t)
      (printf "~a~%" target))
    
    (define/public (runTurn args)
      (printf "running turn~%")
      
      (if (> 6 (vector-length (get-field cowboys player)))
          (send (get-field young-gun player) call-in
                (vector-ref (get-field jobs game) (random 3)))
          (printf "failed to call in~%"))
      
      (for ([cowboy (get-field cowboys player)])
        (unless (get-field is-dead cowboy)
          (let ([path (find-path (<: 'tile cowboy) target)])
            (if (> (vector-length path) 0)
                (send cowboy move (vector-ref path 0))
                (printf "can't move~%")))))
      
      (printf "ending turn~%")
      #t)))
