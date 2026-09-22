import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/editor_callbacks.dart';
import '../core/editor_event.dart';
import '../core/editor_message.dart';
import '../core/editor_selection_state.dart';
import '../core/enums.dart';
import '../core/editor_file.dart';
import '../core/editor_upload_error.dart';
import '../core/js_builder.dart';
import 'summernote_adapter.dart';

class SummernoteAdapterInappWebView extends SummernoteAdapter {
  InAppWebViewController? _webviewController;

  set webviewController(InAppWebViewController? webviewController) =>
      _webviewController ??= webviewController;

  @override
  String get platformSpecificJavascript => "";

  SummernoteAdapterInappWebView({
    required super.key,
    super.initialValue,
    super.summernoteSelector = "\$('#summernote-2')",
    super.hint,
    super.resizeMode = ResizeMode.resizeToParent,
    super.customOptions = const [],
    super.maximumFileSize = 10485760,
    super.spellCheck = false,
    super.onInit,
    super.onFocus,
    super.onBlur,
    super.onImageUpload,
    super.onImageUploadError,
    super.onKeyup,
    super.onKeydown,
    super.onMouseUp,
    super.onMouseDown,
    super.onChange,
    super.onUrlPressed,
    super.onSelectionChanged,
    super.cssBuilder,
    super.jsInitBuilder,
  });

  @override
  Future<void> loadSummernote({ThemeData? theme}) async {
    _webviewController!.addJavaScriptHandler(
      handlerName: "onSummernoteEvent",
      callback: (arguments) =>
          handleEditorMessage(EditorMessage.fromJson(jsonDecode(arguments.first.toString()))),
    );
    await _webviewController!.injectCSSFileFromAsset(assetFilePath: cssPath);
    await _webviewController!.injectCSSCode(source: css(theme: theme));
    await _webviewController!.injectJavascriptFileFromAsset(assetFilePath: jqueryPath);
    await _webviewController!.injectJavascriptFileFromAsset(assetFilePath: summernotePath);
    await _webviewController!.evaluateJavascript(source: init());
  }

  @override
  String messageHandler({required EditorCallbacks event, String? payload}) {
    final effectivePayload = (payload != null) ? ", 'payload': $payload" : "";
    return 'window.flutter_inappwebview.callHandler("onSummernoteEvent", JSON.stringify({"key": "$key", "type": "toDart", "method": "$event" $effectivePayload}));';
  }

  @override
  void handleEditorMessage(EditorMessage message) {
    debugPrint("Received message from editor: $message");
    return switch (EditorCallbacks.fromMessage(message)) {
      EditorCallbacks.onInit => _onInit(),
      EditorCallbacks.onChange => currentHtml = message.payload!,
      EditorCallbacks.onChangeCodeview => currentHtml = message.payload!,
      EditorCallbacks.onFocus => onFocus?.call(),
      EditorCallbacks.onBlur => onBlur?.call(),
      EditorCallbacks.onImageUpload => onImageUpload?.call(
        HtmlEditorFile.fromJson(message.payload!),
      ),
      EditorCallbacks.onImageUploadError => onImageUploadError?.call(
        HtmlEditorUploadError.fromJson(message.payload!),
      ),
      EditorCallbacks.onKeyup => onKeyup?.call(int.parse(message.payload!)),
      EditorCallbacks.onKeydown => onKeydown?.call(int.parse(message.payload!)),
      EditorCallbacks.onMouseUp => onMouseUp?.call(),
      EditorCallbacks.onMouseDown => onMouseDown?.call(),
      EditorCallbacks.onUrlPressed => onUrlPressed?.call(message.payload!),
      EditorCallbacks.onSelectionChanged => onSelectionChanged?.call(
        EditorSelectionState.fromEncodedJson(message.payload!),
      ),
      _ => debugPrint("Uknown message received from editor: $message"),
    };
  }

  void _onInit() {
    if (currentValue.hasValue) handleEvent(EditorSetHtml(payload: currentValue.html));
    return onInit?.call();
  }

  @override
  void handleEvent(EditorEvent event) {
    debugPrint("Sending message to editor: $event");
    (switch (event) {
      EditorReload() => _webviewController!.reload(),
      EditorClearFocus() => SystemChannels.textInput.invokeMethod('TextInput.hide'),
      EditorCallFunction(:final method, :final payload) => JsBuilder.functionCall(
        name: method,
        args: [?payload],
      ),
      _ => _webviewController!.evaluateJavascript(
        source: switch (event) {
          EditorSetHtml(:final method, :final payload) => "$method(${jsonEncode(payload)});",
          EditorResizeToParent(:final method) => "$method();",
          EditorSetCursorToEnd(:final method) => "$method();",
          EditorToggleView(:final method) => "$method();",
          EditorInsertImageLink(:final method, :final payload) =>
            "$method(${jsonEncode(payload)});",
          _ => callSummernoteMethod(
            method: event.method,
            payload: switch (event) {
              EditorCreateLink(:final payload) => payload,
              _ => (event.payload != null) ? jsonEncode(event.payload) : null,
            },
          ),
        },
      ),
    });
  }

  @override
  Future<void> dispose() async {
    if (_webviewController != null) handleEvent(const EditorDestroy());
  }
}
