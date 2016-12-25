#lang racket

(require "base-game.rkt"
         "base-game-object.rkt"
         "utilities.rkt")

(provide game-manager%)

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
      (merge-object game delta))


    (define/private (init-game-objects delta-game-objects)
      (hash-for-each delta-game-objects
                     (lambda (k v)
                       (let ([key (symbol->string k)])
                         (cond [(not (send game get-game-object key))
                                (send game set-game-object key
                                      (hash-ref v 'gameObjectName))])))))


    (define/private (merge-object state delta)
      (for ([(key value) delta])
        (define field-id (to-racket-field key))
        (:> field-id state (merge (<: field-id state) value)))
      ;; return mutated state
      state)


    (define/private (merge-vector state delta)
      (define length (hash-ref delta delta-list-len))
      (define state-length (vector-length state))
      ;; builds new vector up
      (for/vector #:length length
                  ([i (in-range length)])
                  (if (hash-has-key? delta (num-to-sym i))
                      ;; merge old state with delta
                      (let ([delta-elem (hash-ref delta (num-to-sym i))]
                            [state-elem (if (< i state-length)
                                            (vector-ref state i)
                                            null)])
                        (merge state-elem delta-elem))
                      ;; no delta to merge, keep old state
                      (vector-ref state i))))


    (define/private (merge-hash state delta)
      (for ([(key value) delta])
        (define str-key (symbol->string key))
        (hash-set! state str-key
                   (if (hash-has-key? state str-key)
                       ;; may need to merge
                       (let ([state-val (hash-ref state str-key)])
                         (merge state-val value))
                       ;; no state to merge
                       value)))
      ;; return mutated state
      state)


    (define/match (merge prev next)
      ;; game reference, inflate it
      [(_ (and (hash-table ('id id)) (app hash-count 1)))
       (send game get-game-object id)]
      ;; object description, apply changes to prev
      [((? object? _) (or (hash-table ('id _) (field value) ..1)
                          (hash-table (field value) ..1)))
       (merge-object prev next)]
      ;; vector, merge prev and next
      [((vector _ ...) (hash-table ('&LEN length)
                                   (index value) ...))
       (merge-vector prev next)]
      ;; hash, merge prev and next
      [((hash-table (_ _) ...) (hash-table (_ _) ..1))
       (merge-hash prev next)]
      ;; delete flag, return null
      [(_ '&RM) null]
      ;; primitive, discard prev; return next
      [(_ _) next])))
