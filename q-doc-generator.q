// q-doc Code Documentation Generator
//  JSON Generator
// Copyright (C) 2014 - 2018 Jaskirat Rajasansir
// License BSD, see LICENSE for details

/ Gets all the files that have been parsed by the q-doc system and the number of documented entries per file
/  @returns (Dict) Single key dictionary 'files' with a table of files and documented entries
.qdoc.json.getFileList:{
    files:distinct value .qdoc.parseTree.source;
    funcCount:{ count where .qdoc.parseTree.source~\:x } each files;

    :enlist[`files]!enlist `file xasc flip `file`funcCount!(files;funcCount);
 };

/ Gets the parse tree for the specified file returned in a format ready for converting to JSON.
/  @param file (FilePath) The path of the file to get the parse tree for
/  @returns (Dict) Single key dictionary 'qdoc' with a table with each row a documented entry
/  @see .qdoc.json.error
.qdoc.json.getQDocFor:{[file]
    if[10h~type file;
        file:hsym `symbol$file;
    ];

    if[not file in distinct value .qdoc.parseTree.source;
        .log.error "Invalid file specified [ File: ",string[file]," ]";
        :.qdoc.json.error[;enlist[`file]!enlist file] "Invalid file specified";
    ];

    funcs:where .qdoc.parseTree.source~\:file;
    comments:funcs#.qdoc.parseTree.comments;
    tags:funcs#.qdoc.parseTree.tags;
    args:funcs#.qdoc.parseTree.arguments;

    doc:{[f;c;t;a] 
        funcAndArgs:`func`arguments`comments!(f;a f;c f);
        docTags:(!).({`$1_/:key x};value)@\:t f;
        
        :funcAndArgs,docTags;

    }[;comments;tags;args] each funcs;

    :enlist[`qdoc]!enlist doc;
 };

/ Gets all the file and q-doc information in a single function
/  @see .qdoc.json.getFileList
/  @see .qdoc.json.getQDocFor
.qdoc.json.getAll:{
    :enlist[`allDocs]!enlist { x,.qdoc.json.getQDocFor x`file } each .qdoc.json.getFileList[]`files;
 };

/ Generates an error dictionary in case any parsing fails
/  @param msg (String) The error message
/  @param dict (Dict) Any related objects to help assist with debugging the issue
/  @returns (Dict) An error dictionary for conversion to JSON
.qdoc.json.error:{[msg;dict]
    if[all null dict;
        dict:()!();
    ];

    :dict,enlist[`ERROR]!enlist msg;
 };

/  @returns (Dict) The company and application name for use in the HTML page
.qdoc.json.getHeaderDetails:{
    :`company`appName!.qdoc.cfg`companyNameStr`appNameStr;
 };
