// q-doc Code Documentation Generator
//  Initialisation
// Copyright (C) 2014 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details

/ The root folder that the q-doc functionality resides in. This will be set on boot.
/  @see .qdoc.init
.qdoc.cfg.baseFolder:`;

.qdoc.init:{
	system "c 100 500";

	-1 "*****";
	-1 "q-doc Code Documentation Generator";
	-1 "Copyright (C) 2014 - 2017 Jaskirat M.S. Rajasansir";
	-1 "License BSD, see LICENSE for details";
	-1 "*****\n";

	.qdoc.cfg.baseFolder:.qdoc.getCwd[];

	system "l util.q";

    if[not `j in key`;
        .qdoc.require `json;
    ];

	.qdoc.require `$"q-doc-config";
	.qdoc.require `$"q-doc-generator";
	.qdoc.require `$"q-doc-parser";

	.h.HTML:"html";
	.h.tx[`jsn]:{ enlist .j.j x };
	.h.ty[`jsn]:"application/json";

	$[.util.isListening[];
		.log.info "Process is listening on port ",string system "p";
		.log.warn "This process is not bound to any port. Please restart the process with the '-p' flag or use '\\p'."
	];

	-1 "";
	.log.info "To initialise the parser, run .qdoc.parser.init `:/path/to/code/folder/root\n";
 };

/ Get the current working directory, dependent on the Operating System the process is started on.
/ NOTE: Only Windows and Linux are currently supported.
/  @returns (FolderPath) The current working directory
/  @throws GetCwdNotImplementedException If the operating system is not yet supported
.qdoc.getCwd:{
	if["w"~first string .z.o;
		:hsym first `$trim system "echo %cd%";
	];

	if["l"~first string .z.o;
		:hsym first `$trim system "pwd";
	];

	'"GetCwdNotImplementedException (",string[.z.o],")";
 };

/ Simple wrapper around .util.require to load the specified library from the current working directory
/  @param lib (Symbol) The library to load
.qdoc.require:{[lib]
	:.util.require[lib;.qdoc.cfg.baseFolder];
 };


.qdoc.init[];
