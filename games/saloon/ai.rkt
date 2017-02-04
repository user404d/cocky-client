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
             [else                             ;keep expanding
              (define added
                (for/vector ([neighbor (vector-filter pathable neighbors)]
                             #:unless (hash-has-key? from neighbor))
                  (hash-set! from neighbor top)
                  neighbor))
              (bfs (vector-append (list->vector rest) added))])])))


(define ai%
  (class base-ai%
    (super-new)
    (inherit-field game settings)
    (field [player null]
           [pianos (vector)])


    (define/public (set-player player-id)
      (set-field! player this (send game get-game-object player-id)))


    (define/override (start)
      (set-field! pianos this (vector-filter (cut <: 'is-piano <>)
                                             (<: 'furnishings game))))


    (define/public (run-turn args)
      (printf "running turn~%")

      (if (> 6 (vector-length (get-field cowboys player)))
          (send (get-field young-gun player) call-in
                (vector-ref (get-field jobs game) (random 3)))
          (printf "failed to call in~%"))

      (for ([cowboy (get-field cowboys player)])
        (unless (get-field is-dead cowboy)
          (define target (<: 'tile (vector-ref pianos 0)))
          (define loc (<: 'tile cowboy))
          (define path (find-path loc target))
          (if (> (vector-length path) 0)
              (send cowboy move (vector-ref path 0))
              (printf "can't move~%"))

          (when (vector-member target (send loc neighbors))
            (send cowboy play (<: 'furnishing target)))))

      (set-field! pianos this (vector-filter-not (cut <: 'is-destroyed <>)
                                                 pianos))

      (printf "ending turn~%")
      #t)

    (define/override (ended won reason)
      (printf "~a" settings))))
