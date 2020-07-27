;; from https://github.com/seungjaeryanlee/implementations-nfq.git

(defpackage :cartpole-nfq
  (:use #:common-lisp
        #:mu
        #:th
        #:th.layers
        #:th.env))

(in-package :cartpole-nfq)

(defconstant +gravity+ 9.8D0)
(defconstant +masscart+ 1D0)
(defconstant +masspole+ 0.1D0)
(defconstant +total-mass+ (+ +masscart+ +masspole+))
(defconstant +length+ 0.5D0)
(defconstant +polemass-length+ (* +masspole+ +length+))
(defconstant +force-mag+ 10D0)
(defconstant +tau+ 0.02D0)

(defconstant +x-success-range+ 2.4D0)
(defconstant +theta-success-range+ (/ (* 12 PI) 180D0))

(defconstant +x-threshold+ 2.4D0)
(defconstant +theta-threshold-radians+ (/ PI 2))
(defconstant +c-trans+ 0.01D0)

(defconstant +train-max-steps+ 100)
(defconstant +eval-max-steps+ 3000)

(defclass cartpole-regulator-env ()
  ((mode :initform nil :accessor env/mode)
   (step :initform 0 :accessor env/episode-step)
   (state :initform nil :accessor env/state)))

(defun cartpole-regulator-env (&optional (m :train))
  (let ((n (make-instance 'cartpole-regulator-env)))
    (setf (env/mode n) m)
    (env/reset! n)
    n))

(defmethod env/reset! ((env cartpole-regulator-env))
  (with-slots (mode state step) env
    (setf step 0)
    (setf state (if (eq mode :train)
                    (tensor (list (random/uniform -2.3D0 2.3D0)
                                  0
                                  (random/uniform -0.3 0.3)
                                  0))
                    (tensor (list (random/uniform -1D0 1D0)
                                  0
                                  (random/uniform -0.3 0.3)
                                  0))))
    state))

(defmethod env/step! ((env cartpole-regulator-env) action)
  (let* ((x ($0 (env/state env)))
         (xd ($1 (env/state env)))
         (th ($2 (env/state env)))
         (thd ($3 (env/state env)))
         (force (if (eq action 1) +force-mag+ (- +force-mag+)))
         (costh (cos th))
         (sinth (sin th))
         (tmp (/ (+ force (* +polemass-length+ thd thd sinth))
                 +total-mass+))
         (thacc (/ (- (* +gravity+ sinth) (* costh tmp))
                   (* +length+
                      (- 4/3 (/ (* +masspole+ costh costh) +total-mass+)))))
         (xacc (- tmp (/ (* +polemass-length+ thacc costh) +total-mass+)))
         (cost +c-trans+)
         (done nil)
         (blown nil))
    (incf (env/episode-step env))
    (incf x (* +tau+ xd))
    (incf xd (* +tau+ xacc))
    (incf th (* +tau+ thd))
    (incf thd (* +tau+ thacc))
    (cond ((or (< x (- +x-threshold+)) (> x +x-threshold+)
               (< th (- +theta-threshold-radians+)) (> th +theta-threshold-radians+))
           (setf cost 1D0
                 done T))
          ((and (> x (- +x-success-range+)) (< x +x-success-range+)
                (> th (- +theta-success-range+)) (< th +theta-success-range+))
           (setf cost 0D0
                 done nil))
          (T (setf cost +c-trans+
                   done nil)))
    (when (>= (env/episode-step env)
             (if (eq :train (env/mode env)) +train-max-steps+ +eval-max-steps+))
      (setf blown T))
    (let ((next-state (tensor (list x xd th thd))))
      (setf (env/state env) next-state)
      (list nil next-state cost done blown))))

(defun generate-goal-patterns (&optional (size 100))
  (list (tensor (loop :repeat size
                      :collect (list (random/uniform -0.05 0.05)
                                     (random/normal 0 1)
                                     (random/uniform (- +theta-success-range+)
                                                     +theta-success-range+)
                                     (random/normal 0 1)
                                     (random 2))))
        (zeros size 1)))

(defun collect-experiences (env &optional selector)
  (let ((rollout '())
        (episode-cost 0)
        (state (env/reset! env))
        (done nil)
        (blown nil))
    (loop :while (and (not done) (not blown))
          :for action = (if selector
                            (funcall selector state)
                            (random 2))
          :for tx = (env/step! env action)
          :do (let ((next-state ($1 tx))
                    (cost ($2 tx)))
                (setf done ($3 tx)
                      blown ($4 tx))
                (push (list state action cost next-state done) rollout)
                (incf episode-cost cost)
                (setf state next-state)))
    (list (reverse rollout) episode-cost)))

(defun model (&optional (ni 5) (no 1))
  (let ((h1 5)
        (h2 5))
    (sequential-layer
     (affine-layer ni h1 :weight-initializer :random-uniform)
     (affine-layer h1 h2 :weight-initializer :random-uniform)
     (affine-layer h2 no :weight-initializer :random-uniform))))

(defun best-action-selector (model)
  (lambda (state)
    (let* ((state ($reshape state 1 4))
           (qleft ($evaluate model ($concat state (zeros 1 1) 1)))
           (qright ($evaluate model ($concat state (ones 1 1) 1))))
      (if (>= ($ qleft 0 0) ($ qright 0 0)) 1 0))))

(defun generate-patterns (model experiences &optional (gamma 0.95D0))
  (let* ((nr ($count experiences))
         (state-list (mapcar #'$0 experiences))
         (states (-> (apply #'$concat state-list)
                     ($reshape! nr 4)))
         (actions (-> (tensor (mapcar #'$1 experiences))
                      ($reshape! nr 1)))
         (costs (-> (tensor (mapcar #'$2 experiences))
                    ($reshape! nr 1)))
         (next-states (-> (apply #'$concat (mapcar #'$3 experiences))
                          ($reshape! nr 4)))
         (dones (-> (tensor (mapcar (lambda (e) (if ($4 e) 1 0)) experiences))
                    ($reshape! nr 1)))
         (xs ($concat states actions 1))
         (qleft ($evaluate model ($concat next-states (zeros nr 1) 1)))
         (qright ($evaluate model ($concat next-states (ones nr 1) 1)))
         (qns ($min ($concat qleft qright 1) 1))
         (tqvs ($+ costs ($* gamma qns ($- 1 dones)))))
    (list xs tqvs)))

(defun train (model xs ts)
  (let* ((ys ($execute model xs))
         (loss ($mse ys ts)))
    ($rpgd! model)
    ($data loss)))

(defun evaluate (env model)
  (let ((state (env/reset! env))
        (ne 0)
        (done nil)
        (blown nil)
        (ecost 0D0)
        (selector (best-action-selector model)))
    (loop :while (and (not done) (not blown))
          :for step :from 0 :below +eval-max-steps+
          :for action = (funcall selector state)
          :for tx = (env/step! env action)
          :do (let ((next-state ($1 tx))
                    (cost ($2 tx)))
                (setf done ($3 tx)
                      blown ($4 tx))
                (incf ecost cost)
                (incf ne)
                (setf state next-state)))
    (list ne
          (and (>= ne (- +eval-max-steps+ 2)) (<= (abs ($0 state)) +x-success-range+))
          ecost)))

(defvar *init-experience* T)
(defvar *increment-experience* T)
(defvar *hint-to-goal* T)
(defvar *max-epochs* 300)

(defun report (epoch loss ntrain ctrain neval ceval success)
  (when (or success (zerop (rem epoch 20)))
    (let ((fmt "EPOCH ~4D | TRAIN ~3D / ~4,2F | EVAL ~4D / ~5,2F | TRAIN.LOSS ~,4F"))
      (prn (format nil fmt epoch ntrain ctrain neval ceval loss)))))

(with-max-heap ()
  (let* ((train-env (cartpole-regulator-env :train))
         (eval-env (cartpole-regulator-env :eval))
         (model (model))
         (experiences '())
         (total-cost 0)
         (success nil))
    (when *init-experience*
      (let* ((exsi (collect-experiences train-env))
             (exs (car exsi))
             (ecost (cadr exsi)))
        (setf experiences exs)
        (incf total-cost ecost)))
    (loop :for epoch :from 1 :to *max-epochs*
          :while (not success)
          :do (let ((ctrain 0)
                    (ntrain 0))
                (when *increment-experience*
                  (let* ((exsi (collect-experiences train-env (best-action-selector model)))
                         (exs (car exsi)))
                    (setf ctrain (cadr exsi))
                    (setf ntrain ($count exs))
                    (setf experiences (append experiences exs))
                    (incf total-cost ctrain)))
                (let* ((xys (generate-patterns model experiences 0.95D0))
                       (xs (car xys))
                       (ys (cadr xys)))
                  (when *hint-to-goal*
                    (let ((gxys (generate-goal-patterns)))
                      (setf xs ($concat xs (car gxys) 0))
                      (setf ys ($concat ys (cadr gxys) 0))))
                  (let* ((loss (train model xs ys))
                         (eres (evaluate eval-env model))
                         (neval ($0 eres))
                         (ceval ($2 eres)))
                    (setf success ($1 eres))
                    (report epoch loss ntrain ctrain neval ceval success)))))
    (when success
      (prn (format nil "*** TOTAL ~6D / ~4,2F" ($count experiences) total-cost)))))