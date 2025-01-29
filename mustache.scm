(define-library (postiche mustache)
  (import (scheme base)
          (srfi srfi-13))
  (export process-template apply-template)
  (include "mustache-impl.scm"))

