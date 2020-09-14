(declaim (optimize (speed 3) (debug 1) (safety 0)))

(in-package :th)

(defparameter *th-tensor-functions*
  '(("storage" storage storageptr (tensor tensorptr))
    ("storageOffset" storage-offset ptrdiff-t (tensor tensorptr))
    ("nDimension" n-dimension :int (tensor tensorptr))
    ("size" size :long (tensor tensorptr) (dim :int))
    ("stride" stride :long (tensor tensorptr) (dim :int))
    ("newSizeOf" new-size-of th-long-storage-ptr (tensor tensorptr))
    ("newStrideOf" new-stride-of th-long-storage-ptr (tensor tensorptr))
    ("data" data realptr (tensor tensorptr))
    ("setFlag" set-flag :void (tensor tensorptr) (flag :char))
    ("clearFlag" clear-flag :void (tensor tensorptr) (flag :char))
    ("new" new tensorptr)
    ("newWithTensor" new-with-tensor tensorptr (tensor tensorptr))
    ("newWithStorage" new-with-storage tensorptr (storage storageptr) (storage-offset ptrdiff-t)
     (size th-long-storage-ptr) (stride (th-long-storage-ptr)))
    ("newWithStorage1d" new-with-storage-1d tensorptr (storage storageptr) (storage-offset ptrdiff-t)
     (size0 :long) (stride0 :long))
    ("newWithStorage2d" new-with-storage-2d tensorptr (storage storageptr) (storage-offset ptrdiff-t)
     (size0 :long) (stride0 :long) (size1 :long) (stride1 :long))
    ("newWithStorage3d" new-with-storage-3d tensorptr (storage storageptr) (storage-offset ptrdiff-t)
     (size0 :long) (stride0 :long) (size1 :long) (stride1 :long) (size2 :long) (stride2 :long))
    ("newWithStorage4d" new-with-storage-4d tensorptr (storage storageptr) (storage-offset ptrdiff-t)
     (size0 :long) (stride0 :long) (size1 :long) (stride1 :long) (size2 :long) (stride2 :long)
     (size3 :long) (stride3 :long))
    ("newWithSize" new-with-size tensorptr (size th-long-storage-ptr) (stride th-long-storage-ptr))
    ("newWithSize1d" new-with-size-1d tensorptr (size0 :long))
    ("newWithSize2d" new-with-size-2d tensorptr (size0 :long) (size1 :long))
    ("newWithSize3d" new-with-size-3d tensorptr (size0 :long) (size1 :long) (size2 :long))
    ("newWithSize4d" new-with-size-4d tensorptr (size0 :long) (size1 :long) (size2 :long)
     (size3 :long))
    ("newClone" new-clone tensorptr (tensor tensorptr))
    ("newContiguous" new-contiguous tensorptr (tensor tensorptr))
    ("newSelect" new-select tensorptr (tensor tensorptr) (dimension :int) (slice-index :long))
    ("newNarrow" new-narrow tensorptr (tensor tensorptr) (dimension :int) (first-idnex :long)
     (size :long))
    ("newTranspose" new-transpose tensorptr (tensor tensorptr) (dimension1 :int) (dimension2 :int))
    ("newUnfold" new-unfold tensorptr (tensor tensorptr) (dim :int) (size :long) (step :long))
    ("newView" new-view tensorptr (tensor tensorptr) (size th-long-storage-ptr))
    ("newExpand" new-expand tensorptr (tensor tensorptr) (size th-long-storage-ptr))
    ("expand" expand :void (r tensorptr) (tensor tensorptr) (size th-long-storage-ptr))
    ("resize" resize :void (tensor tensorptr) (size th-long-storage-ptr)
     (stride th-long-storage-ptr))
    ("resizeAs" resize-as :void (tensor tensorptr) (src tensorptr))
    ("resizeNd" resize-nd :void (tensor tensorptr) (dim :int) (size (:pointer :long))
     (stride (:pointer :long)))
    ("resize1d" resize-1d :void (tensor tensorptr) (size0 :long))
    ("resize2d" resize-2d :void (tensor tensorptr) (size0 :long) (size1 :long))
    ("resize3d" resize-3d :void (tensor tensorptr) (size0 :long) (size1 :long) (size2 :long))
    ("resize4d" resize-4d :void (tensor tensorptr) (size0 :long) (size1 :long) (size2 :long)
     (size3 :long))
    ("resize5d" resize-5d :void (tensor tensorptr) (size0 :long) (size1 :long) (size2 :long)
     (size3 :long) (size4 :long))
    ("set" set :void (tensor tensorptr) (src tensorptr))
    ("setStorage" set-storage :void (tensor tensorptr) (storage storageptr)
     (storage-offset ptrdiff-t) (size th-long-storage-ptr) (stride th-long-storage-ptr))
    ("setStorageNd" set-storage-nd :void (tensor tensorptr) (storage storageptr)
     (storage-offset ptrdiff-t) (dim :int) (size (:pointer :long)) (stride (:pointer :long)))
    ("setStorage1d" set-storage-1d :void (tensor tensorptr) (storage storageptr)
     (storage-offset ptrdiff-t) (size0 :long) (stride0 :long))
    ("setStorage2d" set-storage-2d :void (tensor tensorptr) (storage storageptr)
     (storage-offset ptrdiff-t) (size0 :long) (stride0 :long) (size1 :long) (stride1 :long))
    ("setStorage3d" set-storage-3d :void (tensor tensorptr) (storage storageptr)
     (storage-offset ptrdiff-t) (size0 :long) (stride0 :long) (size1 :long) (stride1 :long)
     (size2 :long) (stride2 :long))
    ("setStorage4d" set-storage-4d :void (tensor tensorptr) (storage storageptr)
     (storage-offset ptrdiff-t) (size0 :long) (stride0 :long) (size1 :long) (stride1 :long)
     (size2 :long) (stride2 :long) (size3 :long) (stride3 :long))
    ("narrow" narrow :void (tensor tensorptr) (src tensorptr) (dim :int) (first-index :long)
     (size :long))
    ("select" select :void (tensor tensorptr) (src tensorptr) (dim :int) (slice-index :long))
    ("transpose" transpose :void (tensor tensorptr) (src tensorptr) (dim1 :int) (dim2 :int))
    ("unfold" unfold :void (tensor tensorptr) (src tensorptr) (dim :int) (size :long) (step :long))
    ("squeeze" squeeze :void (tensor tensorptr) (src tensorptr))
    ("squeeze1d" squeeze-1d :void (tensor tensorptr) (src tensorptr) (dimension :int))
    ("unsqueeze1d" unsqueeze-1d :void (tensor tensorptr) (src tensorptr) (dimension :int))
    ("isContiguous" is-contiguous :int (tensor tensorptr))
    ("isSameSizeAs" is-same-size-as :int (tensor tensorptr) (src tensorptr))
    ("isSetTo" is-set-to :int (tensor tensorptr) (src tensorptr))
    ("isSize" is-size :int (tensor tensorptr) (dims th-long-storage-ptr))
    ("nElement" n-element ptrdiff-t (tensor tensorptr))
    ("retain" retain :void (tensor tensorptr))
    ("free" free :void (tensor tensorptr))
    ("freeCopyTo" free-copy-to :void (tensor tensorptr) (dst tensorptr))
    ("set1d" set-1d :void (tensor tensorptr) (index0 :long) (value real))
    ("set2d" set-2d :void (tensor tensorptr) (index0 :long) (index1 :long) (value real))
    ("set3d" set-3d :void (tensor tensorptr) (index0 :long) (index1 :long) (index2 :long)
     (value real))
    ("set4d" set-4d :void (tensor tensorptr) (index0 :long) (index1 :long) (index2 :long)
     (index3 :long) (value real))
    ("get1d" get-1d real (tensor tensorptr) (index0 :long))
    ("get2d" get-2d real (tensor tensorptr) (index0 :long) (index1 :long))
    ("get3d" get-3d real (tensor tensorptr) (index0 :long) (index1 :long) (index2 :long))
    ("get4d" get-4d real (tensor tensorptr) (index0 :long) (index1 :long) (index2 :long)
     (index3 :long))
    ("copy" copy :void (tensor tensorptr) (src tensorptr))
    ("copyByte" copy-byte :void (tensor tensorptr) (src th-byte-tensor-ptr))
    ("copyChar" copy-char :void (tensor tensorptr) (src th-char-tensor-ptr))
    ("copyShort" copy-short :void (tensor tensorptr) (src th-short-tensor-ptr))
    ("copyInt" copy-int :void (tensor tensorptr) (src th-int-tensor-ptr))
    ("copyLong" copy-long :void (tensor tensorptr) (src th-long-tensor-ptr))
    ("copyFloat" copy-float :void (tensor tensorptr) (src th-float-tensor-ptr))
    ("copyDouble" copy-double :void (tensor tensorptr) (src th-double-tensor-ptr))
    ("random" random :void (tensor tensorptr) (generator th-generator-ptr))
    ("geometric" geometric :void (tensor tensorptr) (generator th-generator-ptr) (p :double))
    ("bernoulli" bernoulli :void (tensor tensorptr) (generator th-generator-ptr) (p :double))
    ("bernoulli_FloatTensor" bernoulli-float-tensor :void (tensor tensorptr)
     (generator th-generator-ptr) (p th-float-tensor-ptr))
    ("bernoulli_DoubleTensor" bernoulli-double-tensor :void (tensor tensorptr)
     (generator th-generator-ptr) (p th-double-tensor-ptr))
    ("fill" fill :void (tensor tensorptr) (value real))
    ("zero" zero :void (tensor tensorptr))
    ("maskedFill" masked-fill :void (tensor tensorptr) (mask th-byte-tensor-ptr) (value real))
    ("maskedCopy" masked-copy :void (tensor tensorptr) (mask th-byte-tensor-ptr) (src tensorptr))
    ("maskedSelect" masked-select :void (tensor tensorptr) (src tensorptr)
     (mask th-byte-tensor-ptr))
    ("nonzero" nonzero :void (subscript th-long-tensor-ptr) (tensor tensorptr))
    ("indexSelect" index-select :void (tensor tensorptr) (src tensorptr) (dim :int)
     (index th-long-tensor-ptr))
    ("indexCopy" index-copy :void (tensor tensorptr) (dim :int) (index th-long-tensor-ptr)
     (src tensorptr))
    ("indexAdd" index-add :void (tensor tensorptr) (dim :int) (index th-long-tensor-ptr)
     (src tensorptr))
    ("indexFill" index-fill :void (tensor tensorptr) (dim :int) (index th-long-tensor-ptr)
     (value real))
    ("gather" gather :void (tensor tensorptr) (src tensorptr) (dim :int)
     (index th-long-tensor-ptr))
    ("scatter" scatter :void (tensor tensorptr) (dim :int) (index th-long-tensor-ptr)
     (src tensorptr))
    ("scatterAdd" scatter-add :void (tensor tensorptr) (dim :int) (index th-long-tensor-ptr)
     (src tensorptr))
    ("scatterFill" scatter-fill :void (tensor tensorptr) (dim :int) (index th-long-tensor-ptr)
     (value real))
    ("dot" dot acreal (tensor tensorptr) (src tensorptr))
    ("minall" min-all real (tensor tensorptr))
    ("maxall" max-all real (tensor tensorptr))
    ("medianall" median-all real (tensor tensorptr))
    ("sumall" sum-all acreal (tensor tensorptr))
    ("prodall" prod-all acreal (tensor tensorptr))
    ("add" add :void (result tensorptr) (tensor tensorptr) (value real))
    ("sub" sub :void (result tensorptr) (tensor tensorptr) (value real))
    ("mul" mul :void (result tensorptr) (tensor tensorptr) (value real))
    ("div" div :void (result tensorptr) (tensor tensorptr) (value real))
    ("lshift" lshift :void (result tensorptr) (tensor tensorptr) (value real))
    ("rshift" rshift :void (result tensorptr) (tensor tensorptr) (value real))
    ("fmod" fmod :void (result tensorptr) (tensor tensorptr) (value real))
    ("remainder" remainder :void (result tensorptr) (tensor tensorptr) (value real))
    ("clamp" clamp :void (result tensorptr) (tensor tensorptr) (minv real) (maxv real))
    ("bitand" bitand :void (result tensorptr) (tensor tensorptr) (value real))
    ("bitor" bitor :void (result tensorptr) (tensor tensorptr) (value real))
    ("bitxor" bitxor :void (result tensorptr) (tensor tensorptr) (value real))
    ("cadd" cadd :void (result tensorptr) (tensor tensorptr) (value real) (src tensorptr))
    ("csub" csub :void (result tensorptr) (tensor tensorptr) (value real) (src tensorptr))
    ("cmul" cmul :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cpow" cpow :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cdiv" cdiv :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("clshift" clshift :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("crshift" crshift :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cfmod" cfmod :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cremainder" cremainder :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cbitand" cbitand :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cbitor" cbitor :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cbitxor" cbitxor :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("addcmul" add-cmul :void (result tensorptr) (tensor tensorptr) (value real)
     (src1 tensorptr) (src2 tensorptr))
    ("addcdiv" add-cdiv :void (result tensorptr) (tensor tensorptr) (value real)
     (src1 tensorptr) (src2 tensorptr))
    ("addmv" add-mv :void (result tensorptr) (beta real) (tensor tensorptr) (alpha real)
     (maxtrix tensorptr) (vector tensorptr))
    ("addmm" add-mm :void (result tensorptr) (beta real) (tensor tensorptr) (alpha real)
     (maxtrix1 tensorptr) (matrix2 tensorptr))
    ("addr" add-r :void (result tensorptr) (beta real) (tensor tensorptr) (alpha real)
     (vector1 tensorptr) (vector2 tensorptr))
    ("addbmm" add-bmm :void (result tensorptr) (beta real) (tensor tensorptr) (alpha real)
     (batch1 tensorptr) (batch2 tensorptr))
    ("baddbmm" badd-bmm :void (result tensorptr) (beta real) (tensor tensorptr) (alpha real)
     (batch1 tensorptr) (batch2 tensorptr))
    ("match" match :void (result tensorptr) (m1 tensorptr) (m2 tensorptr) (gain real))
    ("numel" numel ptrdiff-t (tensor tensorptr))
    ("max" max :void (values tensorptr) (indices th-long-tensor-ptr) (tensor tensorptr)
     (dim :int) (keep-dim :int))
    ("min" min :void (values tensorptr) (indices th-long-tensor-ptr) (tensor tensorptr)
     (dim :int) (keep-dim :int))
    ("kthvalue" kth-value :void (values tensorptr) (indices th-long-tensor-ptr)
     (tensor tensorptr) (k :long) (dim :int) (keep-dim :int))
    ("mode" mode :void (values tensorptr) (indices th-long-tensor-ptr) (tensor tensorptr)
     (dim :int) (keep-dim :int))
    ("median" median :void (values tensorptr) (indices th-long-tensor-ptr) (tensor tensorptr)
     (dim :int) (keep-dim :int))
    ("sum" sum :void (values tensorptr) (tensor tensorptr) (dim :int) (keep-dim :int))
    ("prod" prod :void (values tensorptr) (tensor tensorptr) (dim :int) (keep-dim :int))
    ("cumsum" cum-sum :void (result tensorptr) (tensor tensorptr) (dim :int))
    ("cumprod" cum-prod :void (result tensorptr) (tensor tensorptr) (dim :int))
    ("sign" sign :void (result tensorptr) (tensor tensorptr))
    ("trace" trace acreal (tensor tensorptr))
    ("cross" cross :void (result tensorptr) (a tensorptr) (b tensorptr) (dim :int))
    ("cmax" cmax :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cmin" cmin :void (result tensorptr) (tensor tensorptr) (src tensorptr))
    ("cmaxValue" cmax-value :void (result tensorptr) (tensor tensorptr) (value real))
    ("cminValue" cmin-value :void (result tensorptr) (tensor tensorptr) (value real))
    ("zeros" zeros :void (result tensorptr) (size th-long-storage-ptr))
    ("ones" ones :void (result tensorptr) (size th-long-storage-ptr))
    ("diag" diag :void (result tensorptr) (tensor tensorptr) (k :int))
    ("eye" eye :void (result tensorptr) (n :long) (m :long))
    ("arange" arange :void (result tensorptr) (xmin acreal) (xmax acreal) (step acreal))
    ("range" range :void (result tensorptr) (xmin acreal) (xmax acreal) (step acreal))
    ("randperm" rand-perm :void (result tensorptr) (generator th-generator-ptr) (n :long))
    ("reshape" reshape :void (result tensorptr) (tensor tensorptr) (size th-long-storage-ptr))
    ("sort" sort :void (rtensor tensorptr) (itensor th-long-tensor-ptr) (tensor tensorptr)
     (dim :int) (discending-order :int))
    ("topk" topk :void (rtensor tensorptr) (itensor th-long-tensor-ptr) (tensor tensorptr)
     (k :long) (dim :int) (dir :int) (sorted :int))
    ("tril" tril :void (result tensorptr) (tensor tensorptr) (k :long))
    ("triu" triu :void (result tensorptr) (tensor tensorptr) (k :long))
    ("cat" cat :void (result tensorptr) (a tensorptr) (b tensorptr) (dim :int))
    ("catArray" cat-array :void (reuslt tensorptr) (inputs (:pointer tensorptr))
     (num-inputs :int) (dimension :int))
    ("equal" equal :int (a tensorptr) (b tensorptr))
    ("ltValue" lt-value :void (result th-byte-tensor-ptr) (tensor tensorptr) (value real))
    ("leValue" le-value :void (result th-byte-tensor-ptr) (tensor tensorptr) (value real))
    ("gtValue" gt-value :void (result th-byte-tensor-ptr) (tensor tensorptr) (value real))
    ("geValue" ge-value :void (result th-byte-tensor-ptr) (tensor tensorptr) (value real))
    ("neValue" ne-value :void (result th-byte-tensor-ptr) (tensor tensorptr) (value real))
    ("eqValue" eq-value :void (result th-byte-tensor-ptr) (tensor tensorptr) (value real))
    ("ltValueT" lt-value-t :void (result tensorptr) (tensor tensorptr) (value real))
    ("leValueT" le-value-t :void (result tensorptr) (tensor tensorptr) (value real))
    ("gtValueT" gt-value-t :void (result tensorptr) (tensor tensorptr) (value real))
    ("geValueT" ge-value-t :void (result tensorptr) (tensor tensorptr) (value real))
    ("neValueT" ne-value-t :void (result tensorptr) (tensor tensorptr) (value real))
    ("eqValueT" eq-value-t :void (result tensorptr) (tensor tensorptr) (value real))
    ("ltTensor" lt-tensor :void (result th-byte-tensor-ptr) (a tensorptr) (b tensorptr))
    ("leTensor" le-tensor :void (result th-byte-tensor-ptr) (a tensorptr) (b tensorptr))
    ("gtTensor" gt-tensor :void (result th-byte-tensor-ptr) (a tensorptr) (b tensorptr))
    ("gtTensor" ge-tensor :void (result th-byte-tensor-ptr) (a tensorptr) (b tensorptr))
    ("neTensor" ne-tensor :void (result th-byte-tensor-ptr) (a tensorptr) (b tensorptr))
    ("eqTensor" eq-tensor :void (result th-byte-tensor-ptr) (a tensorptr) (b tensorptr))
    ("ltTensorT" lt-tensor-t :void (result tensorptr) (a tensorptr) (b tensorptr))
    ("leTensorT" le-tensor-t :void (result tensorptr) (a tensorptr) (b tensorptr))
    ("gtTensorT" gt-tensor-t :void (result tensorptr) (a tensorptr) (b tensorptr))
    ("gtTensorT" ge-tensor-t :void (result tensorptr) (a tensorptr) (b tensorptr))
    ("neTensorT" ne-tensor-t :void (result tensorptr) (a tensorptr) (b tensorptr))
    ("eqTensorT" eq-tensor-t :void (result tensorptr) (a tensorptr) (b tensorptr))
    ("validXCorr2Dptr" valid-x-corr-2d-ptr :void (res realptr) (alpha real)
     (ten realptr) (ir :long) (ic :long) (k realptr) (kr :long) (kc :long)
     (sr :long) (sc :long))
    ("validConv2Dptr" valid-conv-2d-ptr :void (res realptr) (alpha real)
     (ten realptr) (ir :long) (ic :long) (k realptr) (kr :long) (kc :long)
     (sr :long) (sc :long))
    ("fullXCorr2Dptr" full-x-corr-2d-ptr :void (res realptr) (alpha real)
     (ten realptr) (ir :long) (ic :long) (k realptr) (kr :long) (kc :long)
     (sr :long) (sc :long))
    ("fullConv2Dptr" full-conv-2d-ptr :void (res realptr) (alpha real)
     (ten realptr) (ir :long) (ic :long) (k realptr) (kr :long) (kc :long)
     (sr :long) (sc :long))
    ("validXCorr2DRevptr" valid-x-corr-2d-rev-ptr :void (res realptr) (alpha real)
     (ten realptr) (ir :long) (ic :long) (k realptr) (kr :long) (kc :long)
     (sr :long) (sc :long))
    ("conv2DRevger" conv-2d-rev-ger :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long))
    ("conv2DRevgerm" conv-2d-rev-germ :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long))
    ("conv2Dger" conv-2d-ger :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv2Dmv" conv-2d-mv :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv2Dmm" conv-2d-mm :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv2Dmul" conv-2d-mul :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv2Dcmul" conv-2d-cmul :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("validXCorr3Dptr" valid-x-corr-3d-ptr :void (res realptr) (alpha real) (ten realptr)
     (it :long) (ir :long) (ic :long) (k realptr)
     (kt :long) (kr :long) (kc :long) (st :long) (sr :long) (sc :long))
    ("validConv3Dptr" valid-conv-3d-ptr :void (res realptr) (alpha real) (ten realptr)
     (it :long) (ir :long) (ic :long) (k realptr)
     (kt :long) (kr :long) (kc :long) (st :long) (sr :long) (sc :long))
    ("fullXCorr3Dptr" full-x-corr-3d-ptr :void (res realptr) (alpha real) (ten realptr)
     (it :long) (ir :long) (ic :long) (k realptr)
     (kt :long) (kr :long) (kc :long) (st :long) (sr :long) (sc :long))
    ("fullConv3Dptr" full-conv-3d-ptr :void (res realptr) (alpha real) (ten realptr)
     (it :long) (ir :long) (ic :long) (k realptr)
     (kt :long) (kr :long) (kc :long) (st :long) (sr :long) (sc :long))
    ("validXCorr3DRevptr" valid-x-corr-3d-rev-ptr :void (res realptr) (alpha real) (ten realptr)
     (it :long) (ir :long) (ic :long) (k realptr)
     (kt :long) (kr :long) (kc :long) (st :long) (sr :long) (sc :long))
    ("conv3DRevger" conv-3d-rev-ger :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (sdepth :long) (srow :long) (scol :long))
    ("conv3Dger" conv-3d-ger :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (sdepth :long) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv3Dmv" conv-3d-mv :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (sdepth :long) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv3Dmul" conv-3d-mul :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (sdepth :long) (srow :long) (scol :long)
     (vf :string) (xc :string))
    ("conv3Dcmul" conv-3d-cmul :void (result tensorptr) (beta real) (alpha real)
     (tensor tensorptr) (k tensorptr) (sdepth :long) (srow :long) (scol :long)
     (vf :string) (xc :string))))

(loop :for td :in *th-type-infos*
      :for prefix = (caddr td)
      :for real = (cadr td)
      :for acreal = (cadddr td)
      :do (loop :for fl :in *th-tensor-functions*
                :for df = (make-defcfun-tensor fl prefix real acreal)
                :do (eval df)))

;; #if defined(TH_REAL_IS_BYTE)
;; void THTensor_(getRNGState)(THGenerator *_generator, THTensor *self);
(cffi:defcfun ("THByteTensor_getRNGState" th-byte-tensor-get-rng-state) :void
  (generator th-generator-ptr)
  (tensor th-byte-tensor-ptr))

;; void THTensor_(setRNGState)(THGenerator *_generator, THTensor *self);
(cffi:defcfun ("THByteTensor_setRNGState" th-byte-tensor-set-rng-state) :void
  (generator th-generator-ptr)
  (tensor th-byte-tensor-ptr))
;; #endif /* TH_REAL_IS_BYTE */

;; #if defined(TH_REAL_IS_BYTE)
;; int THTensor_(logicalall)(THTensor *self);
(cffi:defcfun ("THByteTensor_logicalall" th-byte-tensor-logical-all) :int
  (tensor th-byte-tensor-ptr))
;; int THTensor_(logicalany)(THTensor *self);
(cffi:defcfun ("THByteTensor_logicalany" th-byte-tensor-logical-any) :int
  (tensor th-byte-tensor-ptr))
;; #endif /* TH_REAL_IS_BYTE */

(defparameter *th-float-tensor-functions*
  '(("neg" neg :void (result tensorptr) (tensor tensorptr))
    ("cinv" cinv :void (result tensorptr) (tensor tensorptr))
    ("uniform" uniform :void (tensor tensorptr) (generator th-generator-ptr)
     (a :double) (b :double))
    ("normal" normal :void (tensor tensorptr) (generator th-generator-ptr)
     (mean :double) (stdv :double))
    ("exponential" exponential :void (tensor tensorptr) (generator th-generator-ptr)
     (lam :double))
    ("cauchy" cauchy :void (tensor tensorptr) (generator th-generator-ptr)
     (median :double) (sigma :double))
    ("logNormal" log-normal :void (tensor tensorptr) (generator th-generator-ptr)
     (mean :double) (stdv :double))
    ("multinomial" multinomial :void (tensor tensorptr) (generator th-generator-ptr)
     (prob-dist tensorptr) (n-sample :int) (replacement :int))
    ("multinomialAliasSetup" multinomial-alias-setup :void
     (prob-dist tensorptr) (j th-long-tensor-ptr) (q tensorptr))
    ("multinomialAliasDraw" multinomial-alias-draw :void (tensor tensorptr)
     (generator th-generator-ptr) (j th-long-tensor-ptr) (q tensorptr))
    ("sigmoid" sigmoid :void (result tensorptr) (tensor tensorptr))
    ("log" log :void (result tensorptr) (tensor tensorptr))
    ("gamma" gamma :void (result tensorptr) (tensor tensorptr))
    ("lgamma" lgamma :void (result tensorptr) (tensor tensorptr))
    ("erf" erf :void (result tensorptr) (tensor tensorptr))
    ("erfc" erfc :void (result tensorptr) (tensor tensorptr))
    ("log1p" log1p :void (result tensorptr) (tensor tensorptr))
    ("exp" exp :void (result tensorptr) (tensor tensorptr))
    ("cos" cos :void (result tensorptr) (tensor tensorptr))
    ("acos" acos :void (result tensorptr) (tensor tensorptr))
    ("cosh" cosh :void (result tensorptr) (tensor tensorptr))
    ("sin" sin :void (result tensorptr) (tensor tensorptr))
    ("asin" asin :void (result tensorptr) (tensor tensorptr))
    ("sinh" sinh :void (result tensorptr) (tensor tensorptr))
    ("tan" tan :void (result tensorptr) (tensor tensorptr))
    ("atan" atan :void (result tensorptr) (tensor tensorptr))
    ("atan2" atan2 :void (result tensorptr) (tensorx tensorptr) (tensory tensorptr))
    ("tanh" tanh :void (result tensorptr) (tensor tensorptr))
    ("pow" pow :void (result tensorptr) (tensor tensorptr) (value real))
    ("tpow" tpow :void (result tensorptr) (value real) (tensor tensorptr))
    ("sqrt" sqrt :void (result tensorptr) (tensor tensorptr))
    ("rsqrt" rsqrt :void (result tensorptr) (tensor tensorptr))
    ("ceil" ceil :void (result tensorptr) (tensor tensorptr))
    ("floor" floor :void (result tensorptr) (tensor tensorptr))
    ("round" round :void (result tensorptr) (tensor tensorptr))
    ("abs" abs :void (result tensorptr) (tensor tensorptr))
    ("trunc" trunc :void (result tensorptr) (tensor tensorptr))
    ("frac" frac :void (result tensorptr) (tensor tensorptr))
    ("lerp" lerp :void (result tensorptr) (a tensorptr) (b tensorptr) (weight real))
    ("mean" mean :void (result tensorptr) (tensor tensorptr) (dim :int) (keep-dim :int))
    ("std" std :void (result tensorptr) (tensor tensorptr) (dim :int) (biased :int) (keep-dim :int))
    ("var" var :void (result tensorptr) (tensor tensorptr) (dim :int) (biased :int) (keep-dim :int))
    ("varall" varall :double (tensor tensorptr) (biased :int))
    ("norm" norm :void (res tensorptr) (tensor tensorptr) (value real) (dim :int) (keep-dim :int))
    ("renorm" renorm :void (res tensorptr) (tensor tensorptr) (value real) (dim :int) (maxnorm real))
    ("dist" dist acreal (a tensorptr) (b tensorptr) (value real))
    ("histc" histc :void (hist tensorptr) (tensor tensorptr) (nbins :long)
     (min-value real) (max-value real))
    ("bhistc" bhistc :void (hist tensorptr) (tensor tensorptr) (nbins :long)
     (min-value real) (max-value real))
    ("meanall" mean-all acreal (tensor tensorptr))
    ("varall" val-all acreal (tensor tensorptr) (biased :int))
    ("stdall" std-all acreal (tensor tensorptr) (biased :int))
    ("normall" norm-all acreal (tensor tensorptr) (value real))
    ("linspace" linspace :void (result tensorptr) (a real) (b real) (n :long))
    ("logspace" logspace :void (result tensorptr) (a real) (b real) (n :long))
    ("rand" rand :void (result tensorptr) (generator th-generator-ptr) (size th-long-storage-ptr))
    ("randn" randn :void (result tensorptr) (generator th-generator-ptr) (size th-long-storage-ptr))
    ("trtrs" trtrs :void (rb tensorptr) (ra tensorptr) (b tensorptr) (a tensorptr) (uplo :string) (trans :string) (diag :string))
    ("gesv" gesv :void (rb tensorptr) (ra tensorptr) (b tensorptr) (a tensorptr))
    ("gels" gels :void (rb tensorptr) (ra tensorptr) (b tensorptr) (a tensorptr))
    ("syev" syev :void (re tensorptr) (rv tensorptr) (a tensorptr) (jobz :string) (uplo :string))
    ("geev" geev :void (re tensorptr) (rv tensorptr) (a tensorptr) (jobvr :string))
    ("gesvd" gesvd :void (ru tensorptr) (rs tensorptr) (rv tensorptr) (a tensorptr) (jobu :string))
    ("gesvd2" gesvd2 :void (ru tensorptr) (rs tensorptr) (rv tensorptr) (ra tensorptr)
     (a tensorptr) (jobu :string))
    ("getri" getri :void (ra tensorptr) (a tensorptr))
    ("potrf" potrf :void (ra tensorptr) (a tensorptr) (uplo :string))
    ("potrs" potrs :void (rb tensorptr) (b tensorptr) (a tensorptr) (uplo :string))
    ("potri" potri :void (ra tensorptr) (a tensorptr) (uplo :string))
    ("qr" qr :void (rq tensorptr) (rr tensorptr) (a tensorptr))
    ("geqrf" geqrf :void (ra tensorptr) (rtau tensorptr) (a tensorptr))
    ("orgqr" orgqr :void (ra tensorptr) (a tensorptr) (tau tensorptr))
    ("ormqr" ormqr :void (ra tensorptr) (a tensorptr) (tau tensorptr) (c tensorptr)
     (side :string) (trans :string))
    ("pstrf" pstrf :void (ra tensorptr) (rpiv th-int-tensor-ptr) (a tensorptr) (uplo :string)
     (tol real))
    ("btrifact" btrifact :void (ra tensorptr) (rpivots th-int-tensor-ptr)
     (rinfo th-int-tensor-ptr) (pivot :int) (a tensorptr))
    ("btrisolve" btrisolve :void (rb tensorptr) (b tensorptr) (atf tensorptr)
     (pivots th-int-tensor-ptr))))

(loop :for td :in (last *th-type-infos* 2)
      :for prefix = (caddr td)
      :for real = (cadr td)
      :for acreal = (cadddr td)
      :do (loop :for fl :in *th-float-tensor-functions*
                :for df = (make-defcfun-tensor fl prefix real acreal)
                :do (eval df)))

(defparameter *th-blas-functions*
  '(("swap" swap :void (n :long) (x realptr) (incx :long) (y realptr) (incy :long))
    ("scal" scal :void (n :long) (a real) (x realptr) (incx :long))
    ("copy" copy :void (n :long) (x realptr) (incx :long) (y realptr) (incy :long))
    ("axpy" axpy :void (n :long) (a real) (x realptr) (incx :long) (y realptr) (incy :long))
    ("dot" dot :void (n :long) (x realptr) (incx :long) (y realptr) (incy :long))
    ("gemv" gemv :void (trans :char) (m :long) (n :long) (alpha real) (a realptr) (lda :long)
     (x realptr) (incx :long) (beta real) (y realptr) (incy :long))
    ("ger" ger :void (m :long) (n :long) (alpha real) (x realptr) (incx :long) (y realptr)
     (incy :long) (a realptr) (lda :long))
    ("gemm" gemm :void (transa :char) (transb :char) (m :long) (n :long) (k :long)
     (alpha real) (a realptr) (lda :long) (b realptr) (ldb :long) (beta real) (c realptr)
     (ldc :long))))

(loop :for td :in *th-type-infos*
      :for prefix = (caddr td)
      :for real = (cadr td)
      :for acreal = (cadddr td)
      :do (loop :for fl :in *th-blas-functions*
                :for df = (make-defcfun-blas fl prefix real acreal)
                :do (eval df)))

(defparameter *th-lapack-functions*
  '(("gesv" gesv :void (n :int) (nrhs :int) (a realptr) (lda :int) (ipiv (:pointer :int))
     (b realptr) (ldb :int) (info (:pointer :int)))
    ("trtrs" trtrs :void (uplo :char) (trans :char) (diag :char) (n :int) (nrhs :int)
     (a realptr) (lda :int) (b realptr) (ldb :int) (info (:pointer :int)))
    ("gels" gels :void (trans :char) (m :int) (n :int) (nrhs :int) (a realptr) (lda :int)
     (b realptr) (ldb :int) (work realptr) (lwork :int) (info (:pointer :int)))
    ("syev" syev :void (jobz :char) (uplo :char) (n :int) (a realptr) (lda :int) (w realptr)
     (work realptr) (lword :int) (info (:pointer :int)))
    ("geev" geev :void (jobvl :char) (jobvr :char) (n :int) (a realptr) (lda :int) (wr realptr)
     (wi realptr) (vl realptr) (ldvl :int) (vr realptr) (ldvr :int) (work realptr) (lwork :int)
     (info (:pointer :int)))
    ("gesvd" gesvd :void (jobu :char) (jobvt :char) (m :int) (n :int) (a realptr) (lda :int)
     (s realptr) (u realptr) (ldu :int) (vt realptr) (ldvt :int) (work realptr) (lwork :int)
     (info (:pointer :int)))
    ("getrf" getrf :void (m :int) (n :int) (a realptr) (lda :int) (ipiv (:pointer :int))
     (info (:pointer :int)))
    ("getrs" getrs :void (trans :char) (n :int) (nrhs :int) (a realptr) (lda :int)
     (ipiv (:pointer :int)) (b realptr) (ldb :int) (info (:pointer :int)))
    ("getri" getri :void (n :int) (a realptr) (lda :int) (ipiv (:pointer :int))
     (work realptr) (lwork :int) (info (:pointer :int)))
    ("potrf" potrf :void (uplo :char) (n :int) (a realptr) (lda :int) (info (:pointer :int)))
    ("potri" potri :void (uplo :char) (n :int) (a realptr) (lda :int) (info (:pointer :int)))
    ("potrs" potrs :void (uplo :char) (n :int) (nrhs :int) (a realptr) (lda :int) (b realptr)
     (ldb :int) (info (:pointer :int)))
    ("pstrf" pstrf :void (uplo :char) (n :int) (a realptr) (lda :int) (piv (:pointer :int))
     (rank (:pointer :int)) (tol real) (work realptr) (info (:pointer :int)))
    ("geqrf" geqrf :void (m :int) (n :int) (a realptr) (lda :int) (tau realptr) (work realptr)
     (lwork :int) (info (:pointer :int)))
    ("orgqr" orgqr :void (m :int) (n :int) (k :int) (a realptr) (lda :int) (tau realptr)
     (work realptr) (lwork :int) (info (:pointer :int)))
    ("ormqr" ormqr :void (side :char) (trans :char) (m :int) (n :int) (k :int) (a realptr)
     (lda :int) (tau realptr) (c realptr) (ldc :int) (work realptr) (lwork :int)
     (info (:pointer :int)))))

(loop :for td :in *th-type-infos*
      :for prefix = (caddr td)
      :for real = (cadr td)
      :for acreal = (cadddr td)
      :do (loop :for fl :in *th-lapack-functions*
                :for df = (make-defcfun-lapack fl prefix real acreal)
                :do (eval df)))
