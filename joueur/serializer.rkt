(module serializer racket
  (require "base-game.rkt"
           "base-game-object.rkt")
  (provide is-game-obj-ref? is-obj? serialize deserialize)


  (define (is-game-obj-ref? d)
    (and (hash? d) (= (hash-count d) 1) (hash-has-key? d 'id)))
  
  (define (is-obj? obj)
    (or (hash? obj) (vector? obj) (subclass? obj base-game-object%)))
  
  (define (serialize data)
    (cond [(not (is-obj? data)) data]
          [(subclass? data base-game-object%) (make-hash `((id . ,(send data get-id))))]
          [else (let ([serialized (make-hash)])
                  (begin
                    (hash-for-each data (lambda (k v)
                                          (if (is-obj? v)
                                              (hash-set! serialized k (serialize v))
                                              (hash-set! serialized k v))))
                    serialized))]))

  (define (deserialize data game)
    (cond [(not (is-obj? data)) data]
          [(is-game-obj-ref? data) (send game get-game-object (hash-ref data 'id))]
          [else (let ([deserialized (if (hash? data) (make-hash) '())])
                  (begin
                    (if (hash? deserialized)
                        (hash-for-each data (lambda (k v)
                                              (if (is-obj? v)
                                                  (hash-set! deserialized k (deserialize v game))
                                                  (hash-set! deserialized k v))))
                        (set! deserialized (vector-map data (lambda (v)
                                                              (if (is-obj? v)
                                                                  (deserialize v game)
                                                                  v)))))
                    deserialized))])))

