"use strict"; 

// q-doc Code Documentation Generator
//  Javascript Query and Post-Processing
// Copyright (C) 2014 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details

var QDoc = {};

$(function() {
    QDoc.init();
});


// Div ID for the file tree list
QDoc.fileTreeDiv = "q-doc-file-tree";

// Div ID for the documentation itself
QDoc.contentDiv = "q-doc-parsed-content";

// Relative folder location of the handlebar templates
QDoc.templatesLoc = "templates/";

// File tree contents set on load
//  @see QDoc.buildFileTree
QDoc.fileTree = null;

// File tree handlebars template once it has been compiled. No need to re-query
// if file tree has to change
QDoc.fileTreeTemplate = null;


QDoc.init = function() {
    QDoc.getFunctionSources();
 }

// Function executed when the page is loaded to get all the files in scope for q-doc parsing.
//  @see QDoc.buildFileTree
QDoc.getFunctionSources = function() {
    $.getJSON("/jsn?.qdoc.json.getFileList[]", {}, QDoc.buildFileTree);
 }

// Builds the file tree view based on the returned JSON and the related handlebars templated.
//  @see QDoc.getHandlebarsTemplate
//  @see QDoc.fileTreeTemplate
//  @see QDoc.fileTree
//  @see QDoc.fileTreeDiv
QDoc.buildFileTree = function(json) {
    QDoc.getHandlebarsTemplate("q-doc-file-tree.handlebars",
		function(source) {
			QDoc.fileTreeTemplate = Handlebars.compile(source);
			QDoc.fileTree = QDoc.addElementsForFileTree(json);

			$("#" + QDoc.fileTreeDiv).html( QDoc.fileTreeTemplate(json) );
		});
 }

QDoc.addElementsForFileTree = function(filesJson) {
    for(var fCount = 0; fCount < filesJson.files.length; fCount++) {
        var file = filesJson.files[fCount].file;

        filesJson.files[fCount].id = QDoc.escapeChars(file);
        filesJson.files[fCount].link = "javascript:QDoc.get(\"" + file + "\")";
    }

    return filesJson;
 }

// Entry point for retrieving the documentation for a new file
//  @see QDoc.buildQDoc
QDoc.get = function(file) {
    $("#" + QDoc.fileTreeDiv + "-group>a.active").removeClass("active");
    $("#" + QDoc.escapeChars(file)).addClass("active");

	var url = "/jsn?.qdoc.json.getQDocFor`$\"" + file + "\"";
    $.getJSON(url, {},  QDoc.buildQDoc)
		.fail(function(jq, status, error) {
			console.error("JSON [" + url + "] " + status + ": " + error);
		});
 }

// Builds the HTML content page from the handlebars template and the post-processed
// JSON results
//  @see QDoc.postProcessDoc
QDoc.buildQDoc = function(json) {
    QDoc.getHandlebarsTemplate("q-doc-element.handlebars",
		function(source) {
			var elementTemplate = Handlebars.compile(source);
			var jsonUi = QDoc.postProcessDoc(json);

			$("#" + QDoc.contentDiv).html( elementTemplate(jsonUi) );
		});
 }


// INTERNAL FUNCTIONS

// Function retrieves the specified template file, synchronously, from the server.
//  @see QDoc.templatesLoc
QDoc.getHandlebarsTemplate = function(templateFile, callback) {
	var url = QDoc.templatesLoc + templateFile;
    $.ajax({
        url: url,
		dataType: "html",
        success: function(template) {
			callback(template);
        },
		error: function(jq, status, error) {
			console.error("AJAX [" + url + "] " + status + ": " + error);
		}
    });
 }

// Once we receive the JSON result from the kdb server, we need to clean it up
// before we can display to the user. This includes:
//  - Generating IDs for page anchors
//  - Build the argument list
//  - Format the comment description
//  - Format the returns description
//  - Format the types description
QDoc.postProcessDoc = function(docJson) {

    for(var dCount = 0; dCount < docJson.qdoc.length; dCount++) {
        var element = docJson.qdoc[dCount];
        element.id = QDoc.escapeChars(element.func);

        if(S(element.func).contains("[")) {
            element.arguments = "";
        } else {
            element.arguments = "[" + element.arguments.join(";") + "]";
        }

        element.comments = element.comments.join(" ");
        element.returns.description = S(element.returns.description).humanize();

        for(var tCount = 0; tCount < element.throws.length; tCount++) {
            element.throws[tCount].description = S(element.throws[tCount].description).humanize();
        }

        for(var sCount = 0; sCount < element.see.length; sCount++) {
            element.see[sCount] = {
                linkOfFunc: element.see[sCount],
                id: /^<a /.test(element.see[sCount]) ? null : QDoc.escapeChars(element.see[sCount])
            };
        }

        docJson.qdoc[dCount] = element;
    }

    return docJson;
 };

// Removes any characters that are not supported by jQuery's DOM lookup function. All
// the non-supported characters are replaced with an underscore "_"
QDoc.escapeChars = function(fileName) {
    return fileName.replace(/[:/.]/g, "_");
 }

