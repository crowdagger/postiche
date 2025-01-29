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
  (define tpl4 (process-template "foo< bar>baz" "<" ">"))
  (test-equal tpl2 tpl4)

  ;; Test for
  (test-error (process-template "foo{{#bar))baz"))
  (define tpl5 (process-template "foo{{#bar}}baz{{/bar}}quux"))
  (test-equal '("foo" (for bar ("baz")) "quux")
    tpl5)

    ;; Test unless
  (test-error (process-template "foo{{^bar))baz"))
  (define tpl6 (process-template "foo{{^bar}}baz{{/bar}}quux"))
  (test-equal '("foo" (unless bar ("baz")) "quux")
    tpl6)
  )

(test-group "apply-template"
  (define tpl2 (process-template "foo{{bar}}baz"))
  (test-equal (apply-template tpl2 '((bar . "42"))) "foo42baz")
  (test-error (apply-template tpl2 '((foo . 42))))
  
  (define tpl-unless (process-template "A {{^bar}}silly {{/bar}}test"))
  (test-equal "A test" (apply-template tpl-unless '()))
  (test-equal "A silly test" (apply-template tpl-unless '((bar . "whatever"))))
  (define tpl-unless2 (process-template "A {{^bar}}{{adj}} {{/bar}}test"))
  (test-equal "A test" (apply-template tpl-unless2 '((adj . "less silly"))))
  (test-equal "A less silly test" (apply-template tpl-unless2 '((bar . "whatever")
                                                          (adj . "less silly"))))
  )
(test-end "template")
