#lang racket

(require "../../joueur/base-ai.rkt"
         "../../joueur/utilities.rkt"
         srfi/26)

(provide ai%)


(define (pathable tile)
  (not (or (<: 'is-balcony tile)
           (object? (<: 'furnishing tile))
           (object? (<: 'cowboy tile)))))


(define (find-path initial target)
  (define from (make-hash `((,initial . null))))
  (let bfs ([frontier (vector initial)])
    (match frontier
      [(app vector-length 0) (vector)]  ;return empty path
      [(vector top rest ...)
       (define neighbors (send top neighbors))
       (cond [(vector-member target neighbors) ;reconstruct path
              (do ([step top (hash-ref from step)]
                   [steps null (cons step steps)])
                  [(eq? step initial) (list->vector steps)])]
             [else
              (define added
                (for/vector ([neighbor (vector-filter pathable neighbors)]
                             #:unless (hash-has-key? from neighbor))
                  (hash-set! from neighbor top)
                  neighbor))
              (bfs (vector-append (list->vector rest) added))])])))


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
        #t))
    
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
