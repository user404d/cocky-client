#lang racket/base

(require (only-in racket/class
                  dynamic-get-field
                  dynamic-set-field!
                  is-a?
                  object%))

(provide (all-defined-out))


;; Helper Functions

(define (is-game-obj-ref? d)
  (and (hash? d) (= (hash-count d) 1) (hash-has-key? d 'id)))


(define (is-obj? obj)
  (or (hash? obj) (is-a? obj object%)))


(define (camel-to-hyphen str)
  (regexp-replace* #px"[[:upper:]]"
                   str (lambda (any) (string-append "-" (string-downcase any)))))


(define (num-to-sym num)
  (string->symbol (number->string num)))


(define (to-racket-field field-name)
  (string->symbol (camel-to-hyphen (symbol->string field-name))))


(define-syntax-rule (:> field-id state value)
  (dynamic-set-field! field-id state value))


(define-syntax-rule (<: field-id state)
  (dynamic-get-field field-id state))
