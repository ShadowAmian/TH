(defpackage :th.m.vgg19
  (:use #:common-lisp
        #:mu
        #:th)
  (:export #:read-vgg19-weights
           #:convert-to-vgg19-input
           #:vgg19
           #:vgg19fcn))

(in-package :th.m.vgg19)

(defparameter +model-location+ ($concat (namestring (user-homedir-pathname)) ".th/models"))

(defun read-text-weight-file (wn &optional (readp t))
  (when readp
    (let ((f (file.disk (format nil "~A/vgg19/vgg19-~A.txt" +model-location+ wn) "r"))
          (tx (tensor)))
      ($fread tx f)
      ($fclose f)
      tx)))

(defun read-weight-file (wn &optional (readp t))
  (when readp
    (let ((f (file.disk (format nil "~A/vgg19/vgg19-~A.dat" +model-location+ wn) "r"))
          (tx (tensor)))
      (setf ($fbinaryp f) t)
      ($fread tx f)
      ($fclose f)
      tx)))

(defun read-vgg19-text-weights (&optional (flatp t))
  (list :k1 (read-text-weight-file "k1") :b1 (read-text-weight-file "b1")
        :k2 (read-text-weight-file "k2") :b2 (read-text-weight-file "b2")
        :k3 (read-text-weight-file "k3") :b3 (read-text-weight-file "b3")
        :k4 (read-text-weight-file "k4") :b4 (read-text-weight-file "b4")
        :k5 (read-text-weight-file "k5") :b5 (read-text-weight-file "b5")
        :k6 (read-text-weight-file "k6") :b6 (read-text-weight-file "b6")
        :k7 (read-text-weight-file "k7") :b7 (read-text-weight-file "b7")
        :k8 (read-text-weight-file "k8") :b8 (read-text-weight-file "b8")
        :k9 (read-text-weight-file "k9") :b9 (read-text-weight-file "b9")
        :k10 (read-text-weight-file "k10") :b10 (read-text-weight-file "b10")
        :k11 (read-text-weight-file "k11") :b11 (read-text-weight-file "b11")
        :k12 (read-text-weight-file "k12") :b12 (read-text-weight-file "b12")
        :k13 (read-text-weight-file "k13") :b13 (read-text-weight-file "b13")
        :k14 (read-text-weight-file "k14") :b14 (read-text-weight-file "b14")
        :k15 (read-text-weight-file "k15") :b15 (read-text-weight-file "b15")
        :k16 (read-text-weight-file "k16") :b16 (read-text-weight-file "b16")
        :w17 (read-text-weight-file "w17" flatp) :b17 (read-text-weight-file "b17" flatp)
        :w18 (read-text-weight-file "w18" flatp) :b18 (read-text-weight-file "b18" flatp)
        :w19 (read-text-weight-file "w19" flatp) :b19 (read-text-weight-file "b19" flatp)))

(defun read-vgg19-weights (&optional (flatp t))
  (list :k1 (read-weight-file "k1") :b1 (read-weight-file "b1")
        :k2 (read-weight-file "k2") :b2 (read-weight-file "b2")
        :k3 (read-weight-file "k3") :b3 (read-weight-file "b3")
        :k4 (read-weight-file "k4") :b4 (read-weight-file "b4")
        :k5 (read-weight-file "k5") :b5 (read-weight-file "b5")
        :k6 (read-weight-file "k6") :b6 (read-weight-file "b6")
        :k7 (read-weight-file "k7") :b7 (read-weight-file "b7")
        :k8 (read-weight-file "k8") :b8 (read-weight-file "b8")
        :k9 (read-weight-file "k9") :b9 (read-weight-file "b9")
        :k10 (read-weight-file "k10") :b10 (read-weight-file "b10")
        :k11 (read-weight-file "k11") :b11 (read-weight-file "b11")
        :k12 (read-weight-file "k12") :b12 (read-weight-file "b12")
        :k13 (read-weight-file "k13") :b13 (read-weight-file "b13")
        :k14 (read-weight-file "k14") :b14 (read-weight-file "b14")
        :k15 (read-weight-file "k15") :b15 (read-weight-file "b15")
        :k16 (read-weight-file "k16") :b16 (read-weight-file "b16")
        :w17 (read-weight-file "w17" flatp) :b17 (read-weight-file "b17" flatp)
        :w18 (read-weight-file "w18" flatp) :b18 (read-weight-file "b18" flatp)
        :w19 (read-weight-file "w19" flatp) :b19 (read-weight-file "b19" flatp)))

(defun write-binary-weight-file (w filename)
  (let ((f (file.disk filename "w")))
    (setf ($fbinaryp f) t)
    ($fwrite w f)
    ($fclose f)))

(defun write-vgg19-binary-weights (&optional weights)
  (let ((weights (or weights (read-vgg19-text-weights))))
    (loop :for wk :in weights :by #'cddr
          :for wn = (string-downcase (format nil "~A" wk))
          :for w = (getf weights wk)
          :do (write-binary-weight-file w (format nil
                                                  "~A/vgg19/vgg19-~A.dat"
                                                  +model-location+ wn)))))

(defun vgg19-flat (x w flat)
  (let ((nbatch ($size x 0)))
    (cond ((eq flat :all) (-> ($reshape x nbatch 25088)
                              ($affine (getf w :w17) (getf w :b17))
                              ($relu)
                              ($affine (getf w :w18) (getf w :b18))
                              ($relu)
                              ($affine (getf w :w19) (getf w :b19))
                              ($softmax)))
          (t ($reshape x nbatch 25088)))))

(defun vgg19 (&optional (flat :all) weights)
  (let ((weights (or weights (read-vgg19-weights (not (eq flat :none))))))
    (lambda (x)
      (when (and x (>= ($ndim x) 3) (equal (last ($size x) 3) (list 3 224 224)))
        (let ((x (if (eq ($ndim x) 3)
                     ($reshape x 1 3 224 224)
                     x)))
          (-> x
              ($conv2d (getf weights :k1) (getf weights :b1) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k2) (getf weights :b2) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k3) (getf weights :b3) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k4) (getf weights :b4) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k5) (getf weights :b5) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k6) (getf weights :b6) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k7) (getf weights :b7) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k8) (getf weights :b8) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k9) (getf weights :b9) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k10) (getf weights :b10) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k11) (getf weights :b11) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k12) (getf weights :b12) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k13) (getf weights :b13) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k14) (getf weights :b14) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k15) (getf weights :b15) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k16) (getf weights :b16) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              (vgg19-flat weights flat)))))))

(defun vgg19fcn (&optional weights)
  (let* ((weights (or weights (read-vgg19-weights t)))
         (w17 (getf weights :w17))
         (b17 (getf weights :b17))
         (w18 (getf weights :w18))
         (b18 (getf weights :b18))
         (w19 (getf weights :w19))
         (b19 (getf weights :b19))
         (k17 ($reshape ($transpose w17) 4096 512 7 7))
         (b17 ($squeeze b17))
         (k18 ($reshape ($transpose w18) 4096 4096 1 1))
         (b18 ($squeeze b18))
         (k19 ($reshape ($transpose w19) 1000 4096 1 1))
         (b19 ($squeeze b19)))
    (lambda (x)
      (when (and x (>= ($ndim x) 3) )
        (let ((x (if (eq ($ndim x) 3)
                     ($unsqueeze x 0)
                     x)))
          (-> x
              ($conv2d (getf weights :k1) (getf weights :b1) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k2) (getf weights :b2) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k3) (getf weights :b3) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k4) (getf weights :b4) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k5) (getf weights :b5) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k6) (getf weights :b6) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k7) (getf weights :b7) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k8) (getf weights :b8) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k9) (getf weights :b9) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k10) (getf weights :b10) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k11) (getf weights :b11) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k12) (getf weights :b12) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d (getf weights :k13) (getf weights :b13) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k14) (getf weights :b14) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k15) (getf weights :b15) 1 1 1 1)
              ($relu)
              ($conv2d (getf weights :k16) (getf weights :b16) 1 1 1 1)
              ($relu)
              ($maxpool2d 2 2 2 2)
              ($conv2d k17 b17)
              ($relu)
              ($conv2d k18 b18)
              ($relu)
              ($conv2d k19 b19)
              ($softmax)))))))
