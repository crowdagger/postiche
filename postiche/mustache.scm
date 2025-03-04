(define-library (postiche mustache)
  (import (scheme base)
          (scheme write)
          (srfi srfi-11)
          (srfi srfi-13)
          (srfi srfi-14)
          (srfi srfi-28)
          (ice-9 match))
  (export process-template apply-template alist?
          assoc-deep assoc-str)
  (begin
    (define (alist? x)
      "Returns #t if x is a valid list of (x . y) pairs"
      (match x
        ('() #t)
        (((foo . bar) . rest)
         (if (or (eq? '() foo)
                  (eq? '() bar))
             #f
             (alist? rest)))
      (_ #f)))

    (define (assoc-deep keys alist)
      "Like assoc, but search with a list of keys in a possibly
nested alist"
      (if (null? keys)
          alist
          (if (not (list? alist))
              (error "Not an AList" alist)
              (let* ([key (car keys)]
                     [rest (cdr keys)]
                     [value (assoc key alist)])
                (display "Looking for ")
                (display key)
                (newline)
                (if (eq? #f value)
                    #f ; Found no value, return false
                    (assoc-deep rest ; Found value, look deeper
                                (cdr value)))))))

    ;;; string-split isn't in SRFI-13, so we have to use string-tokenize instead
    (define _char-set (char-set-complement (char-set #\.)))
    
    (define (assoc-str str alist)
      "Get the key identified by the symbols present in str, separated by .

Example:
(assoc-str \"foo.bar\" alist) ===
(assoc 'bar (assoc 'foo alist))"
      (let* ([keys (string-tokenize str _char-set)]
             [keys (map string->symbol
                        keys)])
        (display "keys: ")
        (display keys)
        (newline)
        (assoc-deep keys alist)))
                 
    
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
      (let*-values ([(special tag closing) (unwrap-tag tag o-d c-d)]
                    [(before after) (find-closing-tag s closing)])
        (cons (list (case special
                     [(#{#}#) 'for]
                     [(^) 'unless])
                    (string->symbol tag)
                    (find-opening before o-d c-d))
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

    (define (ctx-add-value v ctx)
      "Adds a singe value (bound to '.) to ctx"
      (append `(( ,(string->symbol ".") . ,(format "~a" v)))
              ctx))

    (define (ctx-add-alist a ctx)
      (append a ctx))

    (define (apply-to-element x context)
      (cond
       [(string? x) x]
       [(eq? x '.) ; special case for "." lookup
        (let ([v (assoc x context)])
          (if v
              (cdr v)
              (error "Context does not include key"
                     x context)))]
       [(symbol? x)
        (let* ([s (symbol->string x)]
               [v (assoc-str s context)])
          (if v
              v
              (error "Context does not include key"
                     x context)))]
       [(list? x)
        ;; Special cases are more complicated
        (match x
          [('for tag sub)
           (let ([v (assoc tag context)])
             (if (or (eq? #f v)
                     (eq? #f (cdr v))
                     (eq? '() (cdr v)))
                 ""
                 (let lp ([v (cdr v)]
                          [rest '()])
                   (cond
                    [(not (list? v)) ;
                     (if (eq? rest '())
                         (apply-template sub
                                         (ctx-add-value v context))
                         (string-append
                          (apply-template sub
                                          (ctx-add-value v context))
                          (lp (car rest) (cdr rest))))]
                    [(eq? '() v)
                     ""]
                    [(alist? (car v)) ; v should be a list of alist
                     (lp (car v) (cdr v))]
                    [(alist? v)
                     (if (eq? rest '())
                         (apply-template sub
                                         (ctx-add-alist v context))
                         (string-append
                          (apply-template sub
                                          (ctx-add-alist v context))
                          (lp (car rest) (cdr rest))))]
                    [(not (pair? (car v))) ; v is a single list
                     (lp (car v) (cdr v))]
                    [else (error "Wrong value for context value" v)]
                     ))))]
          
          [('unless tag sub)
           (let ([v (assoc tag context)])
             (if (or (eq? #f v)
                     (eq? #f (cdr v))
                     (eq? '() (cdr v)))
                 (apply-template sub context)
                 ""))]
          [_ (error "WTF?!" x)]
          )]
       [else (error "Template should be a list of string and symbols" x)]))
    
    (define (apply-template template context)
      "Apply template with values given by context

Context must be an association list"
      (apply string-append
             (map (lambda (x)
                    (apply-to-element x context))
                  template)))
    
    ))

