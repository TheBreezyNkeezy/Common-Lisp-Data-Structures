(in-package :data-structures)

(defparameter +init-num-buckets+ 10)

(defclass general-hashmap ()
  ((items :initform 0 :accessor .items)
   (capacity :initform 0 :accessor .capacity))
  (:documentation "The basic class for a hashmap."))

(defclass array-hashmap (general-hashmap)
  ((array-buckets :initform (make-array 0 :element-type 'array-bucket :fill-pointer 0)
                  :accessor .buckets))
  (:documentation "A hashmap that takes care of collisions by using buckets made of vectors of key-value pairs."))

(defstruct array-bucket
  (pairs (make-array 0 :element-type 'k&v :fill-pointer 0)))

(defstruct k&v key value)

(defclass linked-hashmap (general-hashmap)
  ((linked-buckets :initform nil))
  (:documentation "A hashmap that takes care of collisions by using buckets made of a doubly-linked list of key-value pairs."))

(defun new-array-hashmap () (make-instance 'array-hashmap))
(defun new-linked-hashmap () (make-instance 'linked-hashmap))

(defgeneric createhm (&key table-class key-type val-type))
(defgeneric clearhm (hm))
(defgeneric inserthm (key val hm))
(defgeneric resizehm (hm))
(defgeneric gethm (key hm))
(defgeneric removehm (key hm))
(defgeneric iterhm (hm))
(defgeneric drainhm (hm))
(defgeneric mergehm (hm1 hm2))
(defgeneric copyhm (hm))
(defgeneric see-keyhm? (key hm))
(defgeneric see-valuehm? (val hm))
(defgeneric emptyhm? (hm))
(defgeneric near-fullhm? (hm))

(defmethod clearhm ((hm array-hashmap))
  (cond ((emptyhm? hm) nil)
        (t (setf (fill-pointer (.buckets hm)) 0
                 (.items hm) 0)
           (values (delete-if #'identity (.buckets hm)) t))))

(defmethod inserthm (key val (hm array-hashmap))
  (if (or (emptyhm? hm) (near-fullhm? hm))
      (inserthm key val (resizehm hm))
      (let ((index (mod (sxhash key) (length (.buckets hm)))))
        (block replacement
          (loop :for pair :across (array-bucket-pairs (aref (.buckets hm) index))
                :do (when (equalp key (k&v-key pair))
                      (setf (k&v-value pair) val)
                      (return-from replacement (values val t))))
          (vector-push-extend (make-k&v :key key :value val)
                              (array-bucket-pairs (aref (.buckets hm) index)))
          (incf (.items hm))
          (return-from replacement (values val nil))))))

(defmethod resizehm ((hm array-hashmap))
  (let ((target-size (if (zerop (length (.buckets hm)))
                         +init-num-buckets+
                         (* 2 (length (.buckets hm))))))
    (let ((new-buckets (make-array 0
                                   :element-type 'array-bucket
                                   :fill-pointer t
                                   :adjustable t)))
      (dotimes (i target-size)
        (vector-push-extend (make-array-bucket) new-buckets))
      (loop :for bucket :across (.buckets hm)
            :do (loop :for pair :across (array-bucket-pairs bucket)
                      :do (let ((key (k&v-key pair)))
                            (let ((index (mod (sxhash key) (length new-buckets))))
                              (vector-push-extend pair (array-bucket-pairs (aref new-buckets index)))))))
      (setf (.buckets hm) new-buckets
            (.capacity hm) target-size))
    (.buckets hm)))

(defmethod gethm (key (hm array-hashmap))
  (if (not (emptyhm? hm))
      (let ((search-index (mod (sxhash key) (length (.buckets hm)))))
        (block find
          (loop :for pair :across (array-bucket-pairs (aref (.buckets hm) search-index))
                :do (when (equalp key (k&v-key pair))
                      (return-from find (values (k&v-value pair) t))))
          (return-from find (values nil nil))))
      (values nil 'empty)))

(defmethod removehm (key (hm array-hashmap))
  (if (not (emptyhm? hm))
      (let ((search-index (mod (sxhash key) (length (.buckets hm)))))
        (block find-and-delete
          (loop :for pair :across (array-bucket-pairs (aref (.buckets hm) search-index))
                :do (when (equalp key (k&v-key pair))
                      (decf (.items hm))
                      (return-from find-and-delete
                        (values (k&v-value pair)
                                (delete pair (array-bucket-pairs (aref (.buckets hm) search-index)))
                                t))))
          (return-from find-and-delete (values nil nil))))
      (values nil 'empty)))

(defmethod iterhm ((hm array-hashmap))
  "Returns a vector of dotted pairs to iterate over"
  (if (not (emptyhm? hm))
      (let ((vec (make-array 0
                             :element-type 'cons
                             :fill-pointer t
                             :adjustable t)))
        (loop :for bucket :across (.buckets hm)
              :append (loop :for pair :across (array-bucket-pairs bucket)
                            :collect (cons (k&v-key pair) (k&v-value pair)))
              :into list-of-pairs
              :finally (loop :for pair :in list-of-pairs
                             :do (vector-push-extend pair vec)))
        vec)
      (values nil 'empty)))

(defmethod drainhm ((hm array-hashmap))
  (cond ((not (emptyhm? hm))
         (let ((vec (make-array 0
                                :element-type 'cons
                                :fill-pointer t
                                :adjustable t)))
           (loop :for bucket :across (.buckets hm)
                 :append (loop :for pair :across (array-bucket-pairs bucket)
                               :collect (cons (k&v-key pair) (k&v-value pair)))
                 :into list-of-pairs
                 :finally (loop :for pair :in list-of-pairs
                                :do (vector-push-extend pair vec)))
           (values (delete-if #'identity (.buckets hm)) vec)))
        (t nil)))

(defmethod mergehm ((hm1 array-hashmap) (hm2 array-hashmap))
  (cond ((emptyhm? hm2) (.buckets hm1))
        (t (loop :for bucket :across (.buckets hm2)
                 :do (loop :for pair :across (array-bucket-pairs bucket)
                           :do (inserthm (k&v-key pair) (k&v-value pair) hm1)))
           (.buckets hm1))))

(defmethod emptyhm? ((hm array-hashmap))
  (zerop (length (.buckets hm))))

(defmethod near-fullhm? ((hm array-hashmap))
  (> (.items hm) (* 3/4 (length (.buckets hm)))))
