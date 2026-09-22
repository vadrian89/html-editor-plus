import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/editor_file.dart';
import '../core/editor_upload_error.dart';
import '../core/enums.dart';
import '../editor_controller.dart';

/// {@template HtmlEditor}
/// The full HTML editor widget.
///
/// It contains the editor's text field where the user can insert the text, aswell as the toolbar.
/// {@endtemplate}
class HtmlEditor extends StatelessWidget {
  /// {@macro HtmlEditorField.hint}
  final String? hint;

  /// {@macro ResizeMode}
  final ResizeMode resizeMode;

  /// {@macro HtmlEditorField.controller}
  final HtmlEditorController? controller;

  /// {@macro HtmlEditorField.inAppWebViewSettings}
  final InAppWebViewSettings? inAppWebViewSettings;

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

  const HtmlEditor({
    super.key,
    this.hint,
    this.resizeMode = ResizeMode.resizeToParent,
    this.controller,
    this.inAppWebViewSettings,
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
  Widget build(BuildContext context) =>
      const Center(child: Text("Unsupported in this environment"));
}
