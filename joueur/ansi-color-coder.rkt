(module ansiColorCoder racket
  (provide ansi)

  (define _style
    (make-hash '((none . "00")
                 (bold . "01")
                 (underline . "04")
                 (blink . "05")
                 (inverse . "07")
                 (hidden . "08"))))

  (define _text
    (make-hash '((black . "30")
                 (red . "31")
                 (green . "32")
                 (yellow . "33")
                 (blue . "34")
                 (magenta . "35")
                 (cyan . "36")
                 (white . "37")
                 (default . "39"))))

  (define _background
    (make-hash '((black . "40")
                 (red . "41")
                 (green . "42")
                 (yellow . "43")
                 (blue . "44")
                 (magenta . "45")
                 (cyan . "46")
                 (white . "47")
                 (default . "49"))))
  
  (define (find-style key)
    (let ((val (hash-ref _style key #f)))
      (if val
          val
          (hash-ref _style 'none))))

  (define (find-text key)
    (let ((val (hash-ref _text key #f)))
      (if val
          val
          (hash-ref _text 'default))))

  (define (find-background key)
    (let ((val (hash-ref  _background key #f)))
      (if val
          val
          (hash-ref _background 'default))))

  (define (ansi style text background)
    (string-append "\033["
                   (find-style style) ";"
                   (find-text text) ";"
                   (find-background background) "m")))

