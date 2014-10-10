// q-doc Code Documentation Generator
//  JSON Generator
// Copyright (C) 2014 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details

.qdoc.json.getFileList:{
    files:distinct value .qdoc.parseTree.source;
    funcCount:{ count where .qdoc.parseTree.source~\:x } each files;

    :enlist[`files]!enlist { `file`funcCount!(x;y) }./:flip (files;funcCount);
 };

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

.qdoc.json.error:{[msg;dict]
    if[all null dict;
        dict:()!();
    ];

    :dict,enlist[`ERROR]!enlist msg;
 };

