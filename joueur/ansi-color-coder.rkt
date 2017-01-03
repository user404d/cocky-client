#lang racket/base

(provide ansi reset)

;; TODO: Add support for MORE COLORS :D

(define modifiers
  (make-hash '((none . "00")
               (bold . "01")
               (underline . "04")
               (blink . "05")
               (inverse . "07")
               (hidden . "08"))))

(define colors
  (make-hash '((black . "30")
               (red . "31")
               (green . "32")
               (yellow . "33")
               (blue . "34")
               (magenta . "35")
               (cyan . "36")
               (white . "37")
               (default . "39"))))

(define background-colors
  (make-hash '((black . "40")
               (red . "41")
               (green . "42")
               (yellow . "43")
               (blue . "44")
               (magenta . "45")
               (cyan . "46")
               (white . "47")
               (default . "49"))))


(define (ansi #:mod        [mod 'none]
              #:text       [text 'default]
              #:background [background 'default])
  (string-append "\033["
                 (hash-ref modifiers mod) ";"
                 (hash-ref colors text) ";"
                 (hash-ref background-colors background) "m"))


(define reset (ansi))

