(add-to-load-path "..")
(install-r7rs!)

(import (scheme base)
        (srfi srfi-64)
        (postiche mustache))


(test-begin "template")
(test-group "process-template"
  (define tpl1 (process-template "foo"))
  (test-equal tpl1 '("foo"))
  (test-error (process-template "foo{{bar"))
  (define tpl2 (process-template "foo{{bar}}baz"))
  (test-equal tpl2 '("foo" bar "baz"))
  ;; Test that spaces are trimmed
  (define tpl3 (process-template "foo{{ bar   }}baz"))
  (test-equal tpl3 tpl2)

  ;; Test changing delimiter
  (define tpl4 (process-template"foo< bar>baz" "<" ">"))
  (test-equal tpl2 tpl4)
  )

(test-group "apply-template"
  (define tpl2 (process-template "foo{{bar}}baz"))
  (test-equal (apply-template tpl2 '((bar . "42"))) "foo42baz")
  (test-error (apply-template tpl2 '((foo . 42))))
  )
(test-end "template")
