#|
  This file is a part of data-structures project.
|#

(defsystem "data-structures-test"
  :defsystem-depends-on ("prove-asdf")
  :author ""
  :license ""
  :depends-on ("data-structures"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "data-structures"))))
  :description "Test system for data-structures"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
