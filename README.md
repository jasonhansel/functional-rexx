# Functional REXX

A set of procedures that implement the basics of functional programming &ndash; as in languages like LISP and Haskell &ndash; in the REXX language.

In particular, it provides the following features:

* Anonymous, first-class functions (called using a special `?` procedure)
	* Basically, procedures can be stored in variables
	* This allows for higher-order procedures: procedures whose arguments or return values are themselves procedures
* Simple partial application (currying)
	* This makes it easy to make simple procedures from more complex ones
* `car`, `cdr`, and `cons` from LISP
	* This allows for the creation of more complicated data types (especially linked lists)
* Conversion between REXX stem variables and LISP-style linked lists
	* This provides somewhat greater interoperability
* Lexical scope (kind of)

However, attempting to do this in REXX causes several issues:

* Performance will likely be an issue, since the library uses `INTERPRET` to perform function calls
* REXX's relatively low call stack limit (100) prevents the use of recursion for most tasks
* As REXX lacks true compound data types, all data must be stored in strings (ugh)
* Lexical scope is possible, but it is hardly elegant

In general, this is probably more of a hack than something of great practical value. Still, it is interesting to see how functional programming can be implemented in a language like REXX.

## Why REXX?

In the first place, REXX is frequently used to complete the sorts of data processing tasks for which functional programming can be suitable. Secondly, this provides a way of allowing more powerful REXX programs without needing to implement OOP (which is unavailable on some REXX platforms).

In the second place, why not?

## Inspiration

* Ramda, a functional programming library for JavaScript
* Scheme, a LISP dialect
* PHP's closure syntax
