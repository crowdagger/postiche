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

#### Lists

Indeed, when `tag` corresponds to a list, the section will be repeated
for every element of the list.

Template:

```
Look!{{#foo}} {{.}} example!{{/foo}}
```

Context:

```scheme
'(( foo . ("An" "Another" "A final")))
```

Output:

```
Look! An example! Another example! A final example!
```

#### List of associations lists

For those who are not afraid of nested parenthesis, it is also
possible to set each individual element of the list to an association
list. In this case, it is possible to access named elements of the
current item:

Template:

```
ANIMAL NOISES
=============
{{#animals}} * {{name}}: \"{{noise}}\"
{{/animals}}
```

Context :

```scheme
'((animals . (((name . "cat")
               (noise . "meow"))
              ((name . "dog")
               (noise . "woof"))
              ((name . "duck")
               (noise . "quack")))))
```

Output: 

```
ANIMAL NOISES
=============
 * cat: "meow"
 * dog: "woof"
 * duck: "quack"
```


#### Inverted sections

Sometimes, you want something to be displayed when a value is *not*
set. In order to do this, you can mark an "inverted section" with the
`{{^tag}}...{{/tag}}` syntax.

Such "inverted section" will only be displayed if var is false or
empty, similar to the `unless` operator.

Template:

```
A little {{^pred}} silly{{/pred}} example
```

Context:

```scheme
'()
```

Output:

```
A little silly example
```

## Changing delimiters

Depending of the language you are writing in, `{{` and `}}` delimiters
might be annoying. It is possible to modify them by giving additional
argument to `process-template`:

```scheme
(define my-tpl (process-template "Some «adj» delimiters" "«" "»"))
(display (apply-template my-tpl
                         '((adj . unusual))))
; displays "Some unusual delimiters"
```


## Escaping

No HTML escaping or any escaping. 

## Compatibility 

Code is written trying to conform to R7RS, but only tested with Guile
at the moment. 

## License

GNU Lesser General Public License.
