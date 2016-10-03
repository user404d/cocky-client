(module client (<Client> disconnect)
  (import chicken
          scheme)
  (use coops)


  (define-class <Client> ()
    ((disconnect initform: (lambda (x) 0) reader: disconnect))
    )
  )
