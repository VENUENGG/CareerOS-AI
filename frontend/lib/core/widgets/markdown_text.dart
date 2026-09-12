import 'package:flutter/material.dart';
import '../../core/design/design.dart';

/// A small, dependency-free Markdown renderer for the AI's plain-text
/// Markdown responses (`#`/`##`/`###` headings, `**bold**`, `-`/`*` bullet
/// lists, `1.` numbered lists, blank-line paragraphs). Deliberately not a
/// full CommonMark implementation -- just enough structure to make a long
/// AI answer scannable instead of a wall of plain text, without adding a
/// new package dependency for it.
class MarkdownText extends StatelessWidget {
  final String data;
  final TextStyle? bodyStyle;
  final Color? accentColor;
  final bool selectable;

  const MarkdownText(
    this.data, {
    super.key,
    this.bodyStyle,
    this.accentColor,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final lines = data.replaceAll('\r\n', '\n').split('\n');
    final blocks = <Widget>[];
    final body = bodyStyle ?? AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6);
    final accent = accentColor ?? AppColors.primary;
    var i = 0;

    bool isBullet(String s) => s.startsWith('- ') || s.startsWith('* ');
    bool isOrdered(String s) => RegExp(r'^\d+\.\s').hasMatch(s);
    bool isHeading(String s) => s.startsWith('#');
    bool isBlockStart(String s) => s.isEmpty || isBullet(s) || isOrdered(s) || isHeading(s);

    while (i < lines.length) {
      final trimmed = lines[i].trim();
      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      if (trimmed.startsWith('### ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
          child: _richText(trimmed.substring(4), AppTypography.titleSmall),
        ));
        i++;
      } else if (trimmed.startsWith('## ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
          child: _richText(trimmed.substring(3), AppTypography.titleMedium),
        ));
        i++;
      } else if (trimmed.startsWith('# ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
          child: _richText(trimmed.substring(2), AppTypography.titleLarge),
        ));
        i++;
      } else if (trimmed == '---' || trimmed == '***') {
        blocks.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Divider(height: 1, color: AppColors.border),
        ));
        i++;
      } else if (isBullet(trimmed)) {
        final items = <String>[];
        while (i < lines.length && isBullet(lines[i].trim())) {
          items.add(lines[i].trim().substring(2));
          i++;
        }
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, right: AppSpacing.md),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                            ),
                          ),
                          Expanded(child: _richText(item, body)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ));
      } else if (isOrdered(trimmed)) {
        final items = <String>[];
        while (i < lines.length && isOrdered(lines[i].trim())) {
          items.add(lines[i].trim().replaceFirst(RegExp(r'^\d+\.\s'), ''));
          i++;
        }
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var idx = 0; idx < items.length; idx++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text('${idx + 1}.', style: body.copyWith(fontWeight: FontWeight.w700, color: accent)),
                      ),
                      Expanded(child: _richText(items[idx], body)),
                    ],
                  ),
                ),
            ],
          ),
        ));
      } else {
        final paraLines = <String>[];
        while (i < lines.length && !isBlockStart(lines[i].trim())) {
          paraLines.add(lines[i].trim());
          i++;
        }
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _richText(paraLines.join(' '), body),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }

  Widget _richText(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    var last = 0;
    for (final match in boldPattern.allMatches(text)) {
      if (match.start > last) spans.add(TextSpan(text: text.substring(last, match.start)));
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    final richText = TextSpan(style: style, children: spans);
    return selectable ? SelectableText.rich(richText) : Text.rich(richText);
  }
}
