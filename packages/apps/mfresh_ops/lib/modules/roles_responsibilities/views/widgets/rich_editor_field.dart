import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class CharStyle {
  bool isBold;
  bool isItalic;

  CharStyle({this.isBold = false, this.isItalic = false});

  CharStyle copy() => CharStyle(isBold: isBold, isItalic: isItalic);
}

class RichTextEditingController extends TextEditingController {
  final List<CharStyle> _charStyles = [];
  bool isBoldActive = false;
  bool isItalicActive = false;
  String _lastText = '';

  RichTextEditingController({super.text}) {
    _lastText = text;
    _charStyles.addAll(List.generate(_lastText.length, (_) => CharStyle()));
  }

  factory RichTextEditingController.fromHtml(String? html) {
    final controller = RichTextEditingController();
    if (html != null && html.trim().isNotEmpty) {
      controller.setHtmlContent(html);
    }
    return controller;
  }

  void setHtmlContent(String html) {
    if (html.trim().isEmpty) {
      _lastText = '';
      _charStyles.clear();
      super.value = const TextEditingValue(text: '');
      return;
    }

    final sb = StringBuffer();
    final styles = <CharStyle>[];

    bool curBold = false;
    bool curItalic = false;

    final regExp = RegExp(r'<[^>]+>|[^<]+');
    final matches = regExp.allMatches(html);

    for (final match in matches) {
      final token = match.group(0)!;
      if (token.startsWith('<')) {
        final lower = token.toLowerCase();
        if (lower.startsWith('<strong') || lower.startsWith('<b')) {
          curBold = true;
        } else if (lower.startsWith('</strong') || lower.startsWith('</b')) {
          curBold = false;
        } else if (lower.startsWith('<em') || lower.startsWith('<i')) {
          curItalic = true;
        } else if (lower.startsWith('</em') || lower.startsWith('</i')) {
          curItalic = false;
        } else if (lower.startsWith('<li')) {
          sb.write('• ');
          styles.add(CharStyle());
          styles.add(CharStyle());
        } else if (lower.startsWith('</li>') || lower.startsWith('</p>') || lower.startsWith('</h3>') || lower.startsWith('</h2>') || lower.startsWith('<br')) {
          if (sb.isNotEmpty && !sb.toString().endsWith('\n')) {
            sb.write('\n');
            styles.add(CharStyle());
          }
        }
      } else {
        String decoded = token
            .replaceAll('&amp;', '&')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>');

        for (int i = 0; i < decoded.length; i++) {
          sb.write(decoded[i]);
          styles.add(CharStyle(isBold: curBold, isItalic: curItalic));
        }
      }
    }

    String resultText = sb.toString();
    _lastText = resultText;
    _charStyles.clear();
    _charStyles.addAll(styles);

    super.value = TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
    );
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = _lastText;
    final newText = newValue.text;
    _syncStyles(oldText, newText);
    _lastText = newText;
    super.value = newValue;
  }

  void _syncStyles(String oldText, String newText) {
    if (oldText == newText) return;

    while (_charStyles.length < oldText.length) {
      _charStyles.add(CharStyle());
    }
    if (_charStyles.length > oldText.length) {
      _charStyles.removeRange(oldText.length, _charStyles.length);
    }

    int prefix = 0;
    while (prefix < oldText.length && prefix < newText.length && oldText[prefix] == newText[prefix]) {
      prefix++;
    }

    int suffix = 0;
    while (suffix < (oldText.length - prefix) &&
           suffix < (newText.length - prefix) &&
           oldText[oldText.length - 1 - suffix] == newText[newText.length - 1 - suffix]) {
      suffix++;
    }

    int deletedCount = oldText.length - prefix - suffix;
    int insertedCount = newText.length - prefix - suffix;

    if (deletedCount > 0) {
      _charStyles.removeRange(prefix, prefix + deletedCount);
    }

    if (insertedCount > 0) {
      final newItems = List.generate(
        insertedCount,
        (_) => CharStyle(isBold: isBoldActive, isItalic: isItalicActive),
      );
      _charStyles.insertAll(prefix, newItems);
    }
  }

  void toggleBoldForSelection(TextSelection selection) {
    if (!selection.isValid || selection.start == selection.end) {
      isBoldActive = !isBoldActive;
      notifyListeners();
      return;
    }

    int start = selection.start.clamp(0, text.length);
    int end = selection.end.clamp(0, text.length);

    bool allBold = true;
    for (int i = start; i < end; i++) {
      if (i < _charStyles.length && !_charStyles[i].isBold) {
        allBold = false;
        break;
      }
    }

    bool targetBold = !allBold;
    isBoldActive = targetBold;

    for (int i = start; i < end; i++) {
      if (i < _charStyles.length) {
        _charStyles[i].isBold = targetBold;
      }
    }
    notifyListeners();
  }

  void toggleItalicForSelection(TextSelection selection) {
    if (!selection.isValid || selection.start == selection.end) {
      isItalicActive = !isItalicActive;
      notifyListeners();
      return;
    }

    int start = selection.start.clamp(0, text.length);
    int end = selection.end.clamp(0, text.length);

    bool allItalic = true;
    for (int i = start; i < end; i++) {
      if (i < _charStyles.length && !_charStyles[i].isItalic) {
        allItalic = false;
        break;
      }
    }

    bool targetItalic = !allItalic;
    isItalicActive = targetItalic;

    for (int i = start; i < end; i++) {
      if (i < _charStyles.length) {
        _charStyles[i].isItalic = targetItalic;
      }
    }
    notifyListeners();
  }

  String toHtml() {
    final textVal = text;
    if (textVal.trim().isEmpty) return '';

    final lines = textVal.split('\n');
    final sb = StringBuffer();
    int charIndex = 0;
    bool inList = false;

    for (int l = 0; l < lines.length; l++) {
      final line = lines[l];
      final lineLen = line.length;
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        charIndex += lineLen + 1;
        continue;
      }

      final isBullet = trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*');

      if (isBullet) {
        if (!inList) {
          sb.write('<ul>');
          inList = true;
        }
        final match = RegExp(r'^\s*[•\-\*]\s*').firstMatch(line)!;
        final prefixLen = match.group(0)!.length;
        final content = _getLineHtmlWithStyles(line.substring(prefixLen), charIndex + prefixLen);
        sb.write('<li>$content</li>');
      } else {
        if (inList) {
          sb.write('</ul>');
          inList = false;
        }
        final content = _getLineHtmlWithStyles(line, charIndex);
        if (l == 0) {
          sb.write('<h3>$content</h3>');
        } else {
          sb.write('<p>$content</p>');
        }
      }

      charIndex += lineLen + 1;
    }

    if (inList) {
      sb.write('</ul>');
    }

    return sb.toString();
  }

  String _getLineHtmlWithStyles(String lineText, int lineStartIndex) {
    if (lineText.isEmpty) return '';

    final sb = StringBuffer();
    int i = 0;

    while (i < lineText.length) {
      final idx = lineStartIndex + i;
      final bool curBold = (idx < _charStyles.length) ? _charStyles[idx].isBold : false;
      final bool curItalic = (idx < _charStyles.length) ? _charStyles[idx].isItalic : false;

      int runEnd = i + 1;
      while (runEnd < lineText.length) {
        final nextIdx = lineStartIndex + runEnd;
        final bool nextBold = (nextIdx < _charStyles.length) ? _charStyles[nextIdx].isBold : false;
        final bool nextItalic = (nextIdx < _charStyles.length) ? _charStyles[nextIdx].isItalic : false;
        if (nextBold != curBold || nextItalic != curItalic) break;
        runEnd++;
      }

      String segment = lineText.substring(i, runEnd);
      if (curBold) segment = '<strong>$segment</strong>';
      if (curItalic) segment = '<em>$segment</em>';

      sb.write(segment);
      i = runEnd;
    }

    return sb.toString();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final textVal = text;
    if (textVal.isEmpty) {
      return TextSpan(style: style);
    }

    final baseStyle = style ?? const TextStyle(color: Colors.black, fontSize: 13);
    final spans = <InlineSpan>[];

    while (_charStyles.length < textVal.length) {
      _charStyles.add(CharStyle());
    }

    int index = 0;
    final lines = textVal.split('\n');

    for (int l = 0; l < lines.length; l++) {
      final line = lines[l];
      final isLast = (l == lines.length - 1);
      final lineWithNL = isLast ? line : '$line\n';

      final trimmed = line.trim();
      if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
        final bulletMatch = RegExp(r'^\s*[•\-\*]\s*').firstMatch(lineWithNL);
        if (bulletMatch != null) {
          final bulletLen = bulletMatch.group(0)!.length;
          spans.add(TextSpan(
            text: lineWithNL.substring(0, bulletLen),
            style: baseStyle.copyWith(color: const Color(0xFFF2562B), fontWeight: FontWeight.bold),
          ));
          _appendStyledSubString(
            lineWithNL.substring(bulletLen),
            index + bulletLen,
            baseStyle,
            spans,
          );
        } else {
          _appendStyledSubString(lineWithNL, index, baseStyle, spans);
        }
      } else if (RegExp(r'^\s*\d+\.\s*').hasMatch(line)) {
        final numMatch = RegExp(r'^\s*\d+\.\s*').firstMatch(lineWithNL);
        if (numMatch != null) {
          final numLen = numMatch.group(0)!.length;
          spans.add(TextSpan(
            text: lineWithNL.substring(0, numLen),
            style: baseStyle.copyWith(color: const Color(0xFFF2562B), fontWeight: FontWeight.bold),
          ));
          _appendStyledSubString(
            lineWithNL.substring(numLen),
            index + numLen,
            baseStyle,
            spans,
          );
        } else {
          _appendStyledSubString(lineWithNL, index, baseStyle, spans);
        }
      } else {
        _appendStyledSubString(lineWithNL, index, baseStyle, spans);
      }

      index += lineWithNL.length;
    }

    return TextSpan(children: spans);
  }

  void _appendStyledSubString(
    String subStr,
    int startIndex,
    TextStyle baseStyle,
    List<InlineSpan> spans,
  ) {
    if (subStr.isEmpty) return;

    int i = 0;
    while (i < subStr.length) {
      final idx = startIndex + i;
      final bool curBold = (idx < _charStyles.length) ? _charStyles[idx].isBold : false;
      final bool curItalic = (idx < _charStyles.length) ? _charStyles[idx].isItalic : false;

      int runEnd = i + 1;
      while (runEnd < subStr.length) {
        final nextIdx = startIndex + runEnd;
        final bool nextBold = (nextIdx < _charStyles.length) ? _charStyles[nextIdx].isBold : false;
        final bool nextItalic = (nextIdx < _charStyles.length) ? _charStyles[nextIdx].isItalic : false;
        if (nextBold != curBold || nextItalic != curItalic) break;
        runEnd++;
      }

      TextStyle runStyle = baseStyle;
      if (curBold) runStyle = runStyle.copyWith(fontWeight: FontWeight.bold);
      if (curItalic) runStyle = runStyle.copyWith(fontStyle: FontStyle.italic);

      spans.add(TextSpan(
        text: subStr.substring(i, runEnd),
        style: runStyle,
      ));

      i = runEnd;
    }
  }
}

class RichEditorField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const RichEditorField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  State<RichEditorField> createState() => _RichEditorFieldState();
}

class _RichEditorFieldState extends State<RichEditorField> {
  String _selectedFormat = 'Paragraph';
  bool _isBoldActive = false;
  bool _isItalicActive = false;
  bool _isBulletActive = false;
  bool _isNumberedActive = false;
  String? _previousText;

  @override
  void initState() {
    super.initState();
    _previousText = widget.controller.text;
  }

  void _insertPrefix(String prefix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final start = selection.isValid ? selection.start : text.length;

    final newText = text.replaceRange(start, start, prefix);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + prefix.length),
    );
    _previousText = newText;
  }

  void _toggleBold() {
    if (widget.controller is RichTextEditingController) {
      final richCtrl = widget.controller as RichTextEditingController;
      richCtrl.toggleBoldForSelection(widget.controller.selection);
      setState(() {
        _isBoldActive = richCtrl.isBoldActive;
      });
    } else {
      setState(() => _isBoldActive = !_isBoldActive);
    }
  }

  void _toggleItalic() {
    if (widget.controller is RichTextEditingController) {
      final richCtrl = widget.controller as RichTextEditingController;
      richCtrl.toggleItalicForSelection(widget.controller.selection);
      setState(() {
        _isItalicActive = richCtrl.isItalicActive;
      });
    } else {
      setState(() => _isItalicActive = !_isItalicActive);
    }
  }

  void _toggleBullet() {
    setState(() {
      _isBulletActive = !_isBulletActive;
      if (_isBulletActive) {
        _isNumberedActive = false;
      }
    });
    if (_isBulletActive) {
      _insertPrefix('• ');
    }
  }

  void _toggleNumbered() {
    setState(() {
      _isNumberedActive = !_isNumberedActive;
      if (_isNumberedActive) {
        _isBulletActive = false;
      }
    });
    if (_isNumberedActive) {
      _insertPrefix('1. ');
    }
  }

  void _handleOnChanged(String value) {
    if (_previousText != null && value.length > _previousText!.length) {
      final diff = value.substring(_previousText!.length);

      if (diff == '\n') {
        final lines = _previousText!.split('\n');
        if (lines.isNotEmpty) {
          final lastLine = lines.last;
          final trimmedLast = lastLine.trim();

          if (trimmedLast.startsWith('•') || trimmedLast.startsWith('-') || trimmedLast.startsWith('*')) {
            if (trimmedLast == '•' || trimmedLast == '-' || trimmedLast == '*') {
              final updated = List<String>.from(lines)..removeLast();
              final resultText = updated.isEmpty ? '' : '${updated.join('\n')}\n';
              widget.controller.value = TextEditingValue(
                text: resultText,
                selection: TextSelection.collapsed(offset: resultText.length),
              );
              setState(() => _isBulletActive = false);
            } else {
              final resultText = '$value• ';
              widget.controller.value = TextEditingValue(
                text: resultText,
                selection: TextSelection.collapsed(offset: resultText.length),
              );
              setState(() => _isBulletActive = true);
            }
          } else if (RegExp(r'^\d+\.').hasMatch(trimmedLast)) {
            final match = RegExp(r'^(\d+)\.').firstMatch(trimmedLast);
            if (match != null) {
              final numVal = int.parse(match.group(1)!);
              if (trimmedLast == '$numVal.') {
                final updated = List<String>.from(lines)..removeLast();
                final resultText = updated.isEmpty ? '' : '${updated.join('\n')}\n';
                widget.controller.value = TextEditingValue(
                  text: resultText,
                  selection: TextSelection.collapsed(offset: resultText.length),
                );
                setState(() => _isNumberedActive = false);
              } else {
                final nextNum = numVal + 1;
                final resultText = '$value$nextNum. ';
                widget.controller.value = TextEditingValue(
                  text: resultText,
                  selection: TextSelection.collapsed(offset: resultText.length),
                );
                setState(() => _isNumberedActive = true);
              }
            }
          }
        }
      }
    }
    _previousText = widget.controller.text;
    _updateActiveStatesFromCursor();
  }

  void _updateActiveStatesFromCursor() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    if (!selection.isValid) return;

    final pos = selection.start;
    final lines = text.substring(0, pos).split('\n');
    final currentLine = lines.isEmpty ? '' : lines.last.trim();

    final isBullet = currentLine.startsWith('•') || currentLine.startsWith('-') || currentLine.startsWith('*');
    final isNumber = RegExp(r'^\d+\.').hasMatch(currentLine);

    if (widget.controller is RichTextEditingController) {
      final richCtrl = widget.controller as RichTextEditingController;
      final idx = pos > 0 ? pos - 1 : 0;
      if (idx < text.length && richCtrl._charStyles.isNotEmpty) {
        final style = richCtrl._charStyles[idx.clamp(0, richCtrl._charStyles.length - 1)];
        setState(() {
          _isBoldActive = richCtrl.isBoldActive || style.isBold;
          _isItalicActive = richCtrl.isItalicActive || style.isItalic;
        });
      }
    }

    if (isBullet != _isBulletActive || isNumber != _isNumberedActive) {
      setState(() {
        _isBulletActive = isBullet;
        _isNumberedActive = isNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyle.style_12_600(color: AppColors.black),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Formatting Toolbar ──────────────────────────────────────────
              Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    // Format Dropdown
                    Container(
                      height: 26.h,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFormat,
                          isDense: true,
                          style: AppTextStyle.style_11_400(color: AppColors.black),
                          items: const [
                            DropdownMenuItem(value: 'Paragraph', child: Text('Paragraph')),
                            DropdownMenuItem(value: 'Heading 2', child: Text('Heading 2')),
                            DropdownMenuItem(value: 'Heading 3', child: Text('Heading 3')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedFormat = v);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const VerticalDivider(width: 12, indent: 8, endIndent: 8, color: Color(0xFFD1D5DB)),
                    
                    // Bold Button
                    _buildToolbarButton(
                      iconText: 'B',
                      isBold: true,
                      isActive: _isBoldActive,
                      onTap: _toggleBold,
                    ),
                    SizedBox(width: 4.w),

                    // Italic Button
                    _buildToolbarButton(
                      iconText: 'I',
                      isItalic: true,
                      isActive: _isItalicActive,
                      onTap: _toggleItalic,
                    ),
                    SizedBox(width: 4.w),

                    const VerticalDivider(width: 12, indent: 8, endIndent: 8, color: Color(0xFFD1D5DB)),

                    // Bullet List Button
                    _buildToolbarButton(
                      iconData: Icons.format_list_bulleted,
                      isActive: _isBulletActive,
                      onTap: _toggleBullet,
                    ),
                    SizedBox(width: 4.w),

                    // Numbered List Button
                    _buildToolbarButton(
                      iconData: Icons.format_list_numbered,
                      isActive: _isNumberedActive,
                      onTap: _toggleNumbered,
                    ),
                    SizedBox(width: 4.w),

                    // Quote Button
                    _buildToolbarButton(
                      iconData: Icons.format_quote,
                      onTap: () => _insertPrefix('> '),
                    ),
                  ],
                ),
              ),

              // ── Text Input Area ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(8.r),
                child: TextField(
                  controller: widget.controller,
                  onChanged: _handleOnChanged,
                  maxLines: 8,
                  minLines: 5,
                  style: AppTextStyle.style_12_400(color: AppColors.grey900),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    String? iconText,
    IconData? iconData,
    bool isBold = false,
    bool isItalic = false,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 26.r,
        height: 26.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: isActive ? const Color(0xFFF2562B) : const Color(0xFFE5E7EB),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: iconData != null
            ? Icon(
                iconData,
                size: 14.r,
                color: isActive ? const Color(0xFFF2562B) : AppColors.grey700,
              )
            : Text(
                iconText ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  color: isActive ? const Color(0xFFF2562B) : AppColors.grey800,
                ),
              ),
      ),
    );
  }
}

