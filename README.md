q-doc
=====

> Code documentation generator for kdb 

This repo provides a method of writing function comments in a machine readable way along with a parser and HTML viewer of the generated documentation. 

The commenting method, along with the associated parser, is known as `q-doc`.

### Documenting Code

In order to use this documentation generator, your function comments must confirm to the schema defined in this section.

#### Method

1. Only comments preceding a function (or constant) declaration will be parsed.
   * All comments within functions will be *ignored*.
2. All q-doc comment lines should be start with a single forward slash ("/").
3. A description of the function must be the first part of the comment body. It can span 1 or more lines
4. The block-level tags below are supported by the parser. All are optional.
   * `@param` : Describes the function's input parameters
   * `@return` : Describes the function's return value (alias: `@returns`)
   * `@throws` : Describes each exception that can be thrown by the function (alias: `@exception`)
   * `@see` : Provides references to other functions that are used within the function
   * `@deprecated` : Describes a deprecated feature
5. Each block-level tag expects a certain set of information to parse correctly.
   * `/  @param paramName (paramType) Param description `
   * `/  @return (returnType) Return description `
   * `/  @throws ExceptionName Exception description `
   * `/  @see Reference `
   * `/  @deprecated Deprecation description `
6. Both `paramType` and `returnType` can support multiple types by separating with `|`
7. The inline tags below are supported by the parser.
   * `{@code ...}` : Format a one-liner as code (alias: `<code>...</code>`)
   * `{@literal ...}` : Format a one-liner as literal (alias: `<tt>...</tt>`)
   * `q) ...` : Must occur at beginning of a comment line. Format till the end of line as q code
   * `k) ...` : Must occur at beginning of a comment line. Format till the end of line as k code
8. Function and tag descriptions can contain simple HTML contents.
9. Currently a description for a tag must remain on the same line as the tag. Multi-line descriptions for tags are not supported at this time.

#### Examples

These are some examples of the documentation scheme described above.

```
/ Ensures that a string is returned to the caller, regardless of input. Useful for logging. NOTE:
/ Uses 'string' to print symbols, '.Q.s1' for all other types.
/  @param input (Atom) Any atom to ensure is a string
/  @return (String) The string representation of the atom
.util.ensureString:{[input]
```

```
/ Ensures that a symbol is returned to the caller, regardless of input.
/  @param input (Atom) Any atom to ensure is a symbol
/  @return (Symbol) The input as a symbol
/  @throws IllegalArgumentException If the input is a table, dictionary or function
.util.ensureSymbol:{[input]
```

```
/ Provides the ability to perform search and replace with multiple find and replace strings at once. NOTE: 
/ If using to replace a single string, ensure you enlist it otherwise it will be used as a list of
/ characters.
/  @param str (String) The string to find and replace in
/  @param findList (String|Char|List) The elements to find in the string
/  @param replaceList (String|Char|List) The elements to replace with
.util.findAndReplace:{[str;findList;replaceList]
```

### Generating q-doc 

The `q-doc` parser supplied within this repository, generates documentation on initialisation and stores it in-memory. It is then converted to JSON and rendered on a web page for viewing.

It requires a kdb process to be running and listening on a port in order for people to view the generated documentation.

#### Prerequisites

1. kdb+ running on Windows or Linux
2. Code with comments following the method described at the top of this document
3. A modern web-browser to view the generated output

#### Running q-doc

1. `q /path/to/q-doc.q -p 0W`
2. ``.qdoc.parser.init `:/path/to/code/to/parse``
3. Browse to `http://localhost:port/index-kdb.html`

```
c:\Temp\q-doc-master>c:\jas_apps\q\w32\q.exe q-doc.q -p 0W
KDB+ 3.1 2014.05.03 Copyright (C) 1993-2014 Kx Systems
w32/ 12()core 4095MB jrajasansir jase6230 192.168.1.14 NONEXPIRE

*****
q-doc Code Documentation Generator
Copyright (C) 2014 Jaskirat M.S. Rajasansir
License BSD, see LICENSE for details
*****

INFO: Loading c:\Temp\q-doc-master/json.k
INFO: Loading c:\Temp\q-doc-master/q-doc-config.q
INFO: Loading c:\Temp\q-doc-master/q-doc-generator.q
INFO: Loading c:\Temp\q-doc-master/q-doc-parser.q

INFO: To initialise the parser, run .qdoc.parser.init with the folder root of your code.

q)
q).qdoc.parser.init `:.
INFO: Generating q-doc parse tree for: :./json.k
INFO: Generating q-doc parse tree for: :./q-doc-config.q
INFO: Generating q-doc parse tree for: :./q-doc-generator.q
INFO: Generating q-doc parse tree for: :./q-doc-parser.q
INFO: Generating q-doc parse tree for: :./q-doc.q
INFO: Generating q-doc parse tree for: :./util.q
q)
```


[![Analytics](https://ga-beacon.appspot.com/UA-54104883-5/q-doc/README)](https://github.com/jasraj/q-doc)
