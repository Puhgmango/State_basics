import 'package:flutter/material.dart';

/// Thẻ hiển thị ghi chú giải thích trên màn hình demo.
class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.lines, super.key});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final String line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $line', style: textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }
}
