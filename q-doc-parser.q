// q-doc Code Documentation Generator
//   Parser
// Copyright (C) 2014 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details


/ Stores the q-doc comment body (i.e. the lines that have not been parsed by a tag function).
/ The dictionary key is the function name and the value the list of lines that form the comment
/ body.
/  @see .qdoc.parser.parse
.qdoc.parseTree.comments:(!)."S*"$\:();

/ Stores the parsed tags for all functions and variables that have been successfully parsed by
/ the q-doc parser. This dictionary is keyed by function name. The value varies depending 
/ on the tag that has been parsed
/  @see .qdoc.parser.tags
/  @see .qdoc.parser.parse
.qdoc.parseTree.tags:(!)."S*"$\:();

/ Stores a mapping of function name and the file that it was parsed from
.qdoc.parseTree.source:(!)."SS"$\:();

/ Stores function arguments, keyed by the function name
.qdoc.parseTree.arguments:(!)."S*"$\:();

/ Stores the folder root where the q-doc parsing started from
.qdoc.parseTree.root:`;

/ Defines the supported block-level tags to be parsed. The dictionary key is the string that
/ should be identified from the file and the value is the function that should be executed
/ on lines that match.
/ <p>
/ NOTE: Tag comments must reside on the the same line as the tag
.qdoc.parser.tags:()!();
.qdoc.parser.tags[enlist"@param"]:`.qdoc.parser.tag.param;
.qdoc.parser.tags[enlist"@returns"]:`.qdoc.parser.tag.returns;
.qdoc.parser.tags[enlist"@throws"]:`.qdoc.parser.tag.throws;
.qdoc.parser.tags[enlist"@see"]:`.qdoc.parser.tag.see;
.qdoc.parser.tags[enlist"@deprecated"]:`.qdoc.parser.tag.deprecated;

/ Defines supported inline tags to be parsed. The dictionary key is the string that should
/ be identified from the file and the value is the function that should be executed on
/ lines that match.
.qdoc.parser.inlines:()!();
.qdoc.parser.inlines[("{@code";"<code>";"{@literal";"<tt>")]:`.qdoc.parser.inline.code;
.qdoc.parser.inlines[enlist"q)"]:`.qdoc.parser.inline.q;
.qdoc.parser.inlines[enlist"k)"]:`.qdoc.parser.inline.k;

/ Defines equivalent tags for compatibility.
.qdoc.parser.eqTags:()!();
.qdoc.parser.eqTags[enlist"@return"]:enlist"@returns";
.qdoc.parser.eqTags[enlist"@exception"]:enlist"@throws";

/ Generates the parse trees for all .q and .k files recursively from the specified folder root.
/  @param folderRoot Folder The root folder to parse all .q and .k files recursively from
/  @throws FolderDoesNotExistException If the specified folder does not exist
/  @see .util.isFolder
/  @see .qdoc.parser.parse
.qdoc.parser.init:{[folderRoot]
    if[not .util.isFolder folderRoot;
        .log.error "Folder does not exist! [ Folder: ",string[folderRoot]," ]";
        '"FolderDoesNotExistException (",string[folderRoot],")";
    ];

    .qdoc.parseTree.root:folderRoot;

    files:.util.tree folderRoot;
    files@:where any files like/:("*.q";"*.k");
    files:hsym each `symbol$files;

    .qdoc.parser.parse each files;

    / Post-processing, make file names relative to folder root for better UI display
    .qdoc.parseTree.source:hsym each `$ssr[;,[;"/"] string folderRoot;""] each string .qdoc.parseTree.source;
 };

/ Generates the parse tree for the specified file.
/  @param fileName File The file to parse for q-doc
/  @returns Boolean True if the parse was successful
/  @see .qdoc.parseTree.parseTags
/  @see .qdoc.parser.postProcess
.qdoc.parser.parse:{[fileName]
    .log.info "Generating q-doc parse tree for: ",string fileName;

    file:read0 fileName;
    file@:where not in [;" \t}"] first each file;

    / Remove block comments
    file:file where null{$[x=`;$[y;`C;z;`E;x];x=`C;$[z;`;x];x]}\[`] . file like/:1#/:"/\\";
    funcSignatures:file where not"/"=first each file;
    / Get default namespaces
    namespaceSwitches:funcSignatures like"\\d *";
    namespaces:fills?[namespaceSwitches;`$2_/:funcSignatures;`];

    / Recover namespace for each function
    funcAndArgs:(!). flip(({$[(~).(first;last)@\:y;`;$[(null x)or(y[0]like ".*");::;` sv x,]`$y 0]}@/:namespaces),\:last)@\:'":"vs/:funcSignatures;
    funcAndArgs:{ $[not "{["~2#x; :enlist`$"..."; :`$";" vs x where not any x in/:"{[]} "] } each funcAndArgs;

    commentLines:{last[y]+(last[y]_x)?z}[file]\[0;funcSignatures];
    commentLines:commentLines - til each deltas commentLines;
   
    / Deltas stops at 1 so first line of file gets ignored. If its a comment, manually add to list
    if["/"~first first file;
        commentLines:@[commentLines;0;,;0];
    ];

    commentsDict:key[funcAndArgs]!trim over reverse each 1_/:file commentLines;
    commentsDict:trim 1_/:/:commentsDict;

    / Translate equivalent tags
    commentsDict:{ssr[x;;]. y}\:\:/[commentsDict;flip[(key,value)@\:.qdoc.parser.eqTags],\:\:" "];

    / Translate inline tags
    commentsDict:{$[any x like/:"*",/:y[0],\:"*";get y 1;::]x}\:\:/[commentsDict;flip(value,key)@\:group .qdoc.parser.inlines];

    tagDiscovery:{ key[.qdoc.parser.tags]!where each like[x;]@/:"*",/:key[.qdoc.parser.tags],\:"*" } each commentsDict;
    tagComments:commentsDict@'tagDiscovery;
    comments:commentsDict@'(til each count each commentsDict) except' raze each tagDiscovery;
    comments:comments@'where each not "/"~/:/:first@/:/:comments;
    
    / Key of funcAndArgs / comments / tagComments are equal and must remain equal
    keysToRemove:`,.qdoc.parser.postProcess[funcAndArgs;comments;tagComments];

    if[not .util.isEmpty keysToRemove;
        .log.info "Documented objects to be ignored: ",.Q.s1 keysToRemove];
    funcAndArgs:keysToRemove _ funcAndArgs;
    comments:keysToRemove _ comments;
    tagComments:keysToRemove _ tagComments;

    tagParseTree:raze .qdoc.parser.parseTags[;tagComments] each key tagComments;
    
    .qdoc.parseTree.comments,:comments;
    .qdoc.parseTree.tags,:tagParseTree;
    .qdoc.parseTree.source,:key[funcAndArgs]!count[funcAndArgs]#fileName;
    .qdoc.parseTree.arguments,:funcAndArgs;

    :1b;
 };

/ Extracts and parses the supported tags from the q-doc body.
/  @param func Symbol The function name the documentation is currently being parsed for
/  @param tagsAndComments Dict The dictionary of function name and comments split by tag name
.qdoc.parser.parseTags:{[func;tagsAndComments]
    parseDict:key[.qdoc.parser.tags]!(count[.qdoc.parser.tags]#"*")$\:();

    funcComments:tagsAndComments func;

    parsed:{
        tagFunc:get .qdoc.parser.tags x;
        :tagFunc[z;y x];
    }[;funcComments;func] each key .qdoc.parser.tags;

    :enlist[func]!enlist key[parseDict]!parsed;
 };

/ Performs post-processing on the generated function and arguments, comments and
/ parsed tags as appropriate.
/ Currently this function removes documented objects with any function to the left of the assigment
/ and removes additions to dictionaries if there are no comments associated with them.
/  @param funcAndArgs (Dict) Functions with argument list
/  @param comments (Dict) Functions with description
/  @param tagComments (Dict) Functions with tag parsing
/  @returns (SymbolList) Functions that should be removed from the parsed results
.qdoc.parser.postProcess:{[funcAndArgs;comments;tagComments]
    / Remove documented objects with any function to the left of the assignment
    k:string key funcAndArgs;
    assignmentInFunc:key[funcAndArgs] where any each
        {(x like"*_*")and(not any x like/:"*[A-Za-z]",/:(raze each til[count x]#\:enlist"[0-9A-Za-z]"),\:"_*")}'[k],'
        (any each k in/:\:",@:");

    / Remove additions to dictionaries if no comments
    dictKeysNoComments:{ $[(any any string[x] in/:\:"[]") & (()~y); :x; :` ] }./:flip (key;value)@\:comments;
    dictKeysNoComments@:where not null dictKeysNoComments;

    / Remove any functions that are executed in the root of q-script
    nonDeclaredFuncs:key[funcAndArgs] where any "`;" in/:\:string key funcAndArgs;

    :distinct (,/)(assignmentInFunc;dictKeysNoComments;nonDeclaredFuncs);
 };


.qdoc.parser.tag.param:{[func;params]
    pDict:flip `name`types`description!"S**"$\:();

    if[()~params;
        :pDict;
    ];

    paramSplit:1_/:" " vs/:params;
    paramNames:"S"$paramSplit@\:0;
    paramDescs:" " sv/:2_/:paramSplit;

    paramTypes:paramSplit@\:1;
    paramTypes:.qdoc.parser.typeParser[func;] each paramTypes;
    
    :pDict upsert flip (paramNames;paramTypes;paramDescs);
 };

.qdoc.parser.tag.returns:{[func;return]
    rDict:`types`description!"H*"$\:();

    if[()~return;
        :rDict;
    ];

    returnSplit:1_" " vs first return;

    :key[rDict]!(.qdoc.parser.typeParser[func;returnSplit 0];" " sv 1_ returnSplit);
 };

.qdoc.parser.tag.throws:{[func;throws]
    tDict:flip `exception`description!"S*"$\:();

    if[()~throws;
        :tDict;
    ];

    throwsSplit:1_/:" " vs/:throws;
    exceptions:"S"$throwsSplit@\:0;
    exceptionsDesc:" " sv/:1_/:throwsSplit;

    :tDict upsert flip (exceptions;exceptionsDesc);
 };

.qdoc.parser.tag.see:{[func;sees]
    if[()~sees;
        :"";
    ];

    :" "sv/:1_/:" " vs/:sees;
 };

.qdoc.parser.tag.deprecated:{[func;deprecated]
    if[()~deprecated;
        :();
    ];

    :" "sv/:1_/:" " vs/:deprecated;
 };

.qdoc.parser.typeParser:{[func;types]
    types:"S"$"|" vs types where not any types in/:"()";
    
    if[not all types in key .qdoc.parser.types.input;
        .log.warn "Unrecognised data type [ Function: ",string[func]," ] [ Unrecognised Types: ",.Q.s1[types except key .qdoc.parser.types]," ]";
    ];

    :.qdoc.parser.types.output .qdoc.parser.types.input types;
 };

.qdoc.parser.escapeCode:{[line]
    ssr/[line;"&<>";("&amp;";"&lt;";"&gt;")]
 };

.qdoc.parser.inline.k_q_:{[pfx;line]
    :$[trim[line]like pfx,"*";
        "<tt>",pfx,"</tt><code>",.qdoc.parser.escapeCode[trim count[pfx]_line],"</code><br>";
        line];
 };

/ Wrap {@code k)...} in {@code <tt>k)</tt><code>...</code><br>}.
.qdoc.parser.inline.k:.qdoc.parser.inline.k_q_["k)"];

/ Wrap {@code q)...} in {@code <tt>q)</tt><code>...</code><br>}.
.qdoc.parser.inline.q:.qdoc.parser.inline.k_q_["q)"];

.qdoc.parser.sliceCode:{[leads;ends;line]
    b:min raze ss/:[line;leads];
    if[0W=b;:enlist line];
    pi:first where(b _line)like/:leads,\:"*";
    e:count[line]^x+first ss[(x:b+count leads pi)_line;ends pi];
    slices:(0,(b+0,count leads pi),min'[count[line],/:e+0,count ends pi])cut line;
    :(-1_slices),.z.s[leads;ends;last slices];
 };

/ Replace <code>{@code [^}]*}</code> with escape sequence
.qdoc.parser.inline.code:{[line]
    leads:("{@code";"<code>" ;"{@literal";"<tt>" );
    ends: (1#"}"   ;"</code>";1#"}"      ;"</tt>");
    slices:.qdoc.parser.sliceCode[leads;ends;line];
    slices:@[slices;where 1=(til count slices)mod 4;leads!L:("<code>";"<code>";"<tt>";"<tt>")];
    slices:@[slices;where 2=(til count slices)mod 4;.qdoc.parser.escapeCode trim@];
    k:where 3=(til count slices)mod 4;
    slices:@[;k;(ends,'L)!("</code>";"</code>";"</tt>";"</tt>")]@[slices;k;,;slices k-2];
    raze slices
 };
