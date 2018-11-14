// q-doc Code Documentation Generator
//  Initialisation
// Copyright (C) 2014 - 2018 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details


/ The root folder of the q-doc library
.qdoc.cfg.folderRoot:`;

/ The arguments passed into the process. This defines how the q-doc generator should be initialised
.qdoc.cfg.args:()!();

/ The core libraries that should be loaded from kdb-common prior to loading the q-doc library itself
.qdoc.cfg.coreLibraries:`util`file;

/ A string to define the company using the q-doc application. Used on the HTML page
.qdoc.cfg.companyNameStr:"Company";

/ A string to define the application that the q-doc has been generated for. Used on the HTML page
.qdoc.cfg.appNameStr:"Application Name";


/ Initialisation function when the q-doc system is started directly on the command line (without any
/ pre-existing kdb-common interfaces present)
/  @see .qdoc.init
.qdoc.standaloneInit:{
	system "c 100 500";

	-1 "*****";
	-1 "q-doc Code Documentation Generator";
	-1 "Copyright (C) 2014 - 2018 Jas Rajasansir";
	-1 "License BSD, see LICENSE for details";
	-1 "*****\n";

    .qdoc.cfg.folderRoot:first ` vs hsym .z.f;

    requirePath:` sv .qdoc.cfg.folderRoot,(`$"kdb-common"),`src`require.q;

    system "l ",1_ string requirePath;
    .require.init .qdoc.cfg.folderRoot;

    if[not `j in key`;
        .require.lib `json;
    ];

    .require.lib each .qdoc.cfg.coreLibraries;

    .qdoc.init[];

    $[.util.isListening[];
        .log.info "Process is listening on port ",string system "p";
        .log.warn "This process is not bound to any port. Please restart the process with the '-p' flag or use '\\p'."
    ];

    -1 "\nTo initialise the parser, run .qdoc.parser.init `:/path/to/code/folder/root\n";
    -1 "After running the parser, browse to http://",string[.z.h],":",string[system "p"],"/index-kdb.html to view the generated documentation\n";

 };

/ Initialisation function of just the q-doc system itself, assuming that all requisite libraries are loaded
/ and ready for use
/  @throws NoQDocFolderRootException If the q-doc folder root has not been set when this function is called
.qdoc.init:{
    if[null .qdoc.cfg.folderRoot;
        '"NoQDocFolderRootException";
    ];

    .require.lib each `$("q-doc-config"; "q-doc-generator"; "q-doc-parser");

	.h.HOME:1_ string ` sv .qdoc.cfg.folderRoot,`html;
	.h.tx[`jsn]:{ enlist .j.j x };
	.h.ty[`jsn]:"application/json";
 };


// Standalone process initialisation

.qdoc.cfg.args:first each .Q.opt .z.x;

if[`standalone in key .qdoc.cfg.args;
    .qdoc.standaloneInit[];
 ];
