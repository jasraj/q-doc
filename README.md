q-doc
=====

> Code documentation generator for kdb 

This repo provides a method of writing function comments in a machine readable way along with a parser and HTML viewer of the generated documentation. 

The commenting method, along with the associated parser, is known as `q-doc`.

**NOTE**: The code + README are a WIP. Feel free to look around but there are still bugs and the README definitely isn't finished yet.

### Documenting Code

In order to use this documentation generator, your function comments must confirm to the schema defined in this section.

#### Method

1. Only comments preceding a function (or constant) declaration will be parsed.
   * All comments within functions will be *ignored*.
2. All q-doc comment lines should be start with a single forward slash ("/").
3. A description of the function must be the first part of the comment body. It can span 1 or more lines
4. The tags below are supported by the parser. All are optional.
   * `@param` : Describes the function's input parameters
   * `@returns` : Describes the function's return value
   * `@throws` : Describes each exception that can be thrown by the function
   * `@see` : Provides references to other functions that are used within the function

#### Examples

[![Analytics](https://ga-beacon.appspot.com/UA-54104883-5/q-doc/README)](https://github.com/jasraj/q-doc)
