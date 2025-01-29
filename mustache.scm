(define-library (postiche mustache)
  (import (scheme base)
          (scheme write)
          (srfi srfi-11)
          (srfi srfi-13)
          (ice-9 match))
  (export process-template apply-template)
  (begin
    (define (unwrap-tag tag o-d c-d)
      "Unwrap a tag starting with # or ^ and returns multiple values:
* the special character (e.g. '^ or '#{#}#)
* the tag itself (e.g. foo)
* the string to search to match for closing tag (e.g. \"{{/foo}}"
      (let* ([special (string->symbol (substring tag 0 1))]
             [tag (substring tag 1)]
             [closing (string-append o-d
                                     "/"
                                     tag
                                     c-d)])
        (values special tag closing)))
    
    (define (find-closing-tag s closing)
      "Parse string s until closing, and returns two values:
* the substring BEFORE closing
* the substring AFTER closing"
      (let ([b (string-contains s closing)])
        (if (not b)
            (error "Template ended expecting closing tag" closing s)
            (let ([before (substring s 0 b)]
                  [after (substring s
                                    (+ (string-length closing)
                                       b))])
              (values before after)))))
    
    
    (define (handle-hard tag s o-d c-d)
      "Hande complex cases such as conditionals or lists."
      (display "Handling ")
      (display tag)
      (newline)
      (let*-values ([(special tag closing) (unwrap-tag tag o-d c-d)]
                    [(before after) (find-closing-tag s closing)])
        (cons (list (case special
                     [(#{#}#) 'for]
                     [(^) 'unless])
                    (string->symbol tag)
                    (begin (display "before: ")
                           (display before)
                           (newline)
                           (find-opening before o-d c-d)))
              (find-opening after
                            o-d
                            c-d))
        ))
    
    (define (find-closing s o-d c-d)
      "Search a string for the closing delimiter and returns ???"
      (let ([b (string-contains s c-d)])
        (if (not b)
            (error "Unmatched template's opening delimiter" s)
            (let ([tag (string-trim-both (substring s 0 b)
                                         #\ )]
                  [string-rest (substring s
                                          (+ (string-length c-d)
                                             b))])
              (cond [(or (string-prefix? "#" tag)
                         (string-prefix? "^" tag))
                     (handle-hard tag string-rest o-d c-d)]
                    [else (cons (string->symbol tag)
                                (find-opening string-rest
                                              o-d
                                              c-d))])))))
    
    (define (find-opening s o-d c-d)
      "Search a strïng for opening delimiter and returns ???"
      (let ([b (string-contains s o-d)])
        (if (not b)
            (list s)
            (cons (substring s 0 b)
                  (find-closing
                   (substring s (+ (string-length o-d)
                                   b))
                   o-d
                   c-d)))))
    
    (define (process-template string . rest)
      "Transform a template to a list of substrings and symbols.

Additional parameters may include strings for opening and closing delimiters"
      (unless (string? string)
        (error "Template must be a string" string))
      (let ([o-d
             (if (> (length rest) 0)
                 (if (string? (car rest))
                     (car rest)
                     (error "Opening delimiter must be a string" (car rest)))
                 "{{")]
            [c-d
             (if (> (length rest) 1)
                 (if (string? (cadr rest))
                     (cadr rest)
                     (error "Closing delimiter must be a string"
                            (cadr rest)))
                 "}}")])
        (find-opening string o-d c-d)))
    
    (define (apply-template template context)
      "Apply template with values given by context

Context must be an association list"
      (apply string-append
             (map (lambda (x)
                    (cond
                     [(string? x) x]
                     [(symbol? x)
                      (let ([v (assoc x context)])
                        (if v
                            (cdr v)
                            (error "Context does not include key"
                                   x)))]
                     [(list? x)
                      ;; Special cases are more complicated
                      (match x
                        [('unless tag sub)
                         (let ([v (assoc tag context)])
                           (if (or (eq? #f v)
                                   (eq? '() v))
                               ""
                               (apply-template sub context)))]
                        [_ (error "WTF?!" x)]
                        )]
                     [else (error "Template should be a list of string and symbols" template)]))
                  template)))
    
    ))

