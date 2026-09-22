// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/editor_callbacks.dart';
import '../core/editor_event.dart';
import '../core/editor_message.dart';
import '../core/editor_selection_state.dart';
import '../core/enums.dart';
import '../core/editor_file.dart';
import '../core/editor_upload_error.dart';
import 'summernote_adapter.dart';

class SummernoteAdapterWeb extends SummernoteAdapter {
  final html.IFrameElement _iframe;

  late final StreamSubscription<EditorMessage> _messagesSubscription;

  /// {@macro HtmlEditorField.allowUrlLoading}
  final Future<bool> Function(Uri? uri)? allowUrlLoading;

  @override
  String get platformSpecificJavascript =>
      '''
function handleMessage(e) {
  if (e && e.data && e.data.includes("toIframe")) {
    logDebug("Received toIframe message from parent: " + e.data);
    const data = JSON.parse(e.data);
    const method = data["method"];
    const payload = data["payload"];
    if (data["key"] != $key) {
      logDebug("Ignoring message for view: " + data["key"])
      return;
    }
    if (method == "reload") {
      logDebug("Reloading editor....");
      window.location.reload();
    }
    else if (method == "setHtml") {
      ${javascriptFunction(name: 'setHtml', arg: "payload")}
    }
    else if (method == "setCursorToEnd") {
      ${javascriptFunction(name: 'setCursorToEnd')}
    }
    else if (method == "createLink") {
      ${javascriptFunction(name: 'createLink', arg: "payload")}
    }
    else if (method == "insertImage") {
      ${javascriptFunction(name: 'insertImage', arg: "payload")}
    } 
    else if (method == "toggleCodeView") {
      ${javascriptFunction(name: 'toggleCodeView')}
    }
  }
  else if (e && e.data && e.data.includes("toSummernote")) {
    logDebug("Received toSummernote message from parent: " + e.data);
    const data = JSON.parse(e.data);
    const method = data["method"];
    const payload = data["payload"];
    if (payload) {
      ${callSummernoteMethod(method: 'method', wrapMethod: false, payload: 'payload')}
    } 
    else {
      logDebug("Calling method: " + method);
      if (method == "${const EditorToggleView().method}" && ${resizeMode == ResizeMode.resizeToParent}) {
        resizeToParent();
      }
      ${callSummernoteMethod(method: 'method', wrapMethod: false)}
    }
  }
}

window.parent.addEventListener('message', handleMessage, false);
''';

  @override
  String get jqueryPath => "assets/${super.jqueryPath}";
  @override
  String get cssPath => "assets/${super.cssPath}";
  @override
  String get summernotePath => "assets/${super.summernotePath}";

  Stream<EditorMessage> get _iframeMessagesStream =>
      html.window.onMessage.map((event) => EditorMessage.fromJson(jsonDecode(event.data)));

  SummernoteAdapterWeb({
    required super.key,
    super.initialValue,
    this.allowUrlLoading,
    super.summernoteSelector = "\$('#summernote-2')",
    super.hint,
    super.resizeMode = ResizeMode.resizeToParent,
    super.customOptions,
    super.maximumFileSize,
    super.spellCheck,
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
  }) : _iframe = _initIframe(key) {
    _messagesSubscription = _iframeMessagesStream.listen(handleEditorMessage);
  }

  @override
  Future<void> loadSummernote({ThemeData? theme}) async {
    final allowUrlLoading = (await this.allowUrlLoading?.call(null)) ?? true;
    final summernoteInit =
        '''
${init(allowUrlLoading: allowUrlLoading)}
<style>
${css(theme: theme)} 
</style>
''';
    final defaultHtml = await rootBundle.loadString(filePath);
    _iframe.srcdoc = defaultHtml
        .replaceFirst('"jquery.min.js"', '"$jqueryPath"')
        .replaceFirst('"summernote-lite.min.css"', '"$cssPath"')
        .replaceFirst('"summernote-lite.min.js"', '"$summernotePath"')
        .replaceFirst('<!--summernoteScripts-->', summernoteInit);
  }

  @override
  String messageHandler({required EditorCallbacks event, String? payload}) {
    final effectivePayload = payload ?? "null";
    return 'window.parent.postMessage(JSON.stringify({"key": "$key", "type": "toDart", "method": "$event", "payload": $effectivePayload}), "*");';
  }

  @override
  void handleEditorMessage(EditorMessage message) {
    if (message.type != "toDart") return;
    debugPrint("Received message from iframe: $message");
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
      EditorCallbacks.onMouseDown => onMouseDown?.call(),
      EditorCallbacks.onMouseUp => onMouseUp?.call(),
      EditorCallbacks.onUrlPressed => onUrlPressed?.call(message.payload!),
      EditorCallbacks.onSelectionChanged => onSelectionChanged?.call(
        EditorSelectionState.fromEncodedJson(message.payload!),
      ),
      _ => debugPrint("Uknown message received from iframe: $message"),
    };
  }

  void _onInit() {
    if (currentValue.hasValue) handleEvent(EditorSetHtml(payload: currentValue.html));
    return onInit?.call();
  }

  @override
  void handleEvent(EditorEvent event) {
    const jsonEncoder = JsonEncoder();
    final message = EditorMessage.fromEvent(key: key, event: event, type: _eventType(event));
    html.window.postMessage(jsonEncoder.convert(message.toJson()), '*');
  }

  String _eventType(EditorEvent event) => switch (event) {
    EditorReload() => "toIframe",
    EditorSetHtml() => "toIframe",
    EditorSetCursorToEnd() => "toIframe",
    EditorCreateLink() => "toIframe",
    EditorInsertImageLink() => "toIframe",
    EditorToggleView() => "toIframe",
    _ => "toSummernote",
  };

  static html.IFrameElement _initIframe(String viewId) {
    final iframe = html.IFrameElement();
    iframe.style.height = "100%";
    iframe.style.width = "100%";
    iframe.style.border = "none";
    iframe.style.overflow = "hidden";
    iframe.style.padding = "0";
    iframe.style.margin = "0";
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iframe);
    return iframe;
  }

  @override
  Future<void> dispose() async {
    await _messagesSubscription.cancel();
    handleEvent(const EditorDestroy());
  }
}
