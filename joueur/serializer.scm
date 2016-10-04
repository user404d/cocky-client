(module serializer (Serializer Serializer? empty? empty-except-for game-ref?
                               obj? serial? serialize deserialize)
  (import chicken
          scheme)
  (use baseGame
       baseGameObject
       (only coops subclass? class-of <standard-object>)
       json
       (only srfi-13 string=)
       srfi-99
       srfi-133)


  (define-record-property empty?)
  (define-record-property empty-except-for)
  (define-record-property game-ref?)
  (define-record-property obj?)
  (define-record-property serial?)
  (define-record-property serialize)
  (define-record-property deserialize)
  
  
  (define SERIALIZER
    (make-rtd 'serializer
              '#()
              #:property empty?
              (lambda (rt)
                (lambda (obj)
                  (and (not (null? obj)) (vector? obj) (vector-empty? obj))
                  )
                )
              #:property empty-except-for
              (lambda (rt)
                (lambda (obj key)
                  (and ((obj? rt) obj)
                       (= (vector-length obj) 1)
                       (string= (car (vector-ref obj 0)) key))
                  )
                )
              #:property game-ref?
              (lambda (rt)
                (lambda (obj)
                  ((empty-except-for rt) obj "id")
                  )
                )
              #:property obj?
              (lambda (rt)
                (lambda (obj)
                  (and (not (null? obj)) (subclass? (class-of obj) <standard-object>))
                  )
                )
              #:property serial?
              (lambda (rt)
                (lambda (obj key)
                  (and ((obj? rt) obj)
                       (number? (vector-index (lambda (x) (string= (car x) key)) obj))
                       (not (string= key "_" 0 0 0 0)))
                  )
                )
              #:property serialize
              ;; potentially don't use vectors as serialization container
              ;; fix return value of lone (key value) pair. breaking deserialization
              (lambda (rt)
                (lambda (data)
                  (if (not ((obj? rt) data))
                      data
                      (if (and (not (null? data)) (subclass? (class-of data) <BaseGameObject>))
                          `("id" ,(id data))
                          (vector-unfold (lambda (i)
                                           (let* ((elem (vector-ref data i))
                                                  (key (car elem))
                                                  (datum ((serialize rt) (cdr elem))))
                                             (cons key datum)))
                                         (vector-length data))))
                  )
                )
              #:property deserialize
              ;; potentially don't use vectors as serialization container
              (lambda (rt)
                (lambda (data game)
                  (if ((obj? rt) data)
                      (vector-unfold (lambda (i)
                                       (let* ((elem (vector-ref data i))
                                              (key (car elem))
                                              (datum (cdr elem)))
                                         (if (subclass? (class-of datum) <standard-object>)
                                             (if ((game-ref? rt) datum)
                                                 `(,key ,((getGameObject game) (cdr (vector-ref datum 0))))
                                                 `(,key ,((deserialize rt) datum)))
                                             `(,key ,datum)))
                                       ))
                      data)
                  )
                )
              )
    )


  (define Serializer (rtd-constructor SERIALIZER))
  (define Serializer? (rtd-predicate SERIALIZER))
  )
