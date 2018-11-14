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

// The key value to search for in the URL hash to perform a load of a file on init
QDoc.checkHashOnInit = "doc";

// File tree contents set on load
//  @see QDoc.buildFileTree
QDoc.fileTree = null;

// File tree handlebars template once it has been compiled. No need to re-query
// if file tree has to change
QDoc.fileTreeTemplate = null;

// If non-empty, this value contains the file that was specified in the URL hash when the page
// was loaded
//  @see QDoc.parseUrlHash
QDoc.fileSetOnInit = "";


QDoc.init = function() {
    QDoc.fileSetOnInit = QDoc.parseUrlHash();

    QDoc.getHeaderDetails();
    QDoc.getFunctionSources();

    if(!S(QDoc.fileSetOnInit).isEmpty())
        QDoc.getWithHistory(QDoc.fileSetOnInit);

    window.onpopstate = QDoc.onPopState;
 }


// Function executed when the pages is loaded to get header (company / application name) from kdb
//  @see QDoc.buildHeader
QDoc.getHeaderDetails = function() {
    $.getJSON("/jsn?.qdoc.json.getHeaderDetails[]", {}, QDoc.buildHeader);
 }

// Function executed when the page is loaded to get all the files in scope for q-doc parsing.
//  @see QDoc.buildFileTree
QDoc.getFunctionSources = function() {
    $.getJSON("/jsn?.qdoc.json.getFileList[]", {}, QDoc.buildFileTree);
 }

// Sets the company and application name on the HTML page once loaded
QDoc.buildHeader = function(json) {
    $("#q-doc-header-company").html(json.company);
    $("#q-doc-header-app-name").html(json.appName);
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
    filesJson.files = $.map(filesJson.files, function(item) {
        return $.extend(item, {
            id: QDoc.escapeChars(item.file),
            link: "javascript:QDoc.getWithHistory(\"" + item.file + "\")"
        });
    });
    return filesJson;
 }

// Primary point for retrieving the documentation for a new file. This function also updates the browser history
// to ensure forward and backward tracking
//  @see QDoc.getNoHistory
QDoc.getWithHistory = function(file) {
    QDoc.get(file);

    history.pushState(null, null, "#doc=" + file);
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
            
            window.scrollTo(0, 0);
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

// Queries the kdb process for the specified file and updates the HTML page with the result set
//  @see QDoc.fileTreeDiv
//  @see QDoc.escapeChars
//  @see QDoc.buildQDoc
QDoc.get = function(file) {
    if(file == "") {
        console.log("No file specified. Cannot get q-doc for empty file");
        return;
    };

    $("#" + QDoc.fileTreeDiv + "-group>a.active").removeClass("active");
    $("#" + QDoc.escapeChars(file)).addClass("active");

    var url = "/jsn?.qdoc.json.getQDocFor`$\"" + file + "\"";
    $.getJSON(url, {},  QDoc.buildQDoc)
        .fail(function(jq, status, error) {
            console.error("JSON [" + url + "] " + status + ": " + error);
        });
 };

// Once we receive the JSON result from the kdb server, we need to clean it up
// before we can display to the user. This includes:
//  - Generating IDs for page anchors
//  - Build the argument list
//  - Format the comment description
//  - Format the returns description
//  - Format the types description
QDoc.postProcessDoc = function(docJson) {

    function showTab(text) {
        return text.replace(/\t/g, "\u2003");
    }

    docJson.qdoc = $.map(docJson.qdoc, function(element) {
        element.id = QDoc.escapeChars(element.func);

        if(S(element.func).contains("[")) {
            element.arguments = "";
        } else {
            element.arguments = "[" + element.arguments.join(";") + "]";
        }

        element.comments = showTab(element.comments.join(" "));
        element.returns.description = S(element.returns.description).humanize();

        element.throws = $.map(element.throws, function(t) {
            t.description = S(t.description).humanize();
            return t;
        });

        element.see = $.map(element.see, function(s) {
            return {
                linkOrFunc: s,
                id: /^\s*<a[^>]+>[^<]+<\/a>\s*$/.test(s) ? null : QDoc.escapeChars(s)
            };
        });

        element.deprecated = $.map(element.deprecated, function(d) {
            return showTab(d);
        });

        return element;
    });

    return docJson;
 };

// Removes any characters that are not supported by jQuery's DOM lookup function. All
// the non-supported characters are replaced with an underscore "_"
QDoc.escapeChars = function(fileName) {
    return fileName.replace(/[:/.]/g, "_");
 };

// Parses the URL hash (anything after the '#') looking for the specified key to enable loading of a specific
// documentation page as the page loads
//  @see window.location.hash
//  @see QDoc.checkHashOnInit
//  @see QDoc.fileSetOnInit
QDoc.parseUrlHash = function() {
    var hashString = window.location.hash.substr(1);

    if(hashString == "")
        return;

    var ampSplit = hashString.split("&");
    var fileOnInit = "";

    for(var i = 0; i < ampSplit.length; i++) {
        var eqSplit = ampSplit[i].split("=");

        if(eqSplit.length == 2 && eqSplit[0] == QDoc.checkHashOnInit) {
            fileOnInit = eqSplit[1];
            break;
        };
    };

    return fileOnInit;
 };

// Event handler function for the window.onpopstate event to enable loading the correct file on forward and back
// navigation in the browser. NOTE: This function calls QDoc.get directly to ensure the history is not changed
//  @see QDoc.parseUrlHash
//  @see QDoc.get
QDoc.onPopState = function(event) {
    QDoc.get(QDoc.parseUrlHash());
 };
