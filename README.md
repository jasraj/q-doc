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
5. Each tag expects a certain set of information to parse correctly.
   * `/  @param paramName (paramType) Param description `
   * `/  @returns (returnType) Return description `
   * `/  @throws ExceptionName Exception description `
   * `/  @see Reference `
6. Both `paramType` and `returnType` can support multiple types by separating with `|`

#### Examples

These are some examples of the documentation scheme described above.

```
/ Ensures that a string is returned to the caller, regardless of input. Useful for logging. NOTE:
/ Uses 'string' to print symbols, '.Q.s1' for all other types.
/  @param input (Atom) Any atom to ensure is a string
/  @returns (String) The string representation of the atom
.util.ensureString:{[input]
```

```
/ Ensures that a symbol is returned to the caller, regardless of input.
/  @param input (Atom) Any atom to ensure is a symbol
/  @returns (Symbol) The input as a symbol
/  @throws IllegalArgumentException If the input is a table, dictionary or function
.util.ensureSymbol:{[input]
```

```
/ Provides the ability to perform search and replace with multiple find and replace strings at once. NOTE: If using
/ to replace a single string, ensure you enlist it otherwise it will be used as a list of characters.
/  @param str (String) The string to find and replace in
/  @param findList (String|Char|List) The elements to find in the string
/  @param replaceList (String|Char|List) The elements to replace with
.util.findAndReplace:{[str;findList;replaceList]
```

[![Analytics](https://ga-beacon.appspot.com/UA-54104883-5/q-doc/README)](https://github.com/jasraj/q-doc)
