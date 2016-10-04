(module serializer (Serializer Serializer? empty? empty-except-for)
  (import chicken
          scheme)
  (use baseGameObject
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
  
  
  (define SERIALIZER (make-rtd 'serializer
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
                                   (and (not (null? obj))
                                        (vector? obj)
                                        (= (vector-length obj) 1)
                                        (string= (car (vector-ref obj 0)) key))
                                   )
                                 )
                               #:property game-ref?
                               (lambda (rt)
                                 (lambda (obj)
                                   0
                                   )
                                 )
                               #:property obj?
                               (lambda (rt)
                                 (lambda (obj)
                                   0
                                   )
                                 )
                               #:property serial?
                               (lambda (rt)
                                 (lambda (obj key)
                                   0
                                   )
                                 )
                               #:property serialize
                               (lambda (rt)
                                 (lambda (data)
                                   0
                                   )
                                 )
                               #:property deserialize
                               (lambda (rt)
                                 (lambda (data game)
                                   0
                                   )
                                 )
                               ))


  (define Serializer (rtd-constructor SERIALIZER))
  (define Serializer? (rtd-predicate SERIALIZER))
  )
