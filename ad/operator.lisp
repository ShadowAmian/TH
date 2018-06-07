(in-package :th)

(defmethod $broadcast ((c number) (m tensor))
  ($mul! ($one m) c))

(defgeneric $krows (vector n))
(defgeneric $kcols (vector n))

(defmethod $krows ((vector tensor) n) ($vv (ones n) vector))
(defmethod $kcols ((vector tensor) n) ($vv vector (ones n)))

(defmethod $broadcast ((vector tensor) (matrix tensor))
  (let ((nv ($count vector))
        (sz ($size matrix)))
    (cond ((eq nv ($ sz 1)) ($krows vector ($ sz 0)))
          ((eq nv ($ sz 0)) ($kcols vector ($ sz 1)))
          (t (error "cannot broadcast automatically")))))

(defun broadcast-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((c ($c0 node)))
                             (list (if ($gradientp c)
                                       ($bp! c ($dot ($one ($data node)) gradient))
                                       c)))))
  node)

(defmethod $broadcast ((c node) (m node))
  (let ((result (node ($mul! ($one ($data m)) ($data c)))))
    (setf ($children result) (list c))
    (setf ($gradientp result) ($gradientp c))
    (setf ($bpfn result) #'broadcast-backprop)
    result))

(defun add-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node)
        (mapcar (lambda (c)
                  (if ($gradientp c)
                      ($bp! c gradient)
                      c))
                ($children node)))
  node)

(defmethod $add ((a node) (b node))
  (let ((result (node ($add ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'add-backprop)
    result))

(defun sub-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a) ($bp! a gradient) a)
                                   (if ($gradientp b) ($bp! b ($neg gradient)) b)))))
  node)

(defmethod $sub ((a node) (b node))
  (let ((result (node ($sub ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'sub-backprop)
    result))

(defun neg-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node)))
                             (list (if ($gradientp a) ($bp! a ($neg gradient)) a)))))
  node)

(defmethod $neg ((a node))
  (let ((result (node ($neg ($data a)))))
    (setf ($children result) (list a))
    (setf ($gradientp result) ($gradientp a))
    (setf ($bpfn result) #'neg-backprop)
    result))

(defun dot-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a) ($bp! a ($* ($data b) gradient)) a)
                                   (if ($gradientp b) ($bp! b ($* ($data a) gradient)) b)))))
  node)

(defmethod $dot ((a node) (b node))
  (let ((result (node ($dot ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'dot-backprop)
    result))

(defun mv-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((m ($c0 node))
                                 (v ($c1 node)))
                             (list (if ($gradientp m)
                                       ($bp! m ($vv gradient ($data v)))
                                       m)
                                   (if ($gradientp v)
                                       ($bp! v ($@ ($transpose ($data m)) gradient))
                                       v)))))
  node)

(defmethod $mv ((m node) (v node))
  (let ((result (node ($mv ($data m) ($data v)))))
    (setf ($children result) (list m v))
    (setf ($gradientp result) (or ($gradientp m) ($gradientp v)))
    (setf ($bpfn result) #'mv-backprop)
    result))

(defun mm-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a)
                                       ($bp! a ($@ gradient ($transpose ($data b))))
                                       a)
                                   (if ($gradientp b)
                                       ($bp! b ($@ ($transpose ($data a)) gradient))
                                       b)))))
  node)

(defmethod $mm ((a node) (b node))
  (let ((result (node ($mm ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'mm-backprop)
    result))

(defun mul-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a)
                                       ($bp! a ($* ($data b) gradient))
                                       a)
                                   (if ($gradientp b)
                                       ($bp! b ($* ($data a) gradient))
                                       b)))))
  node)

(defmethod $mul ((a node) (b node))
  (let ((result (node ($mul ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'mul-backprop)
    result))

(defun bmm-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node))
                                 (y ($c1 node)))
                             (list (if ($gradientp x)
                                       ($bp! x ($bmm gradient ($transpose ($data y) 2 1)))
                                       x)
                                   (if ($gradientp y)
                                       ($bp! y ($bmm ($transpose ($data x) 2 1) gradient)))))))
  node)

(defmethod $bmm ((bx node) (by node))
  (let ((result (node ($bmm ($data bx) ($data by)))))
    (setf ($children result) (list bx by))
    (setf ($gradientp result) (or ($gradientp bx) ($gradientp by)))
    (setf ($bpfn result) #'bmm-backprop)
    result))

(defmethod $mml ((x node) (y node))
  (cond ((and (eq 1 ($ndim x)) (eq 1 ($ndim y))) ($dot x y))
        ((and (eq 2 ($ndim x)) (eq 1 ($ndim y))) ($mv x y))
        ((and (eq 2 ($ndim x)) (eq 2 ($ndim y))) ($mm x y))
        ((and (eq 3 ($ndim x)) (eq 3 ($ndim y))) ($bmm x y))))

(defun div-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a)
                                       ($bp! a ($div gradient ($data b)))
                                       a)
                                   (if ($gradientp b)
                                       ($bp! b ($neg! ($div ($* ($data a) gradient)
                                                            ($expt ($data b) 2))))
                                       b)))))
  node)

(defmethod $div ((a node) (b node))
  (let ((result (node ($div ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'div-backprop)
    result))

(defun vv-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a)
                                       ($bp! a ($mv gradient ($data b)))
                                       a)
                                   (if ($gradientp b)
                                       ($bp! b ($mv ($transpose gradient) ($data a)))
                                       b)))))
  node)

(defmethod $vv ((a node) (b node))
  (let ((result (node ($vv ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'vv-backprop)
    result))

(defun inverse-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node)))
                             (list (if ($gradientp a)
                                       (let ((tnode ($transpose ($data node))))
                                         ($bp! a ($neg ($mm ($mm tnode gradient) tnode)))
                                         a))))))
  node)

(defmethod $inverse ((a node))
  (let ((result (node ($inverse ($data a)))))
    (setf ($children result) (list a))
    (setf ($gradientp result) ($gradientp a))
    (setf ($bpfn result) #'inverse-backprop)
    result))

(defun view-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node)))
                             (list (if ($gradientp a)
                                       ($bp! a ($view gradient ($data a)))
                                       a)))))
  node)

(defmethod $view ((a node) &rest sizes)
  (let ((result (node (apply #'$view ($data a) sizes))))
    (setf ($children result) (list a))
    (setf ($gradientp result) ($gradientp a))
    (setf ($bpfn result) #'view-backprop)
    result))

(defun expand-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node)))
                             (list (if ($gradientp a)
                                       (let* ((adata ($data a))
                                              (asize ($size adata))
                                              (out gradient))
                                         (loop :for dim :from 0 :below ($count asize)
                                               :for sz = ($ asize dim)
                                               :do (when (eq sz 1)
                                                     (setf out ($sum out dim))))
                                         ($bp! a out))
                                       a)))))
  node)

(defmethod $expand ((a node) size)
  (let ((result (node ($expand ($data a) size))))
    (setf ($children result) (list a))
    (setf ($gradientp result) ($gradientp a))
    (setf ($bpfn result) #'expand-backprop)
    result))

(defun sum-backprop (node gradient dimension)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (if (< dimension 0)
                                 (list (if ($gradientp x)
                                           ($bp! x ($broadcast gradient ($data x)))
                                           x))
                                 (list (if ($gradientp x)
                                           ($bp! x ($expand gradient ($size x)))
                                           x))))))
  node)

(defmethod $sum ((x node) &optional (dimension -1))
  (let ((result (node ($sum ($data x) dimension))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient) (sum-backprop node gradient dimension)))
    result))

(defun mean-backprop (node gradient dimension)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (if (< dimension 0)
                                 (list (if ($gradientp x)
                                           ($bp! x ($broadcast (/ gradient ($count ($data x)))
                                                               ($data x)))
                                           x))
                                 (list (if ($gradientp x)
                                           ($bp! x ($div! ($expand gradient ($size x))
                                                          ($size ($data x) dimension)))
                                           x))))))
  node)

(defmethod $mean ((x node) &optional (dimension -1))
  (let ((result (node ($mean ($data x) dimension))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient) (mean-backprop node gradient dimension)))
    result))

(defun seteq! (a b v)
  (let ((m ($eq a b)))
    ($mul! ($copy! ($resize! ($empty a) a) m) v)))

(defun min-backprop (node gradient dimension)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (if (< dimension 0)
                                 (list (if ($gradientp x)
                                           ($bp! x (seteq! ($data x) ($data node) gradient))
                                           x))
                                 (list (if ($gradientp x)
                                           ($bp! x (seteq! ($data x)
                                                           ($expand ($data node) ($size x))
                                                           ($expand gradient ($size x))))
                                           x))))))
  node)

(defmethod $min ((x node) &optional (dimension -1))
  (let ((result (node ($min ($data x) dimension))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient) (min-backprop node gradient dimension)))
    result))

(defun max-backprop (node gradient dimension)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (if (< dimension 0)
                                 (list (if ($gradientp x)
                                           ($bp! x (seteq! ($data x) ($data node) gradient))
                                           x))
                                 (list (if ($gradientp x)
                                           ($bp! x (seteq! ($data x)
                                                           ($expand ($data node) ($size x))
                                                           ($expand gradient ($size x))))
                                           x))))))
  node)

(defmethod $max ((x node) &optional (dimension -1))
  (let ((result (node ($max ($data x) dimension))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient) (max-backprop node gradient dimension)))
    result))

(defun transpose-backprop (node gradient dimension0 dimension1)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x ($transpose gradient dimension0 dimension1))
                                       x)))))
  node)

(defmethod $transpose ((x node) &optional dimension0 dimension1)
  (let ((result (node ($transpose ($data x) dimension0 dimension1))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient)
                           (transpose-backprop node gradient dimension0 dimension1)))
    result))

(defun reshape-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x ($view gradient ($data x)))
                                       x)))))
  node)

(defmethod $reshape ((x node) &rest sizes)
  (let ((result (node (apply #'$reshape ($data x) sizes))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'reshape-backprop)
    result))

(defun get-backprop (node gradient locs)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradient x)
                                       ($bp! x (let ((z ($zero ($data x))))
                                                 ($copy! (apply #'$ z locs) gradient)
                                                 z))
                                       x)))))
  node)

(defmethod $ ((x node) location &rest others-and-default)
  (let ((result (node (apply #'$ ($data x) (cons location others-and-default)))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient)
                           (get-backprop node gradient (cons location others-and-default))))
    result))

(defun set-backprop (node gradient locs)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node))
                                 (v ($c1 node)))
                             (list (if ($gradient x)
                                       ($bp! x (let ((ng ($clone gradient)))
                                                 (setf (apply #'$ ng locs) 0)
                                                 ng))
                                       x)
                                   (if ($gradient v)
                                       ($bp! v (let ((gk (apply #'$ gradient locs)))
                                                 (if (numberp gk)
                                                     gk
                                                     ($clone gk))))
                                       v)))))
  node)

(defmethod (setf $) (value (x node) location &rest others)
  (let ((nx ($clone ($data x))))
    (setf (apply #'$ nx (cons location others)) value)
    (let ((result (node nx)))
      (setf ($children result) (list x value))
      (setf ($gradientp result) (or ($gradientp x) ($gradientp value)))
      (setf ($bpfn result) (lambda (node gradient)
                             (set-backprop node gradient (cons location others))))
      result)))

(defmethod clone-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x gradient)
                                       x)))))
  node)

(defmethod $clone ((x node))
  (let ((result (node ($clone ($data x)))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'clone-backprop)
    result))

(defun cat-backprop (node gradient dimension)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let* ((x ($c0 node))
                                  (y ($c1 node))
                                  (gx ($narrow gradient dimension 0 ($size ($data x) 1)))
                                  (gy ($narrow gradient dimension ($size ($data x) 1)
                                               ($size ($data y) 1))))
                             (list (if ($gradientp x)
                                       ($bp! x gx)
                                       x)
                                   (if ($gradientp y)
                                       ($bp! y gy)
                                       y)))))
  node)

(defmethod $cat ((x node) (y node) &optional (dimension 0))
  (let ((result (node ($cat ($data x) ($data y) dimension))))
    (setf ($children result) (list x y))
    (setf ($gradientp result) (or ($gradientp x) ($gradientp y)))
    (setf ($bpfn result) (lambda (node gradient) (cat-backprop node gradient dimension)))
    result))

(defun index-backprop (node gradient dimension indices)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       (let* ((g ($zero ($data x)))
                                              (gs ($index g dimension indices)))
                                         (setf ($index g dimension indices)
                                               (apply #'$reshape gradient ($size gs)))
                                         ($bp! x g))
                                       x)))))
  node)

(defmethod $index ((x node) dimension (indices list))
  (let ((result (node ($index ($data x) dimension indices))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) (lambda (node gradient) (index-backprop node gradient dimension indices)))
    result))
