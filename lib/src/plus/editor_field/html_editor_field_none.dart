import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:html_editor_plus/core.dart';
import 'package:html_editor_plus/editor_plus.dart';

/// {@template HtmlEditorField}
/// The widget representing the editor's text field where the user can insert the text.
/// {@endtemplate}
class HtmlEditorField extends StatelessWidget {
  /// {@template HtmlEditorField.hint}
  /// The hint to display when the editor is empty.
  ///
  /// Should be a description of the expected input.
  ///
  /// Can be either plain text or html.
  /// {@endtemplate}
  final String? hint;

  /// {@macro ResizeMode}
  final ResizeMode resizeMode;

  /// {@template HtmlEditorField.controller}
  /// The controller for the HTML editor.
  ///
  /// Provide a controller if you want to control the HTML editor programmatically.
  /// {@endtemplate}
  final HtmlEditorController? controller;

  /// {@template HtmlEditorField.inAppWebViewSettings}
  /// The initial options for the [InAppWebViewSettings] used only on mobile platforms.
  ///
  /// If not specified, these default options are used:
  /// ```dart
  /// InAppWebViewSettings(
  ///   javaScriptEnabled: true,
  ///   transparentBackground: true,
  ///   useHybridComposition: true,
  ///   useShouldOverrideUrlLoading: true,
  ///   loadWithOverviewMode: true,
  /// );
  /// ```
  /// {@endtemplate}
  final InAppWebViewSettings? inAppWebViewSettings;

  /// {@template HtmlEditorField.maximumFileSize}
  /// The maximum file size allowed to be uploaded, in `bytes`.
  ///
  /// If not specified, the default value is 10MB.
  ///
  /// IMPORTANT: Currently doesn't seem to do anything. Could be due to the version of summernote.
  /// Hopefully, it will be fixed in the future.
  /// {@endtemplate}
  final int? maximumFileSize;

  /// {@template HtmlEditorField.spellCheck}
  /// If the spell check should be enabled.
  ///
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool? spellCheck;

  /// {@template HtmlEditorField.customOptions}
  /// List of custom options to be added to the summernote initialiser.
  ///
  /// Example of element in the list: `"codeviewFilterRegex: 'custom-regex',"`. This will add the
  /// option `codeviewFilterRegex: 'custom-regex'` to the summernote initialiser.
  /// Don't forget the comma at the end of the string.
  ///
  /// The options will be joined together with a comma: `customOptions.join("\n")`.
  ///
  /// DO NOT ADD options which are already handled by the adapter.
  /// {@endtemplate}
  final List<String>? customOptions;

  /// {@template HtmlEditorField.allowUrlLoading}
  /// If the editor should allow the default behavior for `url` handling when the user clicks/taps
  /// on one.
  ///
  /// It provides a [Uri] so the developer can check what url was pressed.
  ///
  /// For Android, iOS, macOS it calls [InAppWebView.shouldOverrideUrlLoading] to provide the [Uri].
  /// For web, due to limitations, this method is called only when the editor is loaded and the
  /// `uri` value is `null`.
  ///
  /// If you need to get the url pressed by the user, use [onUrlPressed]. That callback is called
  /// on all platforms when the user taps/clicks a url.
  ///
  /// If not implemented, the default behavior is left to the platform.
  /// {@endtemplate}
  final Future<bool> Function(Uri? uri)? allowUrlLoading;

  /// {@template HtmlEditorField.onInit}
  /// Callback to be called when the editor is initialized.
  /// {@endtemplate}
  final VoidCallback? onInit;

  /// {@template HtmlEditorField.onFocus}
  /// Callback to be called when the editor gains focus.
  /// {@endtemplate}
  final VoidCallback? onFocus;

  /// {@template HtmlEditorField.onBlur}
  /// Callback to be called when the editor loses focus.
  /// {@endtemplate}
  final VoidCallback? onBlur;

  /// {@template HtmlEditorField.onImageUpload}
  /// Callback to be called when the user inserts an image.
  /// {@endtemplate}
  final ValueChanged<HtmlEditorFile>? onImageUpload;

  /// {@template HtmlEditorField.onImageUploadError}
  /// Callback to be called when an error occurs while uploading an image.
  /// {@endtemplate}
  final ValueChanged<HtmlEditorUploadError>? onImageUploadError;

  /// {@template HtmlEditorField.onKeyup}
  /// Callback to be called when a key is released.
  /// {@endtemplate}
  final ValueChanged<int>? onKeyup;

  /// {@template HtmlEditorField.onKeydown}
  /// Callback to be called when a key is pressed.
  /// {@endtemplate}
  final ValueChanged<int>? onKeydown;

  /// {@template HtmlEditorField.onMouseUp}
  /// Callback to be called when the user presses the mouse button while the cursor is in editor.
  /// {@endtemplate}
  final VoidCallback? onMouseUp;

  /// {@template HtmlEditorField.onMouseDown}
  /// Callback to be called when the user releases the mouse button while the cursor is in editor.
  /// {@endtemplate}
  final VoidCallback? onMouseDown;

  /// {@template HtmlEditorField.onChange}
  /// Callback to be called when the user changes the text in the editor.
  /// {@endtemplate}
  final ValueChanged<String>? onChange;

  /// {@template HtmlEditorField.onUrlPressed}
  /// Callback to be called when the taps/clicks a url inside the editor.
  ///
  /// Only when the user taps/clicks an `<a>` tag.
  /// {@endtemplate}
  final ValueChanged<String>? onUrlPressed;

  /// {@template HtmlEditorField.onSelectionChange}
  /// Callback to be called when the content, or part of it, is selected by the user.
  /// {@endtemplate}
  final ValueChanged<String>? onSelectionChange;

  /// {@template HtmlEditorField.cssBuilder}
  /// Used to build custom CSS code for the editor.
  ///
  /// Should return a [String] containing valid CSS code.
  ///
  /// The default builder uses the current [ThemeData] to ensure the editor is always displayed
  /// correctly.
  ///
  /// If you need to use a custom CSS or add your own styles, you can provide a custom builder.
  /// The builder provides the current CSS string used and the current [ThemeData]. So you can
  /// append or prepend your CSS to your liking.
  ///
  /// Example of appending custom CSS:
  /// ```dart
  /// HtmlEditorField(
  ///   cssBuilder: (css, themeData) => [
  ///     css,
  ///     CssBuilder.elementCss(
  ///       selector: '.note-editable',
  ///       style: {
  ///         'color': CssBuilder.hexFromColor(color: themeData.colorScheme.onSurface),
  ///         'background-color': CssBuilder.hexFromColor(color: themeData.colorScheme.surface),
  ///       },
  ///     ),
  ///   ].join(),
  /// )
  /// ```
  /// {@endtemplate}
  final String Function(String css, ThemeData themeData)? cssBuilder;

  /// {@template HtmlEditorField.jsInitBuilder}
  /// Used to build custom JavaScript code for initialising Summernote editor.
  ///
  /// Should return a [String] containing valid JavaScript code.
  ///
  /// It provides the default implementation, to allow developers to prepend/append custom code.
  ///
  /// Example of appending custom code:
  /// ```dart
  /// HtmlEditorField(
  ///   jsInitBuilder: (js) => [
  ///     js,
  ///     "console.log('Hello from JS!');",
  ///   ].join(),
  /// )
  /// ```
  /// Keep in mind that the summernote editor is in jQuery.ready() function.
  /// For building the Js code you can use [JsBuilder].
  /// {@endtemplate}
  final String Function(String js)? jsInitBuilder;

  const HtmlEditorField({
    super.key,
    required this.controller,
    this.resizeMode = ResizeMode.resizeToParent,
    this.inAppWebViewSettings,
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
    this.hint,
    this.onMouseUp,
    this.onMouseDown,
    this.onChange,
    this.onUrlPressed,
    this.cssBuilder,
    this.jsInitBuilder,
    this.onSelectionChange,
  });

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Unsupported in this environment"));
}
