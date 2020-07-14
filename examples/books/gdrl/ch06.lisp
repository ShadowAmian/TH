(defpackage :gdrl-ch06
  (:use #:common-lisp
        #:mu
        #:th
        #:th.env)
  (:import-from #:th.env.examples))

(in-package :gdrl-ch06)

(defun decay-schedule (v0 minv decay-ratio max-steps &key (log-start -2) (log-base 10))
  (let* ((decay-steps (round (* max-steps decay-ratio)))
         (rem-steps (- max-steps decay-steps))
         (vs (-> ($/ (logspace log-start 0 decay-steps) (log log-base 10))
                 ($list)
                 (reverse)
                 (tensor)))
         (minvs ($min vs))
         (maxvs ($max vs))
         (rngv (- maxvs minvs))
         (vs ($/ ($- vs minvs) rngv))
         (vs ($+ minv ($* vs (- v0 minv)))))
    ($cat vs ($fill! (tensor rem-steps) ($last vs)))))

(defun discounts (gamma max-steps)
  (loop :for i :from 0 :below max-steps :collect (expt gamma i)))

(defun generate-trajectory (env Q select-action epsilon &key (max-steps 200))
  (let ((done nil)
        (trajectory '()))
    (loop :while (not done)
          :for state = (env/reset! env)
          :do (loop :for e :from 0 :to max-steps
                    :while (not done)
                    :do (let* ((action (funcall select-action Q state epsilon))
                               (tx (env/step! env action))
                               (next-state (transition/next-state tx))
                               (reward (transition/reward tx))
                               (terminalp (transition/terminalp tx))
                               (experience (list state action reward next-state terminalp)))
                          (push experience trajectory)
                          (setf done terminalp
                                state next-state)
                          (when (>= e max-steps)
                            (setf trajectory '())))))
    (reverse trajectory)))

(defun experience/state (record) ($ record 0))
(defun experience/action (record) ($ record 1))
(defun experience/reward (record) ($ record 2))
(defun experience/next-state (record) ($ record 3))
(defun experience/terminalp (record) ($ record 4))

(defun mc-control (env &key (gamma 1D0)
                         (alpha0 0.5) (min-alpha 0.01) (alpha-decay-ratio 0.5)
                         (epsilon0 1.0) (min-epsilon 0.1) (epsilon-decay-ratio 0.9)
                         (nepisodes 3000)
                         (max-steps 200)
                         (first-visit-p T))
  (let* ((ns (env/state-count env))
         (na (env/action-count env))
         (discounts (discounts gamma max-steps))
         (alphas (decay-schedule alpha0 min-alpha alpha-decay-ratio nepisodes))
         (epsilons (decay-schedule epsilon0 min-epsilon epsilon-decay-ratio nepisodes))
         (pi-track '())
         (Q (zeros ns na))
         (Q-track (zeros nepisodes ns na))
         (select-action (lambda (Q state epsilon)
                          (if (> (random 1D0) epsilon)
                              ($argmax ($ Q state))
                              (random ($count ($ Q state)))))))
    (loop :for e :from 0 :below nepisodes
          :for eps = ($ epsilons e)
          :for trajectory = (generate-trajectory env Q select-action eps :max-steps max-steps)
          :for visited = (zeros ns na)
          :do (progn
                (loop :for strj :on trajectory
                      :for it :from 0
                      :for experience = (car strj)
                      :for state = (experience/state experience)
                      :for action = (experience/action experience)
                      :for reward = (experience/reward experience)
                      :do (unless (and first-visit-p (> ($ visited state action) 0))
                            (let* ((strj (subseq trajectory it))
                                   (g (loop :for exi :in strj
                                            :for ri = (experience/reward exi)
                                            :for i :from 0
                                            :summing (* ($ discounts i) ri)))
                                   (mc-err (- g ($ Q state action))))
                              (setf ($ visited state action) 1)
                              (incf ($ Q state action) (* ($ alphas e) mc-err)))))
                (setf ($ Q-track e) Q)
                (push ($squeeze ($argmax Q 1)) pi-track)))
    (let ((v ($squeeze ($argmax Q 1))))
      (list Q v (lambda (s) ($ v s)) Q-track pi-track))))
