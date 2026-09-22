import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'editor_selection_state.dart';

@immutable
class HtmlEditorValue extends Equatable {
  final String html;

  /// Check if the [html] string is not empty.
  ///
  /// It trims the string and checks if it's not empty.
  bool get hasValue => html.trim().isNotEmpty;

  final EditorSelectionState _selectionState;

  /// {@template HtmlEditorValue.selectionState}
  /// The state of the selected text from the editor.
  ///
  /// It is used to manage the state of the toolbar buttons.
  ///
  /// The value is set internally by the editor field and is read-only.
  /// {@endtemplate}
  EditorSelectionState get selectionState => _selectionState;

  @override
  List<Object?> get props => [html, _selectionState];
  @override
  bool? get stringify => true;

  const HtmlEditorValue._({required this.html, required EditorSelectionState selectionState})
    : _selectionState = selectionState;

  const HtmlEditorValue({this.html = ""}) : _selectionState = const EditorSelectionState();

  const HtmlEditorValue.initial({String? html})
    : html = html ?? "",
      _selectionState = const EditorSelectionState();

  /// Make a new instance from another [HtmlEditorValue].
  factory HtmlEditorValue.clone(HtmlEditorValue other) =>
      HtmlEditorValue._(html: other.html, selectionState: other.selectionState);

  @internal
  HtmlEditorValue copyWith({String? html, EditorSelectionState? selectionState}) {
    return HtmlEditorValue._(
      html: html ?? this.html,
      selectionState: selectionState ?? _selectionState,
    );
  }
}
