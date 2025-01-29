(add-to-load-path "..")


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

(define template2 "A little {{#pred}}{{.}}silly{{/pred}} example\n")
(define ctx2 '(( pred . "contrived and ")))
(display (apply-template (process-template template2) ctx2))

(display (apply-template (process-template template2) '(( pred . (1 2 3)))))

(define tpl2 (process-template "This is a {{^pred}}silly {{/pred}} example\n"))

(write tpl2)
(newline)

(display (apply-template tpl2 '()))
(display (apply-template tpl2 '((pred . "whatever"))))
