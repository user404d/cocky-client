#lang racket/base

(require "base-game.rkt"
         "base-game-object.rkt"
         (only-in racket/class
                  is-a?
                  send)
         "utilities.rkt")

(provide serialize deserialize)


(define (serialize data)
  (cond [(not (or (vector? data) (is-obj? data))) data]
        [(is-a? data base-game-object%) (make-hash `((id . ,(send data get-id))))]
        [else (define seq
                (if (hash? data)
                    (in-hash data)
                    (in-parallel (in-naturals) (in-vector data))))
              (for/hash ([(key value) seq])
                (if (is-obj? value)
                    (values key (serialize value))
                    (values key value)))]))


(define (produce-hash data game)
  (for/hash ([(key value) (in-hash data)])
    (if (or (vector? value) (is-obj? value))
        (values key (deserialize value game))
        (values key value))))


(define (produce-vector data game)
  (for/vector #:length (vector-length data)
              ([value (in-vector data)])
              (if (or (vector? value) (is-obj? value))
                  (deserialize value game)
                  value)))


(define (deserialize data game)
  (cond [(not (or (vector? data) (is-obj? data))) data]
        [(is-game-obj-ref? data) (send game get-game-object (hash-ref data 'id))]
        [else (if (hash? data)
                  (produce-hash data game)
                  (produce-vector data game))]))
