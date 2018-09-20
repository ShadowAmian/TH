(defpackage :th.m.resnet50
  (:use #:common-lisp
        #:mu
        #:th
        #:th.image
        #:th.m.imagenet))

(in-package :th.m.resnet50)

(defparameter +model-location+ ($concat (namestring (user-homedir-pathname)) "Desktop"))

(defun read-text-weight-file (wn &optional (readp t))
  (when readp
    (let ((f (file.disk (format nil "~A/resnet50/resnet50-~A.txt" +model-location+ wn) "r"))
          (tx (tensor)))
      ($fread tx f)
      ($fclose f)
      tx)))

(defparameter *weights*
  (list :k1 (read-text-weight-file "p0")
        :g1 (read-text-weight-file "p1")
        :b1 (read-text-weight-file "p2")
        :k2 (read-text-weight-file "p3")
        :g2 (read-text-weight-file "p4")
        :b2 (read-text-weight-file "p5")
        :k3 (read-text-weight-file "p6")
        :g3 (read-text-weight-file "p7")
        :b3 (read-text-weight-file "p8")
        :k4 (read-text-weight-file "p9")
        :g4 (read-text-weight-file "p10")
        :b4 (read-text-weight-file "p11")
        :dk1 (read-text-weight-file "p12")
        :dg1 (read-text-weight-file "p13")
        :db1 (read-text-weight-file "p14")
        :k5 (read-text-weight-file "p15")
        :g5 (read-text-weight-file "p16")
        :b5 (read-text-weight-file "p17")
        :k6 (read-text-weight-file "p18")
        :g6 (read-text-weight-file "p19")
        :b6 (read-text-weight-file "p20")
        :k7 (read-text-weight-file "p21")
        :g7 (read-text-weight-file "p22")
        :b7 (read-text-weight-file "p23")
        :k8 (read-text-weight-file "p24")
        :g8 (read-text-weight-file "p25")
        :b8 (read-text-weight-file "p26")
        :k9 (read-text-weight-file "p27")
        :g9 (read-text-weight-file "p28")
        :b9 (read-text-weight-file "p29")
        :k10 (read-text-weight-file "p30")
        :g10 (read-text-weight-file "p31")
        :b10 (read-text-weight-file "p32")
        :k11 (read-text-weight-file "p33")
        :g11 (read-text-weight-file "p34")
        :b11 (read-text-weight-file "p35")
        :k12 (read-text-weight-file "p36")
        :g12 (read-text-weight-file "p37")
        :b12 (read-text-weight-file "p38")
        :k13 (read-text-weight-file "p39")
        :g13 (read-text-weight-file "p40")
        :b13 (read-text-weight-file "p41")
        :dk2 (read-text-weight-file "p42")
        :dg2 (read-text-weight-file "p43")
        :db2 (read-text-weight-file "p44")
        :k14 (read-text-weight-file "p45")
        :g14 (read-text-weight-file "p46")
        :b14 (read-text-weight-file "p47")
        :k15 (read-text-weight-file "p48")
        :g15 (read-text-weight-file "p49")
        :b15 (read-text-weight-file "p50")
        :k16 (read-text-weight-file "p51")
        :g16 (read-text-weight-file "p52")
        :b16 (read-text-weight-file "p53")
        :k17 (read-text-weight-file "p54")
        :g17 (read-text-weight-file "p55")
        :b17 (read-text-weight-file "p56")
        :k18 (read-text-weight-file "p57")
        :g18 (read-text-weight-file "p58")
        :b18 (read-text-weight-file "p59")
        :k19 (read-text-weight-file "p60")
        :g19 (read-text-weight-file "p61")
        :b19 (read-text-weight-file "p62")
        :k20 (read-text-weight-file "p63")
        :g20 (read-text-weight-file "p64")
        :b20 (read-text-weight-file "p65")
        :k21 (read-text-weight-file "p66")
        :g21 (read-text-weight-file "p67")
        :b21 (read-text-weight-file "p68")
        :k22 (read-text-weight-file "p69")
        :g22 (read-text-weight-file "p70")
        :b22 (read-text-weight-file "p71")
        :k23 (read-text-weight-file "p72")
        :g23 (read-text-weight-file "p73")
        :b23 (read-text-weight-file "p74")
        :k24 (read-text-weight-file "p75")
        :g24 (read-text-weight-file "p76")
        :b24 (read-text-weight-file "p77")
        :k25 (read-text-weight-file "p78")
        :g25 (read-text-weight-file "p79")
        :b25 (read-text-weight-file "p80")
        :dk3 (read-text-weight-file "p81")
        :dg3 (read-text-weight-file "p82")
        :db3 (read-text-weight-file "p83")
        :k26 (read-text-weight-file "p84")
        :g26 (read-text-weight-file "p85")
        :b26 (read-text-weight-file "p86")
        :k27 (read-text-weight-file "p87")
        :g27 (read-text-weight-file "p88")
        :b27 (read-text-weight-file "p89")
        :k28 (read-text-weight-file "p90")
        :g28 (read-text-weight-file "p91")
        :b28 (read-text-weight-file "p92")
        :k29 (read-text-weight-file "p93")
        :g29 (read-text-weight-file "p94")
        :b29 (read-text-weight-file "p95")
        :k30 (read-text-weight-file "p96")
        :g30 (read-text-weight-file "p97")
        :b30 (read-text-weight-file "p98")
        :k31 (read-text-weight-file "p99")
        :g31 (read-text-weight-file "p100")
        :b31 (read-text-weight-file "p101")
        :k32 (read-text-weight-file "p102")
        :g32 (read-text-weight-file "p103")
        :b32 (read-text-weight-file "p104")
        :k33 (read-text-weight-file "p105")
        :g33 (read-text-weight-file "p106")
        :b33 (read-text-weight-file "p107")
        :k34 (read-text-weight-file "p108")
        :g34 (read-text-weight-file "p109")
        :b34 (read-text-weight-file "p110")
        :k35 (read-text-weight-file "p111")
        :g35 (read-text-weight-file "p112")
        :b35 (read-text-weight-file "p113")
        :k36 (read-text-weight-file "p114")
        :g36 (read-text-weight-file "p115")
        :b36 (read-text-weight-file "p116")
        :k37 (read-text-weight-file "p117")
        :g37 (read-text-weight-file "p118")
        :b37 (read-text-weight-file "p119")
        :k38 (read-text-weight-file "p120")
        :g38 (read-text-weight-file "p121")
        :b38 (read-text-weight-file "p122")
        :k39 (read-text-weight-file "p123")
        :g39 (read-text-weight-file "p124")
        :b39 (read-text-weight-file "p125")
        :k40 (read-text-weight-file "p126")
        :g40 (read-text-weight-file "p127")
        :b40 (read-text-weight-file "p128")
        :k41 (read-text-weight-file "p129")
        :g41 (read-text-weight-file "p130")
        :b41 (read-text-weight-file "p131")
        :k42 (read-text-weight-file "p132")
        :g42 (read-text-weight-file "p133")
        :b42 (read-text-weight-file "p134")
        :k43 (read-text-weight-file "p135")
        :g43 (read-text-weight-file "p136")
        :b43 (read-text-weight-file "p137")
        :dk4 (read-text-weight-file "p138")
        :dg4 (read-text-weight-file "p139")
        :db4 (read-text-weight-file "p140")
        :k44 (read-text-weight-file "p141")
        :g44 (read-text-weight-file "p142")
        :b44 (read-text-weight-file "p143")
        :k45 (read-text-weight-file "p144")
        :g45 (read-text-weight-file "p145")
        :b45 (read-text-weight-file "p146")
        :k46 (read-text-weight-file "p147")
        :g46 (read-text-weight-file "p148")
        :b46 (read-text-weight-file "p149")
        :k47 (read-text-weight-file "p150")
        :g47 (read-text-weight-file "p151")
        :b47 (read-text-weight-file "p152")
        :k48 (read-text-weight-file "p153")
        :g48 (read-text-weight-file "p154")
        :b48 (read-text-weight-file "p155")
        :k49 (read-text-weight-file "p156")
        :g49 (read-text-weight-file "p157")
        :b49 (read-text-weight-file "p158")
        :w50 (read-text-weight-file "f159")
        :b50 (read-text-weight-file "f160")))

(defun w (wn) (getf *weights* wn))

(prn (w :k39))

;; XXX need to compare with pytorch result, layer by layer
;; especially batch normalization result
(let* ((rgb (tensor-from-png-file "data/cat.vgg16.png"))
       (input (imagenet-input rgb))
       (x  (if (eq 3 ($ndim input))
               (apply #'$reshape input (cons 1 ($size input)))
               input)))
  (prn (-> x
           (blki)
           (blkd :k2 :g2 :b2 :k3 :g3 :b3 :k4 :g4 :b4 :dk1 :dg1 :db1)
           (blk :k5 :g5 :b5 :k6 :g6 :b6 :k7 :g7 :b7)
           (blk :k8 :g8 :b8 :k9 :g9 :b9 :k10 :g10 :b10)
           (blkd :k11 :g11 :b11 :k12 :g12 :b12 :k13 :g13 :b13 :dk2 :dg2 :db2 2)
           (blk :k14 :g14 :b14 :k15 :g15 :b15 :k16 :g16 :b16)
           (blk :k17 :g17 :b17 :k18 :g18 :b18 :k19 :g19 :b19)
           (blk :k20 :g20 :b20 :k21 :g21 :b21 :k22 :g22 :b22)
           (blkd :k23 :g23 :b23 :k24 :g24 :b24 :k25 :g25 :b25 :dk3 :dg3 :db3 2)
           (blk :k26 :g26 :b26 :k27 :g27 :b27 :k28 :g28 :b28)
           (blk :k29 :g29 :b29 :k30 :g30 :b30 :k31 :g31 :b31)
           (blk :k32 :g32 :b32 :k33 :g33 :b33 :k34 :g34 :b34)
           (blk :k35 :g35 :b35 :k36 :g36 :b36 :k37 :g37 :b37)
           (blk :k38 :g38 :b38 :k39 :g39 :b39 :k40 :g40 :b40)
           (blkd :k41 :g41 :b41 :k42 :g42 :b42 :k43 :g43 :b43 :dk4 :dg4 :db4 2)
           (blk :k44 :g44 :b44 :k45 :g45 :b45 :k46 :g46 :b46)
           (blk :k47 :g47 :b47 :k48 :g48 :b48 :k49 :g49 :b49)
           ($avgpool2d 7 7 1 1)
           ($reshape ($size x 0) 2048)
           ($affine (w :w50) (w :b50))
           ($max 1))))

($avgpool2d x 7 7 1 1)
($affine x w b)

(defun blki (x)
  (-> x
      ($conv2d (w :k1) nil 2 2 3 3)
      ($bn (w :g1) (w :b1))
      ($relu)
      ($maxpool2d 3 3 2 2 1 1)))

;; XXX find correct stride size and application point
(defun blkd (x k1 g1 b1 k2 g2 b2 k3 g3 b3 dk dg db &optional (stride 1))
  (let* ((r (-> x
                ($conv2d (w dk) nil stride stride)
                ($bn (w dg) (w db))))
         (o (-> x
                ($conv2d (w k1) nil 1 1)
                ($bn (w g1) (w b1))
                ($relu)
                ($conv2d (w k2) nil stride stride 1 1)
                ($bn (w g2) (w b2))
                ($relu)
                ($conv2d (w k3) nil 1 1)
                ($bn (w g3) (w b3)))))
    ($relu ($+ o r))))

;; XXX find correct stride size and application point
(defun blk (x k1 g1 b1 k2 g2 b2 k3 g3 b3)
  (let ((r x)
        (o (-> x
               ($conv2d (w k1) nil 1 1)
               ($bn (w g1) (w b1))
               ($relu)
               ($conv2d (w k2) nil 1 1 1 1)
               ($bn (w g2) (w b2))
               ($relu)
               ($conv2d (w k3) nil 1 1)
               ($bn (w g3) (w b3)))))
    ($relu ($+ o r))))
