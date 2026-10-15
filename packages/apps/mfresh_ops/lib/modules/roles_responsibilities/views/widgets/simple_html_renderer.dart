import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class SimpleHtmlRenderer extends StatelessWidget {
  final String htmlContent;
  final TextStyle? baseStyle;

  const SimpleHtmlRenderer({
    super.key,
    required this.htmlContent,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (htmlContent.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final blocks = _parseHtmlToBlocks(htmlContent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks.map((block) => _buildBlockWidget(block)).toList(),
    );
  }

  Widget _buildBlockWidget(_HtmlBlock block) {
    switch (block.tag) {
      case 'h1':
      case 'h2':
        return Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
          child: Text(
            block.text,
            style: AppTextStyle.style_16_700(color: AppColors.black),
          ),
        );
      case 'h3':
        return Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
          child: Text(
            block.text,
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
        );
      case 'h4':
        return Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
          child: Text(
            block.text,
            style: AppTextStyle.style_13_600(color: AppColors.black),
          ),
        );
      case 'ul':
      case 'ol':
        return Padding(
          padding: EdgeInsets.only(left: 4.w, top: 4.h, bottom: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.children.map((childBlock) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTextStyle.style_14_700(color: const Color(0xFFF2562B)),
                    ),
                    Expanded(
                      child: Text.rich(
                        _buildTextSpan(childBlock.rawContent),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      case 'blockquote':
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F5),
            border: const Border(
              left: BorderSide(color: Color(0xFFF2562B), width: 4),
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text.rich(_buildTextSpan(block.rawContent)),
        );
      case 'p':
      default:
        if (block.text.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text.rich(_buildTextSpan(block.rawContent)),
        );
    }
  }

  InlineSpan _buildTextSpan(String rawHtml) {
    final String clean = rawHtml
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    final spans = <InlineSpan>[];
    final defaultStyle = baseStyle ?? AppTextStyle.style_13_400(color: AppColors.grey900).copyWith(height: 1.4);

    bool isBold = false;
    bool isItalic = false;

    final regExp = RegExp(r'<[^>]+>|[^<]+');
    final matches = regExp.allMatches(clean);

    for (final match in matches) {
      final token = match.group(0)!;
      if (token.startsWith('<')) {
        final lower = token.toLowerCase();
        if (lower.startsWith('<strong') || lower.startsWith('<b')) {
          isBold = true;
        } else if (lower.startsWith('</strong') || lower.startsWith('</b')) {
          isBold = false;
        } else if (lower.startsWith('<em') || lower.startsWith('<i')) {
          isItalic = true;
        } else if (lower.startsWith('</em') || lower.startsWith('</i')) {
          isItalic = false;
        }
      } else {
        if (token.isNotEmpty) {
          TextStyle currentStyle = defaultStyle;
          if (isBold) currentStyle = currentStyle.copyWith(fontWeight: FontWeight.w700);
          if (isItalic) currentStyle = currentStyle.copyWith(fontStyle: FontStyle.italic);

          spans.add(TextSpan(
            text: token,
            style: currentStyle,
          ));
        }
      }
    }

    if (spans.isEmpty) {
      return TextSpan(text: '', style: defaultStyle);
    }

    return TextSpan(children: spans);
  }

  List<_HtmlBlock> _parseHtmlToBlocks(String html) {
    final blocks = <_HtmlBlock>[];
    final String clean = html.replaceAll('\r\n', '\n');

    final regExp = RegExp(r'<(h[1-6]|p|ul|ol|blockquote)[\s\S]*?>([\s\S]*?)<\/\1>', caseSensitive: false);
    final matches = regExp.allMatches(clean);

    if (matches.isEmpty) {
      final lines = clean.split('\n');
      final bulletChildren = <_HtmlBlock>[];

      for (final l in lines) {
        final trimmed = l.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
          final itemText = trimmed.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim();
          bulletChildren.add(_HtmlBlock(tag: 'li', text: itemText, rawContent: itemText));
        } else if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          final itemText = trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
          bulletChildren.add(_HtmlBlock(tag: 'li', text: itemText, rawContent: itemText));
        } else {
          if (bulletChildren.isNotEmpty) {
            blocks.add(_HtmlBlock(tag: 'ul', text: '', rawContent: '', children: List.from(bulletChildren)));
            bulletChildren.clear();
          }
          blocks.add(_HtmlBlock(tag: 'p', text: trimmed, rawContent: trimmed));
        }
      }
      if (bulletChildren.isNotEmpty) {
        blocks.add(_HtmlBlock(tag: 'ul', text: '', rawContent: '', children: List.from(bulletChildren)));
      }
      return blocks;
    }

    for (final m in matches) {
      final tag = m.group(1)!.toLowerCase();
      final innerContent = m.group(2) ?? '';

      if (tag == 'ul' || tag == 'ol') {
        final liMatches = RegExp(r'<li[\s\S]*?>([\s\S]*?)<\/li>', caseSensitive: false).allMatches(innerContent);
        final children = <_HtmlBlock>[];
        for (final li in liMatches) {
          final liText = li.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&amp;', '&').trim() ?? '';
          children.add(_HtmlBlock(tag: 'li', text: liText, rawContent: li.group(1) ?? ''));
        }
        blocks.add(_HtmlBlock(tag: tag, text: '', rawContent: innerContent, children: children));
      } else {
        final plainText = innerContent.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&amp;', '&').trim();
        blocks.add(_HtmlBlock(tag: tag, text: plainText, rawContent: innerContent));
      }
    }

    return blocks;
  }
}

class _HtmlBlock {
  final String tag;
  final String text;
  final String rawContent;
  final List<_HtmlBlock> children;

  _HtmlBlock({
    required this.tag,
    required this.text,
    required this.rawContent,
    this.children = const [],
  });
}
