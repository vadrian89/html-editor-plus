import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_plus/src/plus/core/editor_callbacks.dart';

import '../core/css_builder.dart';
import '../core/editor_event.dart';
import '../core/editor_file.dart';
import '../core/editor_message.dart';
import '../core/editor_selection_state.dart';
import '../core/editor_upload_error.dart';
import '../core/editor_value.dart';
import '../core/enums.dart';
import '../core/js_builder.dart';
import '../editor_controller.dart';

abstract class SummernoteAdapter {
  static const _defaultMaxFileSize = 10 * 1024 * 1024;

  HtmlEditorValue _currentValue;

  HtmlEditorValue get currentValue => _currentValue;

  set currentHtml(String value) {
    if (value != _currentValue.html) {
      _currentValue = _currentValue.copyWith(html: HtmlEditorController.processHtml(html: value));
      onChange?.call(value);
    }
  }

  /// A unique key for editor.
  ///
  /// For web this is the id of the IFrameElement rendering the editor. It set to
  /// [HtmlElementView.id].
  ///
  /// For mobile (using InAppWebView) this is the key given to [VisibilityDetector] wrapping the
  /// editor.
  final String key;

  /// The javascript (jQuery) selector of the summernote editor.
  final String summernoteSelector;

  /// {@macro HtmlEditorField.hint}
  final String? hint;

  /// The resize mode of the editor.
  final ResizeMode resizeMode;

  /// The maximum file size allowed to be uploaded.
  final int maximumFileSize;

  /// If the spell check should be enabled.
  final bool spellCheck;

  /// List of custom options to be added to the summernote initialiser.
  ///
  /// Example of element in the list: `"codeviewFilterRegex: 'custom-regex',"`. This will add the
  /// option `codeviewFilterRegex: 'custom-regex'` to the summernote initialiser.
  /// Don't forget the comma at the end of the string.
  ///
  /// The options will be joined together with a comma: `customOptions.join("\n")`.
  ///
  /// DO NOT ADD options which are already handled by the adapter.
  final List<String> customOptions;

  /// {@macro HtmlEditorField.onInit}
  ///
  /// This is called when the editor is initialised and is called after the web view initialised.
  /// Only when this is called we can change the initial html.
  final VoidCallback? onInit;

  /// {@macro HtmlEditorField.onFocus}
  final VoidCallback? onFocus;

  /// {@macro HtmlEditorField.onBlur}
  final VoidCallback? onBlur;

  /// {@macro HtmlEditorField.onImageUpload}
  final ValueChanged<HtmlEditorFile>? onImageUpload;

  /// {@macro HtmlEditorField.onImageUploadError}
  final ValueChanged<HtmlEditorUploadError>? onImageUploadError;

  /// {@macro HtmlEditorField.onKeyup}
  final ValueChanged<int>? onKeyup;

  /// {@macro HtmlEditorField.onKeydown}
  final ValueChanged<int>? onKeydown;

  /// {@macro HtmlEditorField.onMouseUp}
  final VoidCallback? onMouseUp;

  /// {@macro HtmlEditorField.onMouseDown}
  final VoidCallback? onMouseDown;

  /// {@macro HtmlEditorField.onChange}
  final ValueChanged<String>? onChange;

  /// {@macro HtmlEditorField.onUrlPressed}
  final ValueChanged<String>? onUrlPressed;

  /// {@macro HtmlEditorField.onSelectionChanged}
  final ValueChanged<EditorSelectionState>? onSelectionChanged;

  /// {@macro HtmlEditorField.cssBuilder}
  final String Function(String css, ThemeData themeData)? cssBuilder;

  /// {@macro HtmlEditorField.jsInitBuilder}
  final String Function(String js)? jsInitBuilder;

  /// Build a string which contains javascript specific to the current platform.
  ///
  ///
  /// On web we need some extra code to handle communication between the app and summernote editor.
  String get platformSpecificJavascript;

  /// Selector for the html input used by summernote.
  String get editorSelector => "\$('div.note-editable')";

  /// Custom CSS used to style the editor.
  String css({ThemeData? theme}) {
    final effectiveTheme = theme ?? ThemeData.light();
    final effectiveCss = CssBuilder.buildCss(theme: effectiveTheme);
    return cssBuilder?.call(effectiveCss, effectiveTheme) ?? effectiveCss;
  }

  String get assetsPath => "packages/html_editor_plus/assets";
  String get filePath => "$assetsPath/summernote-no-plugins.html";
  String get cssPath => "$assetsPath/summernote-lite.min.css";
  String get jqueryPath => "$assetsPath/jquery.min.js";
  String get summernotePath => "$assetsPath/summernote-lite.min.js";

  SummernoteAdapter({
    HtmlEditorValue? initialValue,
    required this.key,
    this.summernoteSelector = "\$('#summernote-2')",
    this.hint,
    this.resizeMode = ResizeMode.resizeToParent,
    this.maximumFileSize = _defaultMaxFileSize,
    this.spellCheck = false,
    this.customOptions = const [],
    this.onInit,
    this.onFocus,
    this.onBlur,
    this.onImageUpload,
    this.onImageUploadError,
    this.onKeyup,
    this.onKeydown,
    this.onMouseUp,
    this.onMouseDown,
    this.onChange,
    this.onUrlPressed,
    this.onSelectionChanged,
    this.cssBuilder,
    this.jsInitBuilder,
  }) : _currentValue = initialValue ?? const HtmlEditorValue();

  /// Method used to load the summernote editor into the apropriate widget.
  ///
  /// Due to the fact that summernote is loaded differently on different platforms, this method
  /// should be implemented in concrete classes.
  Future<void> loadSummernote({ThemeData? theme});

  /// Method used to handle messages sent from the summernote editor.
  void handleEditorMessage(EditorMessage message);

  /// Method to handle an [EditorEvent].
  ///
  /// This method should call the appropriate javascript code based on the event received.
  ///
  /// On Web send a JSON through `window.parent.postMessage` which contains code on how to handle
  /// the incoming payload.
  ///
  /// If a custom event is received, the developer needs to make sure it's handled correctly on
  /// javascript side.
  void handleEvent(EditorEvent event);

  /// Method used to dispose the summernote editor.
  Future<void> dispose();

  /// Build a string which is used to initialise all the web code.
  String init({bool allowUrlLoading = true}) {
    final coreCode = [
      ...helperFunctions(allowUrlLoading: allowUrlLoading),
      JsBuilder.jqReady(
        body: JsBuilder.summernoteInit(
          placeholder: hint,
          spellCheck: spellCheck,
          maximumFileSize: maximumFileSize,
          customOptions: customOptions,
          summernoteCallbacks: summernoteCallbacks(),
        ),
      ),
      ...jsSummernoteCallbacks(),
      platformSpecificJavascript,
      JsBuilder.logDebugCall(message: "Summernote initialised", wrapInQuotes: true),
    ].join();
    final initJs = [
      if (kIsWeb) '<script type="text/javascript">',
      jsInitBuilder?.call(coreCode) ?? coreCode,
      if (kIsWeb) '</script>',
    ].join();
    return initJs;
  }

  /// Builds a JavaScript code which will be used to send a message to the Dart side.
  ///
  /// [payload] is an optional payload.
  String messageHandler({required EditorCallbacks event, String? payload});

  /// Build a JS function to call a summernote editor's function.
  ///
  /// [method] is the name of the function to call.
  /// [payload] is the value passed to the function.
  /// [wrapMethod] is whether to wrap the method in quotes.
  String callSummernoteMethod({required String method, String? payload, bool wrapMethod = true}) {
    final effectiveMethod = wrapMethod ? "'$method'" : method;
    final args = [effectiveMethod, ?payload];
    return "$summernoteSelector.summernote(${args.join(",")});";
  }

  /// List of helper functions to be added to the summernote initialiser.
  List<String> helperFunctions({bool allowUrlLoading = true}) => [
    JsBuilder.logDebug(),
    JsBuilder.resizeToParent(),
    JsBuilder.setHtml(),
    JsBuilder.createLink(),
    JsBuilder.insertImageUrl(),
    JsBuilder.setCursorToEnd(),
    JsBuilder.toggleCodeView(resizeToParent: resizeMode == ResizeMode.resizeToParent),
    JsBuilder.onLinkPressedListener(
      allowUrlLoading: allowUrlLoading,
      handlerBuilder: (payload) =>
          messageHandler(event: EditorCallbacks.onUrlPressed, payload: payload),
    ),
    JsBuilder.fileUpload(
      handlerBuilder: (payload) =>
          messageHandler(event: EditorCallbacks.onImageUpload, payload: payload),
      errorHandlerBuilder: (payload) =>
          messageHandler(event: EditorCallbacks.onImageUploadError, payload: payload),
    ),
    JsBuilder.uploadError(
      handlerBuilder: (payload) =>
          messageHandler(event: EditorCallbacks.onImageUploadError, payload: payload),
    ),
    JsBuilder.onSelectionChange(
      handlerBuilder: (payload) =>
          messageHandler(event: EditorCallbacks.onSelectionChanged, payload: payload),
    ),
  ];

  /// List of summernote callbacks to be added to the summernote initialiser.
  List<String> summernoteCallbacks({int? characterLimit}) => [
    summernoteCallback(event: EditorCallbacks.onInit),
    summernoteCallback(event: EditorCallbacks.onChange),
    summernoteCallback(event: EditorCallbacks.onChangeCodeview),
    if (onFocus != null) summernoteCallback(event: EditorCallbacks.onFocus),
    if (onBlur != null) summernoteCallback(event: EditorCallbacks.onBlur),
    if (onImageUpload != null)
      summernoteCallback(event: EditorCallbacks.onImageUpload, body: "uploadFile(files[0])"),
    if (onImageUploadError != null)
      summernoteCallback(
        event: EditorCallbacks.onImageUploadError,
        body: "uploadError(file, error)",
      ),
    if (onKeyup != null) summernoteCallback(event: EditorCallbacks.onKeyup),
    if (onKeydown != null) summernoteCallback(event: EditorCallbacks.onKeydown),
  ];

  /// List of JS event listeners to be added to the summernote initialiser.
  ///
  /// These are event listeners which couldn't be added as summernote callbacks.
  List<String> jsSummernoteCallbacks() => [
    JsBuilder.jqEventListener(
      selector: summernoteSelector,
      event: "summernote.mouseup",
      body: messageHandler(event: EditorCallbacks.onMouseUp),
    ),
    JsBuilder.jqEventListener(
      selector: summernoteSelector,
      event: "summernote.mousedown",
      body: messageHandler(event: EditorCallbacks.onMouseDown),
    ),
  ];

  /// Build a summernote callback for the editor.
  ///
  /// If the [body] is not provided, the [messageHandler] will be used.
  String summernoteCallback({required EditorCallbacks event, String? body}) =>
      JsBuilder.summernoteCallback(
        event: event,
        body: (event) => body ?? messageHandler(event: event, payload: event.payload),
      );

  /// Build a callable javascript function.
  String javascriptFunction({required String name, String? arg}) =>
      JsBuilder.functionCall(name: name, args: [?arg]);
}
