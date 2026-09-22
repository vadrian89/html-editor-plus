import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

/// Class used to build the CSS string for the editor.
///
/// The CSS will be based of current [Theme.colorScheme] to ensure the editor is always
/// displayed with the correct colors. Both in light and dark modes.
class CssBuilder {
  /// Get the hex code for the [color].
  ///
  /// `#` is added to the start of the hex code.
  static String hexFromColor({Color? color}) => (color != null) ? "#${color.hex}" : "";

  /// Build CSS for an html element.
  ///
  /// [selector] is the element selector, like `body` or `h1`. You can chain selectors
  /// like `body h1` or `body, h1`, etc.
  /// [properties] is a map of CSS properties and values, like `color: #000000;`.
  ///
  /// Example of string built:
  /// ```dart
  /// CssBuilder.elementCss(
  ///  selector: '.note-editable',
  ///   properties: {
  ///   'color': '#000000',
  ///   'background-color': '#ffffff',
  ///   }
  /// );
  /// ```
  /// Result:
  /// ```css
  /// .note-editable {
  ///  color: #000000;
  ///  background-color: #ffffff;
  /// }
  /// ```
  static String elementCss({required String selector, required Map<String, String> properties}) {
    var css = '$selector{';
    for (final entry in properties.entries) {
      css += '${entry.key}:${entry.value};';
    }
    css += '}';
    return css;
  }

  /// Build the css for the Summernote editor, using [Theme.colorScheme] to adhere to Material 2.0.
  static String editor({required ColorScheme colorScheme}) => elementCss(
    selector: '.note-editable',
    properties: {
      'color': hexFromColor(color: colorScheme.onSurface),
      'background-color': hexFromColor(color: colorScheme.surface),
    },
  );

  /// Build the CSS for the Summernote editor, when it's disabled.
  static String editorDisabled({required ThemeData theme}) => elementCss(
    selector: '.note-editing-area .note-editable[contenteditable=false]',
    properties: {'background-color': "${hexFromColor(color: theme.disabledColor)}61 !important"},
  );

  /// Build the CSS for the placeholder
  static String placeholder({required ColorScheme colorScheme}) => elementCss(
    selector: '.note-placeholder',
    properties: {'color': "${hexFromColor(color: colorScheme.onSurface)}73"},
  );

  /// Build the CSS for dialog
  static String dialog({required ColorScheme colorScheme}) {
    final backgroundColor = hexFromColor(color: colorScheme.surface);
    final foregroundColor = hexFromColor(color: colorScheme.onSurface);
    final shadowColor = "${hexFromColor(color: colorScheme.shadow)}20";
    final dialog = elementCss(
      selector: ['.note-dialog', '.note-popover'].join(','),
      properties: {
        'background-color': backgroundColor,
        'color': foregroundColor,
        'border-color': "${foregroundColor}12",
        'box-shadow': "0 5px 10px $shadowColor",
      },
    );
    final bottomArrowCss = elementCss(
      selector: '.note-popover.bottom .note-popover-arrow',
      properties: {'border-bottom-color': shadowColor},
    );
    final bottomArrowAfterCss = elementCss(
      selector: '.note-popover.bottom .note-popover-arrow:after',
      properties: {'border-bottom-color': backgroundColor},
    );
    final topArrowCss = elementCss(
      selector: '.note-popover.top .note-popover-arrow',
      properties: {'border-top-color': shadowColor},
    );
    final topArrowAfterCss = elementCss(
      selector: '.note-popover.top .note-popover-arrow:after',
      properties: {'border-top-color': backgroundColor},
    );
    final rightArrowCss = elementCss(
      selector: '.note-popover.right .note-popover-arrow',
      properties: {'border-right-color': shadowColor},
    );
    final rightArrowAfterCss = elementCss(
      selector: '.note-popover.right .note-popover-arrow:after',
      properties: {'border-right-color': backgroundColor},
    );
    final leftArrowCss = elementCss(
      selector: '.note-popover.right .note-popover-arrow',
      properties: {'border-right-color': shadowColor},
    );
    final leftArrowAfterCss = elementCss(
      selector: '.note-popover.left .note-popover-arrow:after',
      properties: {'border-left-color': backgroundColor},
    );
    return [
      dialog,
      bottomArrowCss,
      bottomArrowAfterCss,
      topArrowCss,
      topArrowAfterCss,
      rightArrowCss,
      rightArrowAfterCss,
      leftArrowCss,
      leftArrowAfterCss,
    ].join();
  }

  /// Build the CSS for modal dialog
  static String modal({required ColorScheme colorScheme}) {
    final borderColor = "${hexFromColor(color: colorScheme.outline)}AA";
    final modal = elementCss(
      selector: '.note-modal-content',
      properties: {
        'background': hexFromColor(color: colorScheme.surface),
        'border-color': borderColor,
        'box-shadow': "0 5px 10px ${hexFromColor(color: colorScheme.shadow)}50",
      },
    );
    final modalHeader = elementCss(
      selector: '.note-modal-header',
      properties: {'border': 'none', 'border-bottom': "1px solid $borderColor"},
    );
    final modalfooter = elementCss(
      selector: '.note-modal-footer',
      properties: {'border': 'none', 'border-top': "1px solid $borderColor"},
    );
    final foregroundColor = elementCss(
      selector: '.note-modal-content, .note-modal-title, .note-form-label',
      properties: {'color': hexFromColor(color: colorScheme.onSurface)},
    );

    return [modal, modalHeader, foregroundColor, modalfooter].join();
  }

  /// Build CSS for text inputs
  static String textInput({required ColorScheme colorScheme}) => elementCss(
    selector: "input[type=text]",
    properties: {
      'color': hexFromColor(color: colorScheme.onSurface),
      'background-color': hexFromColor(color: colorScheme.surface),
      'border-color': hexFromColor(color: colorScheme.outline),
    },
  );

  /// Build CSS for close (X) buttons
  static String closeButton({required ColorScheme colorScheme}) => elementCss(
    selector: ".close",
    properties: {'color': hexFromColor(color: colorScheme.onSurface)},
  );

  /// Build the CSS for buttons
  static String elevatedButton({required ColorScheme colorScheme}) => elementCss(
    selector: '.note-btn',
    properties: {
      'background-color': hexFromColor(color: colorScheme.primary),
      'color': hexFromColor(color: colorScheme.onPrimary),
      'border-color': hexFromColor(color: colorScheme.inversePrimary),
    },
  );

  /// Build the CSS for buttons when they are hovered/focused =>
  static String buttonsHovered({required ColorScheme colorScheme}) => elementCss(
    selector: ['.note-btn:hover', '.note-btn:active'].join(','),
    properties: {
      'color': hexFromColor(color: colorScheme.onPrimaryContainer),
      'background-color': hexFromColor(color: colorScheme.primaryContainer),
      'border-color': hexFromColor(color: colorScheme.inversePrimary),
    },
  );

  /// Build the CSS to hide the status bar
  static String statusBar() =>
      elementCss(selector: '.note-statusbar', properties: {'display': 'none'});

  /// Build the CSS for URLs
  static String urls({required ColorScheme colorScheme}) => elementCss(
    selector: [
      '.note-editable a',
      '.note-popover a',
      '.note-editable a:hover',
      '.note-popover a:hover',
      '.note-editable a:focus',
      '.note-popover a:focus',
    ].join(','),
    properties: {
      'color': hexFromColor(color: colorScheme.primary),
      'text-decoration': 'underline',
    },
  );

  /// Build the CSS for Summernote editor
  ///
  /// If [hideStatusBar] is `true`, the status bar will be hidden, using `display: none;` css.s
  static String buildCss({required ThemeData theme, bool hideStatusBar = true}) {
    final colorScheme = theme.colorScheme;
    return [
      editor(colorScheme: colorScheme),
      placeholder(colorScheme: colorScheme),
      dialog(colorScheme: colorScheme),
      urls(colorScheme: colorScheme),
      elevatedButton(colorScheme: colorScheme),
      buttonsHovered(colorScheme: colorScheme),
      modal(colorScheme: colorScheme),
      textInput(colorScheme: colorScheme),
      closeButton(colorScheme: colorScheme),
      editorDisabled(theme: theme),
      if (hideStatusBar) statusBar(),
    ].join("");
  }
}
