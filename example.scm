(add-to-load-path "..")


(import (scheme base)
        (scheme write)
        (postiche mustache))

(define tpl (process-template "This a {{adj}} example\n"))

(display (apply-template tpl
                         '((adj . "silly"))))


(define tpl2 (process-template "This is a {{^pred}}silly {{/pred}} example\n"))

(write tpl2)
(newline)

(display (apply-template tpl2 '()))
(display (apply-template tpl2 '((pred . "whatever"))))
