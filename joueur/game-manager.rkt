(module game-manager racket
  (require "base-game.rkt"
           "base-game-object.rkt"
           "serializer.rkt")
  (provide game-manager%)


  (define (camel-to-hyphen str)
    (regexp-replace* #px"[[:upper:]]"
                     str (lambda (all) (string-append "-" (string-downcase all)))))

  (define (num-to-sym num)
    (string->symbol (number->string num)))

  (define (mergeable? state)
    (or (is-a? state base-game%) (is-a? state base-game-object%)))

  (define (is-field? state field-name)
    (findf (lambda (field) (eq? field field-name)) (field-names state)))

  (define (vec-key-update state key)
    (values key (< key (vector-length state))))

  (define (mergeable-key-update state key)
    (let ([state-key (string->symbol (camel-to-hyphen (symbol->string key)))])
      (values state-key (and (not (null? state)) (is-field? state state-key)))))

  (define (hash-key-update state key)
    (let ([state-key (symbol->string key)])
      (values state-key (hash-has-key? state state-key))))

  (define (state-ref state state-key)
    (cond [(vector? state) (vector-ref state state-key)]
          [(mergeable? state) (dynamic-get-field state-key state)]
          [else (hash-ref state state-key)]))

  (define (state-set! state state-key value)
    (cond [(vector? state) (vector-set! state state-key value)]
          [(mergeable? state) (dynamic-set-field! state-key state value)]
          [else (if (immutable? state)
                    (hash-set state state-key value)
                    (hash-set! state state-key value))]))

  (define game-manager%
    (class object%
      (super-new)
      (init-field [game (new base-game%)])
      (field [constants null]
             [delta-removed null]
             [delta-list-len null])

      (define/public (set-constants constants)
        (define delta-list-len-sym (string->symbol (hash-ref constants 'DELTA_LIST_LENGTH)))
        (set-field! constants this constants)
        (set-field! delta-removed this (hash-ref constants 'DELTA_REMOVED))
        (set-field! delta-list-len this delta-list-len-sym))
      
      (define/public (apply-delta-state delta)
        (cond [(hash-has-key? delta 'gameObjects)
               (init-game-objects (hash-ref delta 'gameObjects))])
        (merge-delta game delta mergeable-key-update))
      
      (define/private (init-game-objects delta-game-objects)
        (hash-for-each delta-game-objects
                       (lambda (k v)
                         (let ([key (symbol->string k)])
                           (cond [(not (send game get-game-object key))
                                  (send game set-game-object key
                                        (hash-ref v 'gameObjectName))])))))

      ;; TODO: Implement this in a NICE way
      (define/private (merge-delta state delta)))))
