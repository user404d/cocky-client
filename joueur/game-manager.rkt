(module game-manager racket
  (require "base-game.rkt"
           "base-game-object.rkt"
           "serializer.rkt")
  (provide game-manager%)


  (define (camel-to-hyphen str)
    (regexp-replace* #px"[[:upper:]]" str (lambda (all)
                                                 (string-append "-" (string-downcase all)))))

  (define game-manager%
    (class object%
      (super-new)
      (init-field [game (new base-game%)])
      (define _constants '())
      (define _delta-removed '())
      (define _delta-list-len '())
      (define/public (set-constants constants)
        (begin
          (set! _constants constants)
          (set! _delta-removed (hash-ref constants 'DELTA_REMOVED))
          (set! _delta-list-len (hash-ref constants 'DELTA_LIST_LENGTH))))
      
      (define/public (apply-delta-state delta)
        (begin
          (cond [(hash-has-key? delta 'gameObjects)
                 (_init-game-objects (hash-ref delta 'gameObjects))])
          (_merge-delta game delta)))
      
      (define/private (_init-game-objects delta-game-objects)
        (hash-for-each delta-game-objects 
                       (lambda (k v)
                         (cond [(not (send game get-game-object k))
                                (send game set-game-object k 
                                      (hash-ref v 'gameObjectName))]))))
      (define/private (_merge-delta state delta)
        (begin
          (let ([delta-len (hash-ref delta _delta-list-len #f)])
            (cond [delta-len
                   (begin
                     (cond [(> delta-len -1)
                            (set! state (build-vector delta-len (lambda (i)
                                                                  (if (< i (vector-length state))
                                                                      (vector-ref state i)
                                                                      0))))])
                     (hash-remove! delta _delta-list-len))]))
          state)))))
