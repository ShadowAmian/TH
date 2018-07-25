(declaim (optimize (speed 3) (debug 1) (safety 0)))

(in-package :th)

(defmethod $abs ((x node))
  (let ((out ($empty ($data x))))
    (nn-abs-update-output ($data x) out)
    (let ((result (node out)))
      (setf ($name result) "ABS")
      ($gp! result x)
      ($pfn! x (lambda ()
                 (let ((d ($empty ($data x))))
                   (nn-abs-update-grad-input ($data x) ($gradient result) d)
                   d)))
      result)))

(defmethod $acos ((x node))
  (let ((result (node ($acos ($data x)))))
    (setf ($name result) "ACOS")
    ($gp! result x)
    ($pfn! x (lambda () ($mul! ($div -1 ($sqrt! ($sub 1 ($expt ($data x) 2)))) ($gradient result))))
    result))

(defmethod $asin ((x node))
  (let ((result (node ($asin ($data x)))))
    (setf ($name result) "ASIN")
    ($gp! result x)
    ($pfn! x (lambda () ($mul! ($div 1 ($sqrt! ($sub 1 ($expt ($data x) 2)))) ($gradient result))))
    result))

(defmethod $atan ((x node))
  (let ((result (node ($atan ($data x)))))
    (setf ($name result) "ATAN")
    ($gp! result x)
    ($pfn! x (lambda () ($mul! ($div 1 ($add 1 ($expt ($data x) 2))) ($gradient result))))
    result))

(defmethod $atan2 ((y node) (x node))
  (let ((result (node ($atan2 ($data y) ($data x)))))
    (setf ($name result) "ATAN2")
    ($gp! result y x)
    ($pfn! y (lambda () ($mul! ($div ($data x) ($add! ($expt ($data x) 2)
                                                      ($expt ($data y) 2)))
                               ($gradient result))))
    ($pfn! x (lambda () ($mul! ($div ($neg ($data y)) ($add! ($expt ($data x) 2)
                                                             ($expt ($data y) 2)))
                               ($gradient result))))
    result))

(defmethod $cos ((x node))
  (let ((result (node ($cos ($data x)))))
    (setf ($name result) "COS")
    ($gp! result x)
    ($pfn! x (lambda () ($mul! ($neg! ($sin ($data x))) ($gradient result))))
    result))

(defmethod $cosh ((x node))
  (let ((result (node ($cosh ($data x)))))
    (setf ($name result) "COSH")
    ($gp! result x)
    ($pfn! x (lambda () ($mul! ($sinh ($data x)) ($gradient result))))
    result))

(defmethod $exp ((x node))
  (let ((result (node ($exp ($data x)))))
    (setf ($name result) "EXP")
    ($gp! result x)
    ($pfn! x (lambda () ($mul ($data result) ($gradient result))))
    result))

(defmethod $expt ((a node) (b node))
  (let ((result (node ($expt ($data a) ($data b)))))
    (setf ($name result) "EXPT")
    ($gp! result a b)
    ($pfn! a (lambda () ($mul! ($mul ($gradient result) ($data b))
                               ($expt ($data a) ($- ($data b) 1)))))
    ($pfn! b (lambda () ($mul! ($mul! ($log ($data a))
                                      ($expt ($data a) ($data b)))
                               ($gradient result))))
    result))

(defmethod $expt ((a node) (b number))
  (let ((result (node ($expt ($data a) b))))
    (setf ($name result) "EXPT")
    ($gp! result a)
    ($pfn! a (lambda () ($mul! ($mul ($gradient result) b)
                               ($expt ($data a) (- b 1)))))
    result))

(defun dlog (x) ($div 1.0 x))

(defmethod $log ((x node))
  (let ((result (node ($log ($data x)))))
    (setf ($name result) "LOG")
    ($gp! result x)
    ($pfn! x ($* (dlog ($data x)) ($gradient result)))
    result))

(defmethod $sin ((x node))
  (let ((result (node ($sin ($data x)))))
    (setf ($name result) "SIN")
    ($gp! result x)
    ($pfn! x (lambda () ($mul ($cos ($data x)) ($gradient result))))
    result))

(defun dsigmoid (s) ($mul s ($sub 1 s)))

(defmethod $sigmoid ((x node))
  (let ((result (node ($sigmoid ($data x)))))
    (setf ($name result) "SIGMOID")
    ($gp! result x)
    ($pfn! x (lambda () ($mul! (dsigmoid ($data result)) ($gradient result))))
    result))

(defmethod $sinh ((x node))
  (let ((result (node ($sinh ($data x)))))
    (setf ($name result) "SINH")
    ($gp! result x)
    ($pfn! x (lambda () ($mul ($cosh ($data x)) ($gradient result))))
    result))

(defun sqrt-backprop (node gradient)
  (setgradient node gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x ($mul! ($mul gradient 0.5)
                                                      ($expt ($data x) -0.5)))
                                       x)))))
  node)

(defmethod $sqrt ((x node))
  (let ((result (node ($sqrt ($data x)))))
    (setf ($name result) "SQRT")
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'sqrt-backprop)
    result))

(defun tan-backprop (node gradient)
  (setgradient node gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x ($mul! ($expt ($cos ($data x)) 2.0) gradient))
                                       x)))))
  node)

(defmethod $tan ((x node))
  (let ((result (node ($tan ($data x)))))
    (setf ($name result) "TAN")
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'tan-backprop)
    result))

(defun dtanh (s) ($sub 1 ($* s s)))

(defun tanh-backprop (node gradient)
  (setgradient node gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x ($mul! (dtanh ($data node)) gradient))
                                       x)))))
  node)

(defmethod $tanh ((x node))
  (let ((result (node ($tanh ($data x)))))
    (setf ($name result) "TANH")
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'tanh-backprop)
    result))
