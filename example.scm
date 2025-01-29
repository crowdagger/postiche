(add-to-load-path ".")
(import (scheme base)
        (scheme write)
        (postiche mustache))

(define tpl (process-template "This a {{adj}} example\n"))

(display (apply-template tpl
                         '((adj . "silly"))))


(define template1
  "* {{animal}}
* {{color}}
")
(define ctx1 '(( animal . "cat")
               (color . "orange")))

(display (apply-template (process-template template1) ctx1))

(define tpl2 (process-template "This is a {{^pred}}silly {{/pred}} example\n"))

(display (apply-template tpl2 '()))
(display (apply-template tpl2 '((pred . "whatever"))))


(define complex
  "ANIMAL NOISES
=============
{{#animals}} * {{name}}: \"{{noise}}\"
{{/animals}}
")

(define complex-ctx
  '((animals . (((name . "cat")
                 (noise . "meow"))
                ((name . "dog")
                 (noise . "woof"))
                ((name . "duck")
                 (noise . "quack"))))))



(define tpl-cplx (process-template complex))

(display (apply-template tpl-cplx complex-ctx))
