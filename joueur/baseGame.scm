(module baseGame (<BaseGame> gameObjects getGameObject)
  (import chicken
          scheme)
  (use coops
       lookup-table)


  (define-class <BaseGame> ()
    ((gameObjects initform: (make-dict) accessor: gameObjects)
     (gameObjectClasses initform: (make-dict) accessor: gameObjectClasses))
    )


  (define-method (getGameObject (name #t) (instance <BaseGame>))
    (dict-ref (gameObjects instance) name)
    )
  
  )
