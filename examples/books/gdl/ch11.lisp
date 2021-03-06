(ql:quickload :cl-ppcre)

(defpackage :gdl-ch11
  (:use #:common-lisp
        #:mu
        #:th
        #:th.db.imdb))

(in-package :gdl-ch11)

;; onehots
(defparameter *onehots* #{})

(setf ($ *onehots* "cat") (tensor '(1 0 0 0)))
(setf ($ *onehots* "the") (tensor '(0 1 0 0)))
(setf ($ *onehots* "dog") (tensor '(0 0 1 0)))
(setf ($ *onehots* "sat") (tensor '(0 0 0 1)))

(defun word2hot (w) ($ *onehots* w))

(let ((sentence '("the" "cat" "sat")))
  (prn (reduce #'$+ (mapcar #'word2hot sentence))))

;; to implement efficient embedding layer, we need row/column selection
;; which is possible by using $index function
(let ((w (tensor '((1 2 3) (2 3 4) (3 4 5) (4 5 6) (5 6 7) (6 7 8) (7 8 9)))))
  (prn ($index w 0 (tensor.long '(0 1 4))))
  (prn ($sum ($index w 0 (tensor.long '(0 1 4))) 0))
  (prn w))

;; compare multiplication and embedding layer shortcut (conceptually)
(let ((x (tensor '((1 1 0 1))))
      (w (tensor '((1 2 3) (2 3 4) (3 4 5) (4 5 6)))))
  (prn (time ($mm x w)))
  (prn (time ($sum ($index w 0 '(0 1 3)) 0)))
  (prn ($index ($nonzero x) 1 '(1)))
  (prn (time ($sum ($index w 0 ($reshape ($index ($nonzero x) 1 '(1)) 3)) 0))))

(defun process-review (review)
  (remove-duplicates (->> (remove-duplicates (split #\space review) :test #'equal)
                          (mapcar (lambda (w)
                                    (cl-ppcre:regex-replace-all
                                     "[^a-z0-9A-Z]"
                                     (string-downcase w)
                                     "")))
                          (remove-if-not (lambda (w) (> ($count w) 0))))
                     :test #'equal))

(defparameter *imdb* (read-imdb-data2))
(defparameter *reviews* (mapcar #'process-review ($ *imdb* :reviews)))
(defparameter *labels* ($ *imdb* :labels))
(defparameter *train-reviews* (subseq *reviews* 0 24000))
(defparameter *train-labels* (subseq *labels* 0 24000))
(defparameter *test-reviews* (subseq *reviews* 24000))
(defparameter *test-labels* (subseq *labels* 24000))
(defparameter *words* (remove-duplicates (->> *reviews*
                                              (apply #'$concat))
                                         :test #'equal))
(defparameter *w2i* (let ((h (make-hash-table :test 'equal :size ($count *words*))))
                      (loop :for w :in *words*
                            :for i :from 0
                            :do (setf ($ h w) i))
                      h))

(defun review-to-indices (review-words)
  (sort (remove-duplicates (->> review-words
                                (mapcar (lambda (w) ($ *w2i* w)))
                                (remove-if (lambda (w) (null w))))
                           :test #'equal)
        #'<))

(defparameter *input-dataset* (mapcar #'review-to-indices *train-reviews*))
(defparameter *target-dataset* (tensor (mapcar (lambda (s) (if (equal s "positive") 1 0))
                                               *train-labels*)))

(prn ($index *target-dataset* 0 '(0 1 2 3 4)))

;; now we have indices of words as input
(prn ($count *words*)) ;; this is conceptually real input size

;; instead of large matrix multiplication, we can use selection+sum
(let ((w (rnd ($count *words*) 100)))
  (prn (time ($sum ($index w 0 ($0 *input-dataset*)) 0))))

;; for auto backpropagation support
(let ((w ($parameter (rnd ($count *words*) 100))))
  (prn (time ($sum ($index w 0 ($0 *input-dataset*)) 0))))

(defparameter *alpha* 0.01)
(defparameter *iterations* 2)
(defparameter *hidden-size* 100)

(defparameter *w01* ($- ($* 0.2 (rnd ($count *words*) *hidden-size*)) 0.1))
(defparameter *w12* ($- ($* 0.2 (rnd *hidden-size* 1)) 0.1))

(defun predict-sentiment (x)
  (let* ((w01 ($index *w01* 0 x))
         (l1 (-> ($sum w01 0)
                 ($sigmoid!)))
         (l2 (-> ($dot l1 *w12*)
                 ($sigmoid!))))
    l2))

(defparameter *test-dataset* (mapcar #'review-to-indices *test-reviews*))
(defparameter *test-target* (tensor (mapcar (lambda (s) (if (equal s "positive") 1 0))
                                            *test-labels*)))

(defun prn-test-perf ()
  (let ((total 0)
        (correct 0))
    (loop :for i :from 0 :below (min 1000 ($count *test-dataset*))
          :for x = ($ *test-dataset* i)
          :for y = ($ *test-target* i)
          :do (let ((s (predict-sentiment x)))
                (incf total)
                (when (< (abs (- s y)) 0.5)
                  (incf correct))))
    (prn "=>" total correct)))

(time
 (loop :for iter :from 1 :to *iterations*
       :do (let ((total 0)
                 (correct 0))
             (loop :for i :from 0 :below ($count *input-dataset*)
                   :for x = ($ *input-dataset* i)
                   :for y = ($ *target-dataset* i)
                   :for w01 = ($index *w01* 0 x)
                   :for l1 = (-> ($sum w01 0)
                                 ($sigmoid))
                   :for l2 = (-> ($dot l1 *w12*)
                                 ($sigmoid))
                   :for dl2 = ($sub l2 y)
                   :for dl1 = ($* dl2 ($transpose *w12*))
                   :do (let ((d1 ($mul! dl1 *alpha*))
                             (d2 ($mul! l1 (* dl2 *alpha*))))
                         (setf ($index *w01* 0 x)
                               ($sub! w01 ($expand! d1 ($size w01))))
                         ($sub! *w12* d2)
                         (incf total)
                         (when (< (abs dl2) 0.5)
                           (incf correct))))
             (when (zerop (rem iter 1))
               (prn iter total correct)
               (prn-test-perf)))))

(prn (predict-sentiment ($ *input-dataset* 10)))
(prn (predict-sentiment ($ *input-dataset* 2345)))

(let* ((review ($0 *test-reviews*))
       (sentiment ($0 *test-labels*))
       (input (review-to-indices review)))
  (prn review)
  (prn sentiment)
  (prn input)
  (prn (predict-sentiment input)))

(prn-test-perf)

;; wow, this really works
(let* ((my-review "this so called franchise movie of avengers is great master piece. i've enjoyed it very much and my kids love this one as well. though my wife generally does not like this kind of genre, she said this one is better than others.")
       (review (process-review my-review))
       (x (review-to-indices review)))
  (prn x)
  (prn (predict-sentiment x)))

(let* ((my-review "this movie is just a political propaganda, it has neither entertainment or message. i just regret my spending of precious time on this one.")
       (review (process-review my-review))
       (x (review-to-indices review)))
  (prn x)
  (prn (predict-sentiment x)))

;; What hidden layer learns
(defun similar (word)
  (let ((target-index ($ *w2i* word)))
    (when target-index
      (let ((weight-target ($ *w01* target-index))
            (scores nil))
        (loop :for w :in *words*
              :for weight = ($ *w01* ($ *w2i* w))
              :for difference = ($sub weight weight-target)
              :for wdiff = ($dot difference difference)
              :do (let ((score (sqrt wdiff)))
                    (push (cons w score) scores)))
        (subseq (sort scores (lambda (a b) (< (cdr a) (cdr b)))) 0 (min 10 ($count scores)))))))

(prn (similar "beautiful"))
(prn (similar "terrible"))
