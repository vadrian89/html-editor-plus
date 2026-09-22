import 'package:flutter/foundation.dart';

import 'editor_callbacks.dart';
import 'enums.dart';

/// Helper class used to help building the JS code for the editor.
class JsBuilder {
  /// Selector for the html input used by summernote.
  static const String editorSelector = "\$('div.note-editable')";

  /// Selector for the summernote editor element.
  static const String summernoteSelector = "#summernote-2";

  /// Build a javascript function which will be called.
  ///
  /// [name] is the name of the function.
  /// [args] are the arguments passed to the function.
  static String functionCall({required String name, List<String> args = const []}) =>
      "$name(${args.join(",")});";

  /// Build the jquery ready function.
  static String jqReady({required String body}) => functionCall(
    name: "\$(document).ready",
    args: [callbackClosure(body: body)],
  );

  /// Build the declaration of a javascript function.
  ///
  /// [name] is the name of the function.
  /// [args] are the parameters accepted by the function.
  /// [body] is the code that will be executed when the function is called.
  static String function({
    required String name,
    List<String> args = const [],
    required String body,
  }) => "function $name(${args.join(",")}) { $body }";

  /// Build a closure for a javascript callback.
  ///
  /// [args] are the parameters accepted by the function.
  static String callbackClosure({List<String> args = const [], required String body}) =>
      '''
    function(${args.join(', ')}) {
      $body
    }
  ''';

  /// Build a javascript event listener.
  ///
  /// [selector] is the selector of the element to listen to. Defaults to `document`.
  /// [event] is the javascript event to listen to.
  /// [args] are the parameters accepted by the closure.
  /// [body] is the code that will be executed when the event is triggered.
  static String eventListener({
    String selector = "document",
    required String event,
    List<String> args = const [],
    required String body,
  }) => "$selector.addEventListener('$event', ${callbackClosure(args: args, body: body)});";

  /// Build a jQuery event listener
  ///
  /// [selector] is the selector of the element to listen to. The selector should be a
  /// jQuery selector without the paranthesis and the jQuery sign.
  /// [event] is the javascript event to listen to.
  /// [args] are the parameters accepted by the closure.
  /// [body] is the code that will be executed when the event is triggered.
  static String jqEventListener({
    required String selector,
    required String event,
    List<String> args = const [],
    required String body,
  }) => "\$($selector).on('$event', ${callbackClosure(args: args, body: body)});";

  /// Build an event callback for the summernote editor initialiser.
  ///
  /// [event] is an enum containing info about the event and callback.
  /// [body] is the code that will be executed when the event is triggered.
  static String summernoteCallback({
    required EditorCallbacks event,
    required String Function(EditorCallbacks event) body,
  }) => "${event.callback}: ${callbackClosure(args: event.args, body: body(event))}";

  /// Build a JS object represeting file upload which will be uploaded.
  ///
  /// [fileNode] is the node containing the file data.
  /// [hasBase64] is a flag to indicate if the file has base64 data.
  static String fileObject({required String fileNode, bool hasBase64 = true}) =>
      '''
    {
      'lastModified': $fileNode.lastModified,
      'lastModifiedDate': $fileNode.lastModifiedDate,
      'name': $fileNode.name,
      'size': $fileNode.size,
      'mimeType': $fileNode.type,
      ${hasBase64 ? "'base64': base64," : ""}
    };
  ''';

  /// Build a JS function to call a summernote editor's method.
  ///
  /// [selector] is the jQuery selector of the element where summernote editor is initialised.
  /// Defaults to `#summernote-2`.
  /// [args] are the arguments passed to the method.
  static String summernoteMethodCall({
    String selector = "'#summernote-2'",
    List<String> args = const [],
  }) => "\$($selector).summernote(${args.join(",")});";

  /// Build the declaration of a function which will resize the editor to the width and height to the parent (window).
  static String resizeToParent() => function(
    name: "resizeToParent",
    body:
        '''
${logDebugCall(message: "Resizing to parent", wrapInQuotes: true)}
${editorHeight(height: "window.innerHeight")}
${editorWidth(width: "window.innerWidth")}
''',
  );

  /// Build a function which log debug data to the console.
  ///
  /// It will only work if the app is running in debug mode (`kDebugMode == true`).
  static String logDebug() =>
      function(name: "logDebug", args: ["message"], body: "if ($kDebugMode) console.log(message);");

  /// Build code which calls logDebug function.
  ///
  /// [message] is the message to be logged.
  /// [wrapInQuotes] is a flag to indicate if the message should be wrapped in quotes. If the
  /// text will not be wrapped in aditional quotes it will be treated as a JS identifier. It's
  /// default `false` because the developer needs make concatenations most of the time.  ///
  /// DON'T FORGET TO SET [wrapInQuotes] TO TRUE IF YOU ARE PASSING A STRING LITERAL.
  static String logDebugCall({required String message, bool wrapInQuotes = false}) =>
      functionCall(name: 'logDebug', args: [wrapInQuotes ? "'$message'" : message]);

  /// Build a function which will change editor's height.
  ///
  /// [height] is the new width of the editor. It's string to allow passing of different javascript
  /// variables.
  static String editorHeight({String height = ""}) => "$editorSelector.outerHeight($height);";

  /// Build a function which will change editor's width.
  ///
  /// [width] is the new width of the editor. It's string to allow passing of different javascript
  /// variables.
  static String editorWidth({String width = ""}) => "$editorSelector.width($width);";

  /// Build a function which will toggle to/from code view.
  static String toggleCodeView({bool resizeToParent = false}) => function(
    name: "toggleCodeView",
    body:
        '''
${summernoteMethodCall(args: ["'codeview.toggle'"])}
if ($resizeToParent) resizeToParent();
''',
  );

  /// Build a function which creates and inserts a link.
  static String createLink() {
    final summernoteCall = summernoteMethodCall(
      args: ["'createLink'", '{text: text, url: url, isNewWindow: data["isNewWindow"]}'],
    );
    return function(
      name: "createLink",
      args: ["payload"],
      body:
          '''
  const data = JSON.parse(payload);
  const text = data["text"];
  const url = data["url"];
  $summernoteCall
  ''',
    );
  }

  /// Build a function which moves the cursor to the end of the editor.
  static String setCursorToEnd() => function(
    name: "setCursorToEnd",
    body:
        '''
${summernoteMethodCall(args: ["'setLastRange'", "\$.summernote.range.createFromNodeAfter($editorSelector[0]).select()"])}
''',
  );

  /// Build a function which sets the html value of the editor.
  ///
  /// This replaces the current html value of the editor.
  static String setHtml() => function(
    name: "setHtml",
    args: ["value"],
    body:
        '''
const currentValue = ${summernoteMethodCall(args: ["'code'"])}
${logDebugCall(message: '"Current value: "+ currentValue')}
if (value == currentValue) return;
${logDebugCall(message: '"Setting value: " + value')}
${summernoteMethodCall(args: ["'code'", 'value'])}
${functionCall(name: "setCursorToEnd")}
''',
  );

  /// Build a function which inserts an image URL.
  static String insertImageUrl() => function(
    name: "insertImage",
    args: ["payload"],
    body:
        '''
${logDebugCall(message: '"Inserting image: " + payload')}
const data = JSON.parse(payload);
const url = data["url"];
const filename = data["filename"];
${summernoteMethodCall(args: ["'insertImage'", 'url, filename'])}
''',
  );

  /// Build a function which handles file uploads.
  ///
  /// [handlerBuilder] is a function which will build the handler function. It will receive the
  /// payload as a parameter.
  static String fileUpload({
    required String Function(String payload) handlerBuilder,
    required String Function(String payload) errorHandlerBuilder,
  }) => function(
    name: "uploadFile",
    args: ["file"],
    body:
        '''
const reader = new FileReader();
let base64 = "";
reader.onload = function (e) {
  base64 = reader.result;
  const fileObject = ${fileObject(fileNode: "file")}
  ${handlerBuilder("JSON.stringify(fileObject)")}
};
reader.onerror = function (error) {
  ${logDebugCall(message: '"Error while reading file: " + error')}
  const fileObject = ${fileObject(fileNode: "file")}
  const fileObjectAsString = JSON.stringify(fileObject);
  ${errorHandlerBuilder("JSON.stringify({'file': fileObjectAsString, 'error': 'An error occurred!'})")}
};
reader.readAsDataURL(file);
''',
  );

  /// Build a function which handles file upload errors.
  static String uploadError({required String Function(String payload) handlerBuilder}) => function(
    name: "uploadError",
    args: ["file", "error"],
    body:
        '''
if (typeof file === 'string') {
  ${handlerBuilder("JSON.stringify({'file': file, 'error': error})")}
}
else {
  const fileObject = ${fileObject(fileNode: "file", hasBase64: false)}
  const fileObjectAsString = JSON.stringify(fileObject);
  ${handlerBuilder("JSON.stringify({'file': fileObjectAsString, 'error': error})")}
}
''',
  );

  /// Build a javascript event listener which listens to link clicks/taps.
  static String onLinkPressedListener({
    bool allowUrlLoading = true,
    String Function(String payload)? handlerBuilder,
  }) => eventListener(
    event: "click",
    args: ["event"],
    body:
        '''
const target = event.target;
if (target.tagName.toLowerCase() === "a") {
  if (${!allowUrlLoading}) {
    event.preventDefault();
  }
  const url = target.getAttribute("href");
  ${handlerBuilder?.call("url") ?? ""}
}
''',
  );

  /// Build the onSelectionChange function.
  ///
  /// [handlerBuilder] is a function which will build the handler function. It will receive the
  /// payload as a parameter.
  /// [key] is the key of the view.
  static String onSelectionChange({required String Function(String payload)? handlerBuilder}) =>
      '''
    function onSelectionChange() {
          let {anchorNode, anchorOffset, focusNode, focusOffset} = document.getSelection();
          var isBold = false;
          var isItalic = false;
          var isUnderline = false;
          var isStrikethrough = false;
          var isSuperscript = false;
          var isSubscript = false;
          var isUL = false;
          var isOL = false;
          var isLeft = false;
          var isRight = false;
          var isCenter = false;
          var isFull = false;
          var parent;
          var fontName;
          var fontSize = 16;
          var foreColor = "000000";
          var backColor = "FFFF00";
          var focusNode2 = \$(window.getSelection().focusNode);
          var parentList = focusNode2.closest("div.note-editable ol, div.note-editable ul");
          var parentListType = parentList.css('list-style-type');
          var lineHeight = \$(focusNode.parentNode).css('line-height');
          var direction = \$(focusNode.parentNode).css('direction');
          if (document.queryCommandState) {
            isBold = document.queryCommandState('bold');
            isItalic = document.queryCommandState('italic');
            isUnderline = document.queryCommandState('underline');
            isStrikethrough = document.queryCommandState('strikeThrough');
            isSuperscript = document.queryCommandState('superscript');
            isSubscript = document.queryCommandState('subscript');
            isUL = document.queryCommandState('insertUnorderedList');
            isOL = document.queryCommandState('insertOrderedList');
            isLeft = document.queryCommandState('justifyLeft');
            isRight = document.queryCommandState('justifyRight');
            isCenter = document.queryCommandState('justifyCenter');
            isFull = document.queryCommandState('justifyFull');
          }
          if (document.queryCommandValue) {
            parent = document.queryCommandValue('formatBlock');
            fontSize = document.queryCommandValue('fontSize');
            foreColor = document.queryCommandValue('foreColor');
            backColor = document.queryCommandValue('hiliteColor');
            fontName = document.queryCommandValue('fontName');
          }
          const message = {
            'style': parent,
            'fontName': fontName,
            'fontSize': fontSize,
            'isBold': isBold,
            'isItalic': isItalic,
            'isUnderline': isUnderline,
            'isStrikethrough': isStrikethrough,
            'isSuperscript': isSuperscript,
            'isSubscript': isSubscript,
            'foregroundColor': foreColor,
            'backgroundColor': backColor,
            'isUL': isUL,
            'isOL': isOL,
            'listStyle': parentListType,
            'alignLeft': isLeft,
            'alignRight': isRight,
            'alignCenter': isCenter,
            'alignFull': isFull,
            'lineHeight': lineHeight,
            'direction': direction,
          };
          ${handlerBuilder?.call("JSON.stringify(message)") ?? ""}
        }
''';

  /// Build the initialiser code for the summernote editor.
  ///
  /// [selector] is the jQuery selector of the element where summernote editor is initialised. It's
  /// an alternative to [summernoteSelector].
  static String summernoteInit({
    String? selector,
    String? placeholder,
    bool spellCheck = false,
    int maximumFileSize = 5 * 1024 * 1024,
    List<String> customOptions = const [],
    List<String> summernoteCallbacks = const [],
    ResizeMode resizeMode = ResizeMode.resizeToParent,
  }) =>
      '''
\$('${selector ?? summernoteSelector}').summernote({
  ${(placeholder?.trim().isNotEmpty ?? false) ? "placeholder: '$placeholder'," : ""}
  tabsize: 2,
  toolbar: [],
  disableGrammar: false,
  spellCheck: $spellCheck,
  maximumImageFileSize: $maximumFileSize,
  ${customOptions.join("\n")}
  callbacks: {
    ${summernoteCallbacks.join(",\n")}
  }
});
if (${resizeMode == ResizeMode.resizeToParent}) {
  resizeToParent();
  addEventListener("resize", (event) => resizeToParent());
}
document.addEventListener("selectionchange", () => onSelectionChange());
''';
}
