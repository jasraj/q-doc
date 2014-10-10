// q-doc Code Documentation Generator
//  Utility Functions
// Copyright (C) 2014 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details

/ List of valid file suffixes that classify as kdb compatible.
.util.validQSuffixes:(".q";".k";".q_");

/ Determines if the specified location is a folder or not
/  @param folder (FolderPath) The path to check
/  @returns (Boolean) True if the path is a folder, false if a file or nothing
.util.isFolder:{[folder]
    :(not ()~fc) & not folder~fc:key folder;
 };

/ Returns a list of files and folders, recursively, below the folder specified
/  @param root (FolderPath) The folder to start the tree from
/  @returns (Path) All files and folders, recursively, below the folder
/  @see .util.isFolder
.util.tree:{[root]
    rc:` sv/:root,/:key root;
    folders:.util.isFolder each rc;

    :raze (rc where not folders),.z.s each rc where folders;
 };

/ Performs an 'is empty' check on the input. This is useful in the case where
/ the object can be a list of nulls, it is defined as 'empty'.
/  @param obj () Any valid kdb object
/  @returns (Boolean) True if the input is classed as 'empty', false otherwise
.util.isEmpty:{[obj]
    :all null obj;
 };

/ Finds and loads all files that match the library name anywhere from the 
/ root folder supplied.
/  @param lib (Symbol) The name of the library to load
/  @param rootSearch (FolderPath) The root to start the search from
/  @see .util.tree
/  @see .util.load
.util.require:{[lib;rootSearch]
	files:.util.tree rootSearch;
	files@:where any like/:[;"*",/:string[lib],/:.util.validQSuffixes] files;

	.util.load each files;
 };

/ Loads the specified file into the process
/  @param file (FilePath) The file to load
/  @throws FileLoadFailedException If the file fails to load
.util.load:{[file]
	fileStr:1_string file;
	.log.info "Loading ",fileStr;
	
	res:@[system;"l ",fileStr;{ (`LOAD_FAILED;x) }];

	if[`LOAD_FAILED~first res;
		.log.error "Failed to load file (",fileStr,"). Error - ",last res;
		'"FileLoadFailedException (",fileStr,")";
	];
 };

/ Simple check if the process is bound to a port or not
/  @returns (Boolean) True if the process is bound to a port, false otherwise
.util.isListening:{
	:`boolean$system"p";
 };


.log.info:{ -1 "INFO: ",x; };
.log.warn:{ -1 "WARN: ",x; };
.log.error:{ -2 "ERROR: ",x; };
