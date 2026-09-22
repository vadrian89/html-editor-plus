import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

import 'css_builder.dart';

/// The state of the selection in the editor.
class EditorSelectionState extends Equatable {
  // The parent element of the selection
  final String? parentElement;

  // The name of the font of the selection
  final String? fontName;

  // The size of the font of the selection
  final int? fontSize;

  // Whether the selection is bold
  final bool isBold;

  // Whether the selection is italic
  final bool isItalic;

  // Whether the selection is underlined
  final bool isUnderline;

  // Whether the selection is strikethrough
  final bool isStrikethrough;

  // Whether the selection is superscript
  final bool isSuperscript;

  // Whether the selection is subscript
  final bool isSubscript;

  // The foreground color of the selection
  final Color? foregroundColor;

  // The background color of the selection
  final Color? backgroundColor;

  // Whether the selection is an unordered list
  final bool isUl;

  // Whether the selection is an ordered list
  final bool isOl;

  // The list style of the selection
  final String? listStyle;

  // Whether the selection is aligned to the left
  final bool isAlignLeft;

  // Whether the selection is aligned to the right
  final bool isAlignRight;

  // Whether the selection is centered
  final bool isAlignCenter;

  // Whether the selection is justified
  final bool isAlignJustify;

  // The line height of the selection
  final String? lineHeight;

  // The text direction of the selection
  final TextDirection textDirection;

  @override
  bool? get stringify => true;

  const EditorSelectionState({
    this.parentElement,
    this.fontName,
    this.fontSize,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.isSuperscript = false,
    this.isSubscript = false,
    this.foregroundColor,
    this.backgroundColor,
    this.isUl = false,
    this.isOl = false,
    this.listStyle,
    this.isAlignLeft = false,
    this.isAlignCenter = false,
    this.isAlignRight = false,
    this.isAlignJustify = false,
    this.lineHeight,
    this.textDirection = TextDirection.ltr,
  });

  factory EditorSelectionState.fromEncodedJson(String encodedJson) =>
      EditorSelectionState.fromJson(jsonDecode(encodedJson));

  factory EditorSelectionState.fromJson(Map<String, dynamic> json) => EditorSelectionState(
    parentElement: json["style"],
    fontName: json["fontName"],
    fontSize: int.tryParse(json["fontSize"]?.toString() ?? ""),
    isBold: json["isBold"] ?? false,
    isItalic: json["isItalic"] ?? false,
    isUnderline: json["isUnderline"] ?? false,
    isStrikethrough: json["isStrikethrough"] ?? false,
    isSuperscript: json["isSuperscript"] ?? false,
    isSubscript: json["isSubscript"] ?? false,
    foregroundColor: _colorFromJson(json["foregroundColor"]),
    backgroundColor: _colorFromJson(json["backgroundColor"]),
    isUl: json["isUL"] ?? false,
    isOl: json["isOL"] ?? false,
    listStyle: json["listStyle"],
    isAlignLeft: json["alignLeft"] ?? false,
    isAlignCenter: json["alignCenter"] ?? false,
    isAlignRight: json["alignRight"] ?? false,
    isAlignJustify: json["alignFull"] ?? false,
    lineHeight: json["lineHeight"],
    textDirection: json["direction"] == "rtl" ? TextDirection.rtl : TextDirection.ltr,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    "style": parentElement,
    "fontName": fontName,
    "fontSize": fontSize,
    "isBold": isBold,
    "isItalic": isItalic,
    "isUnderline": isUnderline,
    "isStrikethrough": isStrikethrough,
    "isSuperscript": isSuperscript,
    "isSubscript": isSubscript,
    "foregroundColor": CssBuilder.hexFromColor(color: foregroundColor),
    "backgroundColor": CssBuilder.hexFromColor(color: backgroundColor),
    "isUL": isUl,
    "isOL": isOl,
    "listStyle": listStyle,
    "alignLeft": isAlignLeft,
    "alignCenter": isAlignCenter,
    "alignRight": isAlignRight,
    "alignFull": isAlignJustify,
    "lineHeight": lineHeight,
    "direction": textDirection == TextDirection.rtl ? "rtl" : "ltr",
  };

  @override
  List<Object?> get props => [
    parentElement,
    fontName,
    fontSize,
    isBold,
    isItalic,
    isUnderline,
    isStrikethrough,
    isSuperscript,
    isSubscript,
    foregroundColor,
    backgroundColor,
    isUl,
    isOl,
    listStyle,
    isAlignLeft,
    isAlignCenter,
    isAlignRight,
    isAlignJustify,
    lineHeight,
    textDirection,
  ];
}

Color? _colorFromJson([Object? json]) {
  if (json?.toString().isEmpty ?? true) return null;
  try {
    final jsonString = json.toString();
    if (jsonString.toLowerCase().contains("rgb")) return _fromRGB(jsonString);
    if (jsonString.startsWith("#")) return _fromHex(jsonString);
    return null;
  } catch (e, stackTrace) {
    debugPrintStack(
      label: "Error parsing color ($json) from JSON: $e",
      stackTrace: stackTrace,
      maxFrames: 10,
    );
    return null;
  }
}

Color _fromHex(String hex) {
  final cleanedHex = hex.replaceAll("#", "");
  final colorInt = int.parse(cleanedHex, radix: 16);
  return Color(colorInt + 0xFF000000);
}

Color _fromRGB(String rgb) {
  final values = rgb.replaceAll(RegExp(r"rgb|\(|\)"), "").split(",");
  return Color.fromRGBO(int.parse(values[0]), int.parse(values[1]), int.parse(values[2]), 1);
}
