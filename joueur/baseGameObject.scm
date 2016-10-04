(module baseGameObject (<BaseGameObject> id)
  (import chicken
          scheme)
  (use coops)

  
  (define-class <BaseGameObject> ()
    ((id initform: 0 accessor: id))
    )
  )
