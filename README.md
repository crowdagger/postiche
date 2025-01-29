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

### Variables 
`{{var}}` will be replaced by the value of `var` as provided in the
context. 

Unlike (real) Mustache, there is no HTML escaping. 

Template:

```
* {{animal}}
* {{color}}
```

Context:

```scheme
'(( animal . "cat")
  ( color . "orange"))
```

Output:
```
* cat
* orange
```

### Sections

Sections allow for conditionals and/or list. A section starts with
`{{#tag}}` and ends with `{{/tag}}`. The inner part will be rendered
zero, one, or more times, depending of the value of `tag` in context.

#### False values

If `tag` is not present, or its value is `#f` or `()`, the section
simply won't be rendered:

Template:

```
A little {{#pred}} silly{{/pred}} example
```

Context:

```scheme
'(( pred . #f )) ;; an empty ( '() ) context gives same results
```

Output:

```
A little example
```

#### Non false atoms

If the tag evaluates to a string or an atom, the section content will
be rendered:

```
A little {{#pred}} silly{{/pred}} example
```

Context:

```scheme
'(( pred . "whatever" )) 
```

Output:

```
A little silly example
```

Inside of the section, the value correponding to the tag can also be
accessed with the `{{.}}` syntax: 

```
A little {{#pred}}{{.}}silly{{/pred}} example
```

Context:

```scheme
'(( pred . "contrived and" )) 
```

Output:

```
A little contrived and silly example
```

This syntax is, however, more useful if the value is a list.




* `{{^var}}...{{/var}}` will only be displayed if var is not false or empty
* That's all for now!

## Escaping

No HTML escaping or any escaping. 

## Compatibility 

Code is written trying to conform to R7RS, but only tested with Guile
at the moment. 

## License

GNU Lesser General Public License.
