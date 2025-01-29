(add-to-load-path "..")


(import (scheme base)
        (scheme write)
        (postiche mustache))

(define tpl (process-template "This a {{adj}} example\n"))

(display (apply-template tpl
                         '((adj . "silly"))))
