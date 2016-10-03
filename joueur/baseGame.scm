(module baseGame (init gameObjects)
  (import chicken
          scheme)
  (use coops
       lookup-table)


  (define-class <BaseGame> ()
    ((gameObjects initform: (make-dict) accessor: gameObjects)
     (_gameObjectClasses initform: (make-dict)))
    )

  (define (init)
    (make <BaseGame>)
    )
  )
