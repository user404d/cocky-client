(module ansiColorCoder (background style text reset)
  (import chicken scheme)
  (use lookup-table)
  (define _style
    (alist->dict '((none 0)
                   (bold 1)
                   (underline 4)
                   (blink 5)
                   (inverse 7)
                   (hidden 8)))
    )

  (define _text
    (alist->dict '((black 30)
                   (red 31)
                   (green 32)
                   (yellow 33)
                   (blue 34)
                   (magenta 35)
                   (cyan 36)
                   (white 37)
                   ("default" 39)))
    )

  (define _background
    (alist->dict '((black 40)
                   (red 41)
                   (green 42)
                   (yellow 43)
                   (blue 44)
                   (magenta 45)
                   (cyan 46)
                   (white 47)
                   ("default" 49)))
    )
  
  (define (ansi num)
    (let ((_num (string (integer->char (if (null? num)
                                           0
                                           num)))))
      (string-append "\x27" "[" _num "m"))
    )

  (define (style key)
    (let ((val (dict-ref _style key)))
      (if val
          (ansi (car val))
          (ansi 0)))
    )

  (define (text key)
    (let ((val (dict-ref _text key)))
      (if val
          (ansi (car val))
          (ansi 0)))
    )

  (define (background key)
    (let ((val (dict-ref  _background key)))
      (if val
          (ansi (car val))
          (ansi 0)))
    )

  (define (_reset)
    (ansi 0)
    )
  )

