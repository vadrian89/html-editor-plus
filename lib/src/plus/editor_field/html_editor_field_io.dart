import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../core/editor_event.dart';
import '../core/editor_file.dart';
import '../core/editor_upload_error.dart';
import '../core/enums.dart';
import '../editor_controller.dart';
import '../summernote_adapter/summernote_adapter_inappwebview.dart';

/// {@macro HtmlEditorField}
///
/// This is used for mobile platforms.
class HtmlEditorField extends StatefulWidget {
  /// {@macro HtmlEditorField.hint}
  final String? hint;

  /// {@macro ResizeMode}
  final ResizeMode resizeMode;

  /// {@macro HtmlEditorField.inAppWebViewSettings}
  final InAppWebViewSettings? inAppWebViewSettings;

  /// {@macro HtmlEditorField.controller}
  final HtmlEditorController? controller;

  /// {@macro HtmlEditorField.themeData}
  final ThemeData? themeData;

  /// {@macro HtmlEditorField.maximumFileSize}
  final int? maximumFileSize;

  /// {@macro HtmlEditorField.spellCheck}
  final bool? spellCheck;

  /// {@macro HtmlEditorField.customOptions}
  final List<String>? customOptions;

  /// {@macro HtmlEditorField.allowUrlLoading}
  final Future<bool> Function(Uri? uri)? allowUrlLoading;

  /// {@macro HtmlEditorField.onInit}
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

  /// {@macro HtmlEditorField.cssBuilder}
  final String Function(String css, ThemeData themeData)? cssBuilder;

  /// {@macro HtmlEditorField.jsInitBuilder}
  final String Function(String js)? jsInitBuilder;

  const HtmlEditorField({
    super.key,
    required this.controller,
    this.hint,
    this.resizeMode = ResizeMode.resizeToParent,
    this.inAppWebViewSettings,
    this.themeData,
    this.maximumFileSize,
    this.spellCheck,
    this.customOptions,
    this.allowUrlLoading,
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
    this.cssBuilder,
    this.jsInitBuilder,
  });

  @override
  State<HtmlEditorField> createState() => _HtmlEditorFieldState();
}

class _HtmlEditorFieldState extends State<HtmlEditorField> {
  late final SummernoteAdapterInappWebView _adapter;
  late final HtmlEditorController _controller;
  late final StreamSubscription<EditorEvent> _eventsSubscription;

  late final StreamSubscription<bool> _keyboardVisibilitySubscription;
  late final InAppWebViewSettings _initialOptions;

  InAppWebViewController? _webviewController;
  String get _filePath => _adapter.filePath;
  String get _viewId => _adapter.key;

  Stream<bool> get _keyboardVisibilityStream => KeyboardVisibilityController().onChange;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HtmlEditorController();
    _adapter = SummernoteAdapterInappWebView(
      key: DateTime.now().millisecondsSinceEpoch.toString(),
      initialValue: _controller.clonedValue,
      resizeMode: widget.resizeMode,
      hint: widget.hint,
      customOptions: widget.customOptions ?? const [],
      spellCheck: widget.spellCheck ?? false,
      maximumFileSize: widget.maximumFileSize ?? 10485760,
      onInit: widget.onInit,
      onFocus: widget.onFocus,
      onBlur: widget.onBlur,
      onImageUpload: widget.onImageUpload,
      onImageUploadError: widget.onImageUploadError,
      onKeyup: widget.onKeyup,
      onKeydown: widget.onKeydown,
      onMouseUp: widget.onMouseUp,
      onMouseDown: widget.onMouseDown,
      onChange: _onChange,
      onUrlPressed: widget.onUrlPressed,
      onSelectionChanged: (value) => _controller.selectionState = value,
      cssBuilder: widget.cssBuilder,
      jsInitBuilder: widget.jsInitBuilder,
    );
    _eventsSubscription = _controller.events.listen(_adapter.handleEvent);
    _initialOptions =
        widget.inAppWebViewSettings ??
        InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
          useHybridComposition: true,
          useShouldOverrideUrlLoading: true,
          loadWithOverviewMode: true,
        );
    _keyboardVisibilitySubscription = _keyboardVisibilityStream.listen(
      _onKeyboardVisibilityChanged,
    );
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _controller.removeListener(_controllerListener);
    _keyboardVisibilitySubscription.cancel();
    _adapter.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InAppWebView(
    key: ValueKey("webview_key_$_viewId"),
    initialFile: _filePath,
    onWebViewCreated: (controller) => _adapter.webviewController = controller,
    onLoadStop: (controller, url) => _adapter.loadSummernote(theme: Theme.of(context)),
    onReceivedError: (controller, request, error) => debugPrint("message: ${error.description}"),
    initialSettings: _initialOptions,
    shouldOverrideUrlLoading: (controller, action) async {
      if (action.request.url.toString().contains(_filePath)) {
        return NavigationActionPolicy.ALLOW;
      }
      if (widget.allowUrlLoading != null) {
        return (await widget.allowUrlLoading!(action.request.url))
            ? NavigationActionPolicy.ALLOW
            : NavigationActionPolicy.CANCEL;
      }
      return NavigationActionPolicy.ALLOW;
    },
    gestureRecognizers: {
      Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
      Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
    },
    onConsoleMessage: (controller, message) => debugPrint(message.message),
  );

  void _onChange(String value) {
    _controller.html = value;
    widget.onChange?.call(value);
  }

  Future<void> _controllerListener() async {
    debugPrint("Controller listener called");
    if (_controller.html != _adapter.currentValue.html) {
      _adapter.handleEvent(EditorSetHtml(payload: _controller.processedHtml));
    }
  }

  /// Function which clears the focus from the editor once the keyboard is hidden.
  ///
  /// There are some issues with the keyboard on mobile platforms, so this is a workaround.
  /// Usually MediaQuery.of(context).viewInsets gets updated if the keyboard is opened/closed,
  /// but this doesn't seem to be the case with the editor. Don't know if is from InAppWebView or
  /// the platform view itself.
  /// More so, if the keyboard is closed by tapping on the back button, the focus is not cleared.
  /// So we need to manually clear the focus.
  void _onKeyboardVisibilityChanged(bool visible) {
    if (!visible) _webviewController?.clearFocus();
  }
}
