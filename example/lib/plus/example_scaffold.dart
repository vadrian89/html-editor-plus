// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:html_editor_plus/editor_plus.dart';
import 'package:html_editor_plus_example/plus/core/control_button.dart';
import 'package:html_editor_plus_example/plus/core/controls.dart';

import 'core/app_bar_icon_button.dart';

class HtmlEditorPlusExample extends StatefulWidget {
  const HtmlEditorPlusExample({super.key});

  @override
  State<HtmlEditorPlusExample> createState() => _HtmlEditorPlusExampleState();
}

class _HtmlEditorPlusExampleState extends State<HtmlEditorPlusExample> {
  late final HtmlEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HtmlEditorController(initialHtml: "<b>Some default text</b>")
      ..addListener(_onHtmlChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onHtmlChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _appBar,
    body: Column(
      children: [
        Expanded(
          child: HtmlEditor(
            controller: _controller,
            hint: "Your text here...",
            allowUrlLoading: (uri) async {
              print("allowUrlLoading called with uri: $uri");
              return false;
            },
            jsInitBuilder: (js) =>
                [js, "console.log('Hello from JS!');"].join(),
            onInit: () => print("Editor ready!"),
            onFocus: () => print("Focus gained!"),
            onBlur: () => print("Focus lost!"),
            onImageUpload: (value) => print("Image uploaded: $value"),
            onImageUploadError: (value) =>
                print("Image upload failed with error: $value"),
            onKeyup: (value) => print("Key up event: $value"),
            onKeydown: (value) => print("Key down event: $value"),
            onMouseUp: () => print("Mouse up!"),
            onMouseDown: () => print("Mouse down!"),
            onChange: (value) => print("Value changed: $value"),
            onUrlPressed: (value) => print("URL pressed: $value"),
          ),
        ),
        EditorControls(
          controls: [
            ControlButton(
              onPressed: _controller.clear,
              icon: Icons.clear,
              label: "Clear",
            ),
            ControlButton(
              onPressed: _controller.undo,
              icon: Icons.undo,
              label: "Undo",
            ),
            ControlButton(
              onPressed: _controller.redo,
              icon: Icons.redo,
              label: "Redo",
            ),
            ControlButton(
              onPressed: _controller.disable,
              icon: Icons.edit_off,
              label: "Disable",
            ),
            ControlButton(
              onPressed: _controller.enable,
              icon: Icons.edit,
              label: "Enable",
            ),
            ControlButton(
              onPressed: _controller.requestFocus,
              icon: Icons.keyboard,
              label: "Request focus",
            ),
            ControlButton(
              onPressed: _controller.clearFocus,
              icon: Icons.keyboard_hide,
              label: "Clear focus",
            ),
            ControlButton(
              onPressed: () => _controller.insertText(text: "Inserted text"),
              icon: Icons.note_add,
              label: "Insert text",
            ),
            ControlButton(
              onPressed: () =>
                  _controller.pasteHtml(html: "<b><i>Pasted html</i></b>"),
              icon: Icons.paste,
              label: "Paste html",
            ),
            ControlButton(
              onPressed: _controller.setCursorToEnd,
              icon: Icons.skip_next,
              label: "Set cursor at end",
            ),
            ControlButton(
              onPressed: () => _controller.createLink(
                text: "Google linked",
                url: "https://google.com",
              ),
              icon: Icons.add_link,
              label: "Insert link",
            ),
            ControlButton(
              onPressed: () => _controller.insertNetworkImage(
                url:
                    "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png",
                filename: "Google network image",
              ),
              icon: Icons.add_a_photo,
              label: "Insert a network image",
            ),
          ],
        ),
      ],
    ),
  );

  AppBar get _appBar => AppBar(
    title: const Text('HtmlEditorPlus Example'),
    actions: [
      AppBarIconButton(icon: Icons.refresh, onPressed: _controller.reload),
      AppBarIconButton(icon: Icons.code, onPressed: _controller.toggleCodeView),
    ],
  );

  void _onHtmlChanged() {
    print("Controller HTML value: ${_controller.html}");
    print("Controller character count: ${_controller.characterCount}");
    print("Controller selection state: ${_controller.selectionState}");
  }
}
