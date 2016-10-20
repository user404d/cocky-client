(module baseGameObject racket
  (provide base-game-object%)

  
  (define base-game-object%
    (class object%
      (init [id "0"])
      (super-new)
      (define _id id)
      (define/public (get-id)
        _id)))
  )
