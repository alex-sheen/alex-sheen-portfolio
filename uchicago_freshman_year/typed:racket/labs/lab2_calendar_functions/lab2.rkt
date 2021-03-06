#lang typed/racket
(require typed/test-engine/racket-tests)
(require "../include/cs151-core.rkt")
(require "../include/cs151-image.rkt")


(define-struct Date
  ([m : Integer]
   [d : Integer]
   [y : Integer]))

;; note: for the month, 1 means January, 2 means February, etc.

(define-type Day
  (U 'Su 'M 'Tu 'W 'Th 'F 'Sa))

;; leap?: compute whether or not a year is a leap year.
;; a year is a leap year if it is divisible by 4 and not divisible by 100
;; or if it is divisible by 400.
;; parameter "income": an integer number of years
;; output: boolean, whether the year is a gap year
(: leap? (-> Integer Boolean))
(define (leap? year)
   (cond
     [(= 0 (modulo year 400)) #t]
     [(and (= 0 (modulo year 4)) (not (= 0 (modulo year 100)))) #t]
     [else #f]
   )
)
(check-expect (leap? 3) #f)
(check-expect (leap? 16) #t)
(check-expect (leap? 400) #t)
(check-expect (leap? 200) #f)


;; smart-date?: considers whether a date is reasonable
;; parameters : month, day, and year
;; output : error or the given date
(: smart-date (Integer Integer Integer -> Date))
(define (smart-date m d y)
  (cond
    [(or (< m 1) (> m 12)) (error "month out of range")]
    [(or (< y 1900) (> y 2099)) (error "year out of range")]
    [(and (= m 1) (or (< d 1) (> d 31))) (error "day out of range")]
    ;; if Feb and leap year
    [(and (= m 2) (leap? y) (or (< d 1) (> d 29))) (error "day out of range")]
    ;; if Feb and not leap year
    [(and (= m 2) (or (< d 1) (> d 28))) (error "day out of range")]
    [(and (= m 3) (or (< d 1) (> d 31))) (error "day out of range")]
    [(and (= m 4) (or (< d 1) (> d 30))) (error "day out of range")]
    [(and (= m 5) (or (< d 1) (> d 31))) (error "day out of range")]
    [(and (= m 6) (or (< d 1) (> d 30))) (error "day out of range")]
    [(and (= m 7) (or (< d 1) (> d 31))) (error "day out of range")]
    [(and (= m 8) (or (< d 1) (> d 31))) (error "day out of range")]
    [(and (= m 9) (or (< d 1) (> d 30))) (error "day out of range")]
    [(and (= m 10) (or (< d 1) (> d 31))) (error "day out of range")]
    [(and (= m 11) (or (< d 1) (> d 30))) (error "day out of range")]
    [(and (= m 12) (or (< d 1) (> d 31))) (error "day out of range")]
    
    [else (Date m d y)]
   )
)
(check-error (smart-date 99 2 2019) "month out of range")
(check-error (smart-date -10 2 2019) "month out of range")
(check-error (smart-date 10 2 1890) "year out of range")
(check-error (smart-date 10 2 2200) "year out of range")
(check-error (smart-date 10 49 2019) "day out of range")
(check-error (smart-date 10 -2 2019) "day out of range")
(check-expect (smart-date 4 2 2019) (Date 4 2 2019))


;; date=?: considers whether two dates are exactly the same
;; parameters : date1 and date2
;; output : boolean, whether the dates are the same
(: date=? (Date Date -> Boolean))
(define (date=? date1 date2)
  (match* (date1 date2)
    [((Date m1 d1 y1) (Date m2 d2 y2))
     (and (= m1 m2) (= d1 d2) (= y1 y2))]
  )
)
(check-expect (date=? (Date 1 1 2001) (Date 1 1 2001)) #t)
(check-expect (date=? (Date 1 1 2001) (Date 1 2 2001)) #f)
(check-expect (date=? (Date 1 1 2001) (Date 2 1 2001)) #f)
(check-expect (date=? (Date 1 1 2001) (Date 1 2 2002)) #f)

;; date<?: considers if the first date occurs before the other
;; parameters : date1 and date2
;; output : boolean, whether date1 occurs before date2
(: date<? (Date Date -> Boolean))
(define (date<? date1 date2)
  (match* (date1 date2)
    [((Date m1 d1 y1) (Date m2 d2 y2))
     (cond
       [(> y2 y1) #f]
       [(and (= y1 y2) (> m2 m1)) #f]
       [(and (= y1 y2) (= m2 m1) (> d2 d1)) #f]
       [(date=? date1 date2) #f]
       [else #t]
      )]
  )
)
(check-expect (date<? (Date 1 1 2001) (Date 1 1 2001)) #f)
(check-expect (date<? (Date 1 1 2001) (Date 1 1 2002)) #f)
(check-expect (date<? (Date 1 1 2001) (Date 2 1 2001)) #f)
(check-expect (date<? (Date 1 1 2001) (Date 1 2 2002)) #f)
(check-expect (date<? (Date 1 2 2001) (Date 1 1 2001)) #t)

;; day-of-week: computes day of the week from a given date
;; parameter: a date
;; output: a day of the week
(: day-of-week (Date -> Day))
(define (day-of-week date)
 (local
    {
     (define (compute-n date) (match date ;; returns the n value of a date
                         [(Date m d y)
                         (+ (- y 1900) (compute-j date) d (exact-floor (/ y 4)))]
                           ))
     (define (compute-j date) (match date ;; returns the j of a month
                         [(Date 1 _ y) (cond
                              [(leap? y) 0]
                              [else 1]
                              )]
                         
                         [(Date 2 _ y) (cond
                              [(leap? y) 3]
                              [else 4]
                              )]
                         
                         [(Date 3 _ _) 4]
                         [(Date 4 _ _) 0]
                         [(Date 5 _ _) 2]
                         [(Date 6 _ _) 5]
                         [(Date 7 _ _) 0]
                         [(Date 8 _ _) 3]
                         [(Date 9 _ _) 6]
                         [(Date 10 _ _) 1]
                         [(Date 11 _ _) 4]
                         [(Date 12 _ _) 6]
                         [else (error "month out of range")]
                         ))
     ;; returns the remainder of 1 / n for a given date
     (define (compute-day-number date) (remainder (compute-n date) 7 ))
     ;; takes the remainder of 1 / n and turns it into a Day
     (define (number-to-day num) (match num
                                 [0 'Su]
                                 [1 'M]
                                 [2 'Tu]
                                 [3 'W]
                                 [4 'Th]
                                 [5 'F]
                                 [6 'Sa]
                                ))
    }
    
    (number-to-day (compute-day-number date)) ;; returns the Day
  ) 
)
(check-expect (day-of-week (Date 1 1 2019)) 'Tu)
(check-expect (day-of-week (Date 2 18 2002)) 'M)
(check-expect (day-of-week (Date 3 3 2009)) 'Tu)
(check-expect (day-of-week (Date 4 4 2031)) 'F)
(check-expect (day-of-week (Date 5 11 2080)) 'Sa)
(check-expect (day-of-week (Date 6 24 2001)) 'Su)
(check-expect (day-of-week (Date 7 27 2061)) 'W)
(check-expect (day-of-week (Date 8 7 2099)) 'F)
(check-expect (day-of-week (Date 9 29 2034)) 'F)
(check-expect (day-of-week (Date 10 18 2040)) 'Th)
(check-expect (day-of-week (Date 11 19 2087)) 'W)
(check-expect (day-of-week (Date 12 9 2077)) 'Th)

;; yesterday: computes day before a given date
;; parameter: a Date
;; output: the Date before
(: yesterday (Date -> Date))
(define (yesterday date)
 (match date
   [(Date m d y)
    (cond
       
       [(and (= m 1) (= d 1)) (Date 12 31 (- y 1))] 
       [(and (= m 2) (= d 1)) (Date (- m 1) 31 y)]
       [(and (= m 3) (= d 1) (leap? y)) (Date (- m 1) 29 y)] ;; if it is a leap year
       [(and (= m 3) (= d 1)) (Date (- m 1) 28 y)]    ;; if it is not a leap year 31
       [(and (= m 4) (= d 1)) (Date (- m 1) 31 y)] 
       [(and (= m 5) (= d 1)) (Date (- m 1) 30 y)] 
       [(and (= m 6) (= d 1)) (Date (- m 1) 31 y)] 
       [(and (= m 7) (= d 1)) (Date (- m 1) 30 y)] 
       [(and (= m 8) (= d 1)) (Date (- m 1) 31 y)] 
       [(and (= m 9) (= d 1)) (Date (- m 1) 31 y)] 
       [(and (= m 10) (= d 1)) (Date (- m 1) 30 y)] 
       [(and (= m 11) (= d 1)) (Date (- m 1) 31 y)] 
       [(and (= m 12) (= d 1) (Date (- m 1) 30 y))]
       [else (Date m (- d 1) y)]
     )]
  )
)
(check-expect (yesterday (Date 12 9 2077)) (Date 12 8 2077))
(check-expect (yesterday (Date 1 1 2077)) (Date 12 31 2076))
(check-expect (yesterday (Date 5 1 2077)) (Date 4 30 2077))
(check-expect (yesterday (Date 3 1 2077)) (Date 2 28 2077))
(check-expect (yesterday (Date 3 1 2004)) (Date 2 29 2004))

;; tomorrow computes day after a given date
;; parameter: a Date
;; output: the Date befafterore
(: tomorrow (Date -> Date))
(define (tomorrow date)
 (match date
   [(Date m d y)
    (cond
       
       [(and (= m 1) (= d 31)) (Date (+ m 1) 1 y)] 
       [(and (= m 2) (leap? y) (= d 29)) (Date (+ m 1) 1 y)] ;; if it is a leap year
       [(and (= m 2) (= d 28)) (Date (+ m 1) 1 y)]       ;; if it is not a leap year
       [(and (= m 3) (= d 31)) (Date (+ m 1) 1 y)]          
       [(and (= m 4) (= d 30)) (Date (+ m 1) 1 y)] 
       [(and (= m 5) (= d 31)) (Date (+ m 1) 1 y)] 
       [(and (= m 6) (= d 30)) (Date (+ m 1) 1 y)] 
       [(and (= m 7) (= d 31)) (Date (+ m 1) 1 y)] 
       [(and (= m 8) (= d 31)) (Date (+ m 1) 1 y)] 
       [(and (= m 9) (= d 30)) (Date (+ m 1) 1 y)] 
       [(and (= m 10) (= d 31)) (Date (+ m 1) 1 y)] 
       [(and (= m 11) (= d 30)) (Date (+ m 1) 1 y)] 
       [(and (= m 12) (= d 31) (Date 1 1 (+ y 1)))]
       [else (Date m (+ d 1) y)]
     )]
  )
)
(check-expect (tomorrow (Date 12 9 2077)) (Date 12 10 2077))
(check-expect (tomorrow (Date 1 31 2077)) (Date 2 1 2077))
(check-expect (tomorrow (Date 5 31 2077)) (Date 6 1 2077))
(check-expect (tomorrow (Date 2 28 2077)) (Date 3 1 2077))
(check-expect (tomorrow (Date 2 29 2004)) (Date 3 1 2004))
(check-expect (tomorrow (Date 12 31 2004)) (Date 1 1 2005))

(: add-days (Integer Date -> Date))
(define (add-days num date)
  (match* (num date)
    [(0 (Date m d y)) (Date m d y)]
    [(num (Date m d y)) (cond
                          [(> num 0) (add-days (- num 1) (tomorrow (Date m d y)))]
                          [else (add-days (+ num 1) (yesterday (Date m d y)))]
                          )]
  )
)
(check-expect (add-days 1 (Date 12 31 2004)) (Date 1 1 2005))
(check-expect (add-days 5 (Date 12 1 2004)) (Date 12 6 2004))
(check-expect (add-days 5 (Date 12 30 2004)) (Date 1 4 2005))
(check-expect (add-days -5 (Date 12 30 2004)) (Date 12 25 2004))

(test)