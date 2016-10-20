(module game-manager racket
  (require "base-game.rkt"
           "base-game-object.rkt"
           "serializer.rkt")
  (provide game-manager%)


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
          (set! _delta-removed (hash-ref constants "DELTA_REMOVED"))
          (set! _delta-list-len (hash-ref constants "DELTA_LIST_LENGTH"))))
      (define/public (apply-delta-state delta)
        (begin
          (cond [(hash-has-key? delta "gameObjects")
                 (send this init-game-objects (hash-ref delta "gameObjects"))])
          (send this _merge-delta delta)))
      (define/private (_init-game-objects delta-game-objects)
        (hash-for-each delta-game-objects 
                       (lambda (k v)
                         (cond [(not (send game get-game-object k))
                                (send game set-game-object k 
                                      (hash-ref delta-game-objects "gameObjectName"))]))))
      (define/private (_merge-delta state delta)
        (begin
          (let ([delta-len (hash-ref delta _delta-list-len)])
            (cond [delta-len
                   (begin
                     (cond [(> delta-len -1)
                            (set! state (build-vector delta-len (lambda (i)
                                                                  (if (< i (vector-length state))
                                                                      (vector-ref state i)
                                                                      0))))])
                     (hash-remove! delta _delta-list-len))])
            )
          (hash-for-each delta (lambda (k v)
                                 (let* ([state-key (if (vector? state)
                                                       (string->number k)
                                                       k)]
                                        [key-in-state (cond [(number? state-key)
                                                             (< state-key (vector-length state))]
                                                            [(string? state-key) (hash-has-key? state state-key)]
                                                            [else #f])]
                                        [state-update (if (hash? state) hash-set! vector-set!)]
                                        [state-access (if (hash? state) hash-ref vector-ref)])
                                   (cond [(and (string=? v _delta-removed) key-in-state)
                                          (hash-remove! state state-key)]
                                         [(is-game-obj-ref? v)
                                          (state-update state state-key (send game get-game-object (hash-ref v "id")))]
                                         [(and (is-obj? v) key-in-state (is-obj? (state-access state state-key)))
                                          (send this _merge-delta (state-access state state-key) v)]
                                         [(and (not key-in-state) (hash? v))
                                          (if (hash-has-key? v _delta-list-len)
                                              (state-update state state-key (send this _merge-delta (make-hash) v))
                                              (state-update state state-key (send this _merge-delta (vector) v)))]
                                         [else
                                          (state-update state state-key v)]
                                         ))))
          state))))
  )
