;; from
;; http://karpathy.github.io/2015/05/21/rnn-effectiveness/

(defpackage :genchars
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :genchars)

(defparameter *data-lines* (read-lines-from "data/tinyshakespeare.txt"))
(defparameter *data* (format nil "~{~A~^~%~}" *data-lines*))
(defparameter *chars* (remove-duplicates (coerce *data* 'list)))
(defparameter *data-size* ($count *data*))
(defparameter *vocab-size* ($count *chars*))

(defparameter *char-to-idx* (let ((ht #{}))
                              (loop :for i :from 0 :below *vocab-size*
                                    :for ch = ($ *chars* i)
                                    :do (setf ($ ht ch) i))
                              ht))
(defparameter *idx-to-char* *chars*)

(defun choose (probs)
  (let* ((sprobs ($sum probs))
         (probs ($div probs sprobs)))
    ($ ($reshape! ($multinomial probs 1) ($count probs)) 0)))

;;
;; vanilla rnn
;;

(defparameter *hidden-size* 100)
(defparameter *sequence-length* 25)

(defparameter *rnn* (parameters))
(defparameter *wx* ($push *rnn* ($* 0.01 (rndn *vocab-size* *hidden-size*))))
(defparameter *wh* ($push *rnn* ($* 0.01 (rndn *hidden-size* *hidden-size*))))
(defparameter *wy* ($push *rnn* ($* 0.01 (rndn *hidden-size* *vocab-size*))))
(defparameter *bh* ($push *rnn* (zeros 1 *hidden-size*)))
(defparameter *by* ($push *rnn* (zeros 1 *vocab-size*)))

(defun sample (h seed-idx n &optional (temperature 1))
  (let ((x (zeros 1 *vocab-size*))
        (indices (list seed-idx))
        (ph h))
    (setf ($ x 0 seed-idx) 1)
    (loop :for i :from 0 :below n
          :for ht = ($tanh ($+ ($@ x *wx*) ($@ h *wh*) *bh*))
          :for yt = ($+ ($@ ht *wy*) *by*)
          :for ps = ($softmax ($/ yt temperature))
          :for nidx = (choose ($data ps))
          :do (progn
                (setf ph ht)
                (push nidx indices)
                ($zero! x)
                (setf ($ x 0 nidx) 1)))
    (coerce (mapcar (lambda (i) ($ *idx-to-char* i)) (reverse indices)) 'string)))

(defparameter *upto* (- *data-size* *sequence-length* 1))

(time
 (loop :for iter :from 1 :to 1
       :for n = 0
       :for upto = *upto*
       :do (loop :for p :from 0 :below upto :by *sequence-length*
                 :for input-str = (subseq *data* p (+ p *sequence-length*))
                 :for target-str = (subseq *data* (1+ p) (+ p *sequence-length* 1))
                 :for input = (let ((m (zeros *sequence-length* *vocab-size*)))
                                (loop :for i :from 0 :below *sequence-length*
                                      :for ch = ($ input-str i)
                                      :do (setf ($ m i ($ *char-to-idx* ch)) 1))
                                m)
                 :for target = (let ((m (zeros *sequence-length* *vocab-size*)))
                                 (loop :for i :from 0 :below *sequence-length*
                                       :for ch = ($ target-str i)
                                       :do (setf ($ m i ($ *char-to-idx* ch)) 1))
                                 m)
                 :do (let ((ph (zeros 1 *hidden-size*))
                           (losses nil)
                           (tloss 0))
                       (loop :for i :from 0 :below ($size input 0)
                             :for xt = ($index input 0 i)
                             :for ht = ($tanh ($+ ($@ xt *wx*) ($@ ph *wh*) *bh*))
                             :for yt = ($+ ($@ ht *wy*) *by*)
                             :for ps = ($softmax yt)
                             :for y = ($index target 0 i)
                             :for l = ($cee ps y)
                             :do (progn
                                   (setf ph ht)
                                   (incf tloss ($data l))
                                   (push l losses)))
                       ($adgd! *rnn*)
                       (when (zerop (rem n 100))
                         (prn "")
                         (prn "[ITER]" n (/ tloss (* 1.0 *sequence-length*)))
                         (prn (sample ($data ph) ($ *char-to-idx* ($ input-str 0)) 72))
                         (prn ""))
                       (incf n)))))

(prn (sample (zeros 1 *hidden-size*) (random *vocab-size*) 800 0.5))
