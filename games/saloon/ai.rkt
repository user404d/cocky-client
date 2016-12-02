(module ai racket
  (require "../../joueur/base-ai.rkt")
  (provide ai%)


  (define (path-find cowboy ahh)
    'ayy)
  
  (define ai%
    (class base-ai%
      (super-new)
      (inherit-field game)
      (field [player null])
      
      (define/public (set-player player-id)
        (set-field! player this (send game get-game-object player-id)))
      
      (define/public (runTurn args)
        (printf "running turn~%")
        
        (if (> 6 (vector-length (get-field cowboys player)))
            (send (get-field young-gun player) call-in
                  (vector-ref (get-field jobs game) (random 3)))
            (printf "failed to call in~%"))
        
        (pretty-print (list "Cowboys" (get-field cowboys player)))
        
        (for ([cowboy (in-vector (get-field cowboys player))])
          (pretty-print (list "Cowboy " cowboy))
          (pretty-print (list "My name is " (send cowboy get-id)
                              (get-field job cowboy)))
          (pretty-print (map (lambda (field) (dynamic-get-field field cowboy))
                             (field-names cowboy)))
          
          (unless (get-field is-dead cowboy)
            (let* ([neighbors (send cowboy neighbors)]
                   [dir (random (vector-length neighbors))])
             (send cowboy move (vector-ref neighbors dir)))))
        
        (printf "ending turn~%")
        #t))))
