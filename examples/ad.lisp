(defpackage th.ad-example
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :th.ad-example)

;; broadcast
(let* ((x ($variable 5))
       (y ($constant (tensor '(1 2 3))))
       (out ($broadcast x y)))
  (setf (th::$gradientv out) (tensor '(1 2 3)))
  (prn ($gradient x))
  (prn ($gradient y)))

(let ((out ($broadcast ($variable 5) ($constant '(1 2 3)))))
  ($bp! out (tensor '(1 2 3)))
  (loop :for c :in ($children out)
        :do (print ($gradient c))))

;; add
(let* ((a ($variable (tensor '(1 1 1))))
       (b ($variable (tensor '(1 1 1))))
       (out ($add a b)))
  ($bp! out (tensor '(1 2 3)))
  (loop :for c :in ($children out)
        :do (print ($gradient c))))

(let* ((a ($variable '(1 1 1)))
       (b ($variable '(1 1 1)))
       (out ($+ a b)))
  ($bp! out (tensor '(1 2 3)))
  (loop :for c :in ($children out)
        :do (print ($gradient c))))

;; sub
(let ((out ($sub ($constant (tensor '(1 2 3))) ($variable (tensor '(3 2 1))))))
  ($bp! out (tensor '(1 1 1)))
  (loop :for c :in ($children out)
        :do (print ($gradient c))))

(let ((out ($- ($constant '(1 2 3)) ($variable '(3 2 1)))))
  ($bp! out (tensor '(1 1 1)))
  (loop :for c :in ($children out)
        :do (print ($gradient c))))

;; dot
(let* ((x ($variable (tensor '(1 2 3))))
       (y ($variable (tensor '(1 2 3))))
       (out ($dot x y)))
  (setf (th::$gradientv out) 2)
  (prn ($gradient x)))

(let* ((x (tensor '(1 2 3)))
       (out ($dot ($variable x) ($constant x))))
  ($bp! out 2)
  (loop :for c :in ($children out)
        :do (print ($gradient c))))

;; update
(let* ((a ($constant (tensor '(1 1 1))))
       (b ($variable (tensor '(1 2 3))))
       (out ($dot a b)))
  ($bp! out 1)
  (print out)
  (print ($gd! out))
  (print b))

(let* ((a ($constant '(1 1 1)))
       (b ($variable '(1 2 3)))
       (out ($@ a b)))
  ($bp! out 1)
  (print out)
  (print ($gd! out))
  (print b))

;; linear mapping
(let* ((X ($constant (tensor '((1) (3)))))
       (Y ($constant (tensor '(-10 -30))))
       (c ($variable 0))
       (b ($variable (tensor '(10)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d)))
              ($bp! out 1)
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! out)))
  (print b))

(let* ((X ($constant '((1) (3))))
       (Y ($constant '(-10 -30)))
       (c ($variable 0))
       (b ($variable '(10))))
  (loop :for i :from 0 :below 2000
        :do (let* ((d ($- ($+ ($@ X b) ($broadcast c Y)) Y))
                   (out ($@ d d)))
              ($bp! out 1)
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! out)))
  (print b))

(let* ((X ($constant (-> (range 0 10)
                        ($transpose!))))
       (Y ($constant (range 0 10)))
       (c ($variable 0))
       (b ($variable (tensor '(0)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((Y* ($add ($mv X b) ($broadcast c Y)))
                   (d ($sub Y* Y))
                   (out ($dot d d)))
              ($bp! out 1)
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! out 0.001)))
  (print b))

(let* ((X ($constant (-> (range 0 10)
                        ($transpose!))))
       (Y ($constant (range 0 10)))
       (c ($variable 0))
       (b ($variable (tensor '(0)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((Y* ($+ ($@ X b) ($broadcast c Y)))
                   (d ($- Y* Y))
                   (out ($@ d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! out 0.001)))
  (print b))

(let* ((X ($constant (-> (tensor '((1 1 2)
                                  (1 3 1)))
                        ($transpose!))))
       (Y ($constant (tensor '(1 2 3))))
       (c ($variable 0))
       (b ($variable (tensor '(1 1)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! out 0.05)))
  (print b)
  (print c))

(let* ((X ($constant (-> (tensor '((1 1 2)
                                  (1 3 1)))
                        ($transpose!))))
       (Y ($constant (tensor '(1 2 3))))
       (c ($variable 0))
       (b ($variable (tensor '(1 1)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($- ($+ ($@ X b) ($broadcast c Y)) Y))
                   (out ($@ d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! out 0.05)))
  (print b)
  (print c))

;; regressions
(let* ((X ($constant (-> (tensor '(1 3))
                        ($transpose!))))
       (Y ($constant (tensor '(-10 -30))))
       (c ($variable 0))
       (b ($variable (tensor '(10)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 0.02)))
  (print ($add ($mv X b) ($broadcast c Y))))

(let* ((X ($constant (-> (tensor '(1 3))
                        ($transpose!))))
       (Y ($constant (tensor '(-10 -30))))
       (c ($variable 0))
       (b ($variable (tensor '(10)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($- ($+ ($@ X b) ($broadcast c Y)) Y))
                   (out ($@ d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 0.02)))
  (print ($+ ($@ X b) ($broadcast c Y))))

(let* ((X ($constant (tensor '((5 2) (-1 0) (5 2)))))
       (Y ($constant (tensor '(1 0 1))))
       (c ($variable 0))
       (b ($variable (tensor '(0 0)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((Y* ($sigmoid ($add ($mv X b) ($broadcast c Y))))
                   (out ($bce Y* Y)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 0.1)))
  (print ($sigmoid ($add ($mv X b) ($broadcast c Y)))))

;; xor
(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($sigmoid ($mm X w1)))
                   (l2 ($sigmoid ($mm l1 w2)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 1.0)))
  (print w1)
  (print w2)
  (print (let* ((l1 ($sigmoid ($mm X w1)))
                (l2 ($sigmoid ($mm l1 w2))))
           l2)))

(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (b1 ($variable (zeros 3)))
       (b2 ($variable (ones 1)))
       (o1 ($constant (ones 4)))
       (o2 ($constant (ones 4)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((xw1 ($mm X w1))
                   (xwb1 ($add xw1 ($vv o1 b1)))
                   (l1 ($sigmoid xwb1))
                   (lw2 ($mm l1 w2))
                   (lwb2 ($add lw2 ($vv o2 b2)))
                   (l2 ($sigmoid lwb2))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 1)))
  (print w1)
  (print b1)
  (print w2)
  (print (let* ((l1 ($sigmoid ($add ($mm X w1) ($vv o1 b1))))
                (l2 ($sigmoid ($add ($mm l1 w2) ($vv o2 b2)))))
           l2)))

(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (b1 ($variable (ones 3)))
       (b2 ($variable (ones 1)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($sigmoid ($xwpb X w1 b1)))
                   (l2 ($sigmoid ($xwpb l1 w2 b2)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 5)))
  (print (let* ((l1 ($sigmoid ($xwpb X w1 b1)))
                (l2 ($sigmoid ($xwpb l1 w2 b2))))
           l2)))

(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($tanh ($mm X w1)))
                   (l2 ($sigmoid ($mm l1 w2)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 1.0)))
  (print (let* ((l1 ($tanh ($mm X w1)))
                (l2 ($sigmoid ($mm l1 w2))))
           l2)))

(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (b1 ($variable (ones 3)))
       (b2 ($variable (ones 1)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($tanh ($xwpb X w1 b1)))
                   (l2 ($sigmoid ($xwpb l1 w2 b2)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 1.0)))
  (print (let* ((l1 ($tanh ($xwpb X w1 b1)))
                (l2 ($sigmoid ($xwpb l1 w2 b2))))
           l2)))

(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (b1 ($variable (ones 3)))
       (b2 ($variable (ones 1)))
       (o1 ($constant (ones 4)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($tanh ($xwpb X w1 b1 o1)))
                   (l2 ($sigmoid ($xwpb l1 w2 b2 o1)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! out 0.2)))
  (print (let* ((l1 ($tanh ($xwpb X w1 b1)))
                (l2 ($sigmoid ($xwpb l1 w2 b2))))
           l2)))

;; momentum
(let* ((w1 ($variable (rndn 2 3)))
       (w2 ($variable (rndn 3 1)))
       (b1 ($variable (ones 3)))
       (b2 ($variable (ones 1)))
       (o1 ($constant (ones 4)))
       (X ($constant '((0 0) (0 1) (1 0) (1 1))))
       (Y ($constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($tanh ($xwpb X w1 b1 o1)))
                   (l2 ($sigmoid ($xwpb l1 w2 b2 o1)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              (when (zerop (mod i 100)) (print ($data out)))
              ($mgd! out 0.2)))
  (print (let* ((l1 ($tanh ($xwpb X w1 b1)))
                (l2 ($sigmoid ($xwpb l1 w2 b2))))
           l2)))

(defun fwd (input weight) ($sigmoid! ($@ input weight)))
(defun dwb (delta output) ($* delta output ($- 1 output)))

(let* ((X (tensor '((0 0 1) (0 1 1) (1 0 1) (1 1 1))))
       (Y (tensor '((0) (1) (1) (0))))
       (w1 (rndn 3 3))
       (w2 (rndn 3 1))
       (lr 1))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 (fwd X w1))
                   (l2 (fwd l1 w2))
                   (l2d (dwb ($- l2 y) l2))
                   (l1d (dwb ($@ l2d ($transpose w2)) l1))
                   (dw2 ($@ ($transpose l1) l2d))
                   (dw1 ($@ ($transpose X) l1d)))
              ($sub! w1 ($* lr dw1))
              ($sub! w2 ($* lr dw2))))
  (print (fwd (fwd X w1) w2)))

(let* ((w1 ($variable (rndn 3 3)))
       (w2 ($variable (rndn 3 1)))
       (X ($constant '((0 0 1) (0 1 1) (1 0 1) (1 1 1))))
       (Y ($constant '(0 1 1 0)))
       (lr 1))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($sigmoid ($mm X w1)))
                   (l2 ($sigmoid ($mm l1 w2)))
                   (d ($sub l2 Y))
                   (out ($dot d d)))
              ($bp! out)
              ($gd! out lr)))
  (print ($sigmoid ($mm ($sigmoid ($mm X w1)) w2))))
