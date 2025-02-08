(add-to-load-path ".")
(import (scheme base)
        (srfi srfi-64)
        (postiche mustache))


(test-begin "template")
(test-group "assoc-deep"
  (define alist
    '((a . 42)
      (b . ((a . 0)))))

  (test-equal 42 (assoc-deep '(a) alist))
  (test-equal #f (assoc-deep '(c) alist))
  (test-equal 0 (assoc-deep '(b a) alist))
  (test-error (assoc-deep '(a b c) alist))
  )

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

  (define tpl-if (process-template "A {{#bar}}silly {{/bar}}test"))
  (test-equal "A test" (apply-template tpl-if '()))
  (test-equal "A silly test" (apply-template tpl-if '(( bar . "foo" ))))

  (define tpl-if2 (process-template "A {{#bar}}silly {{.}}{{/bar}}test"))
  (test-equal "A test" (apply-template tpl-if2 '()))
  (test-equal "A silly foo test" (apply-template tpl-if2 '(( bar . "foo " ))))

  (define tpl-for1 (process-template "Look!{{#foo}} {{.}} example!{{/foo}}"))
  (test-equal "Look! An example! Another example! A final example!"
    (apply-template tpl-for1 '(( foo . ("An" "Another" "A final"))))) 
  
  (define tpl-unless (process-template "A {{^bar}}silly {{/bar}}test"))
  (test-equal "A silly test" (apply-template tpl-unless '()))
  (test-equal "A test" (apply-template tpl-unless '((bar . "whatever"))))
  (define tpl-unless2 (process-template "A {{^bar}}{{adj}} {{/bar}}test"))
  (test-equal "A less silly test" (apply-template tpl-unless2 '((adj . "less silly"))))
  (test-equal "A test" (apply-template tpl-unless2 '((bar . "whatever")
                                                          (adj . "less silly"))))

  (define complex
  "{{#animals}} * {{name}}: \"{{noise}}\"
{{/animals}}")
  
  (define complex-ctx
  '((animals . (((name . "cat")
                 (noise . "meow"))
                ((name . "dog")
                 (noise . "woof"))
                ((name . "duck")
                 (noise . "quack"))))))



  (define tpl-cplx (process-template complex))
  (test-equal " * cat: \"meow\"
 * dog: \"woof\"
 * duck: \"quack\"
"
    (apply-template tpl-cplx complex-ctx))


  (define my-tpl (process-template "Some «adj» delimiters" "«" "»"))
  (test-equal "Some unusual delimiters"
               (apply-template my-tpl '((adj . "unusual"))))
  )




(test-end "template")
