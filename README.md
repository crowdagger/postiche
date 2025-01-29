# Postiche

Minimal scheme implementation of string templates inspired by
[mustache](https://mustache.github.io/).


## Usage

Put `{{stuff}}` inside of strings and it will be replaced by some
other stuff:

```scheme
(import (scheme base)
        (scheme write)
        (postiche mustache))

;; "Compile" the string template (it's just a list but whatever)
(define tpl (process-template "This a {{adj}} example\n"))

;; Provide a context (as an association list) to the template
(display (apply-template tpl
                         '((adj . "silly"))))

```

will display "This is a silly example". Yay!


## Syntax

Syntax is inspired by mustache, but everything is not (and won't be)
implemented. 

* `{{var}}` will be replaced by the value of `var`
* `{{^var}}...{{/var}}` will only be displayed if var is not false or empty
* That's all for now!

## Escaping

No HTML escaping or any escaping. 

## Compatibility 

Code is written trying to conform to R7RS, but only tested with Guile
at the moment. 

## License

GNU Lesser General Public License.
