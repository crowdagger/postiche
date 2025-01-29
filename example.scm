(add-to-load-path "..")


(import (scheme base)
        (scheme write)
        (postiche mustache))

(define tpl (process-template "This a {{adj}} example\n"))

(display (apply-template tpl
                         '((adj . "silly"))))

(write (process-template "This is a {{#adj}} {{name}}example{{/adj}} \n"))
(newline)
