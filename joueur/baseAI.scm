(module baseAI (<BaseAI> init name game start gameUpdated invalid ended)
  (import chicken
          scheme
          extras) ;; needed for format (analagous to printf)
  (use ansiColorCoder ;;needed for ansi color coding output
       coops) ;; needed for objects w/ inheritance (similar to CLOS in common lisp)

  
  (define-class <BaseAI> ()
    ((game initform: '() accessor: game)
     (name initform: "Scheme Player" accessor: name)
     )
    )

  
  (define (init)
    (make <BaseAI>)
    )

  
  (define-method (start (instance <BaseAI>))
    (print "implement me!")
    )

  
  (define-method (gameUpdated (instance <BaseAI>))
    (print "implement me!")
    )

  
  (define-method (invalid (message #t) (instance <BaseAI>))
    (format (current-error-port)
            "~A~%"
            (string-append
             (ansi 'bold 'yellow 'default)
             "Invalid: "
             (ansi 'none 'default 'default)
             message
             )
            )
    )

  
  (define-method (ended (won #t) (reason #t) (instance <BaseAI>))
    (print "implement me!")
    )
  
  )
