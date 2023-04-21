import 'package:flutter/material.dart';
import 'package:twitter_clone/theme/theme.dart';

class HashtagText extends StatelessWidget {
  final String text;
  const HashtagText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textspans = [];
    double fontSize = 18;

    text.split(' ').forEach(
      (element) {
        if (element.startsWith('#')) {
          textspans.add(
            TextSpan(
              text: '$element ',
              style: TextStyle(
                color: Pallete.limeColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (element.startsWith('www') ||
            element.startsWith('https://')) {
          textspans.add(
            TextSpan(
              text: '$element ',
              style: TextStyle(
                color: Pallete.limeColor,
                fontSize: fontSize,
              ),
            ),
          );
        } else {
          textspans.add(
            TextSpan(
              text: '$element ',
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          );
        }
      },
    );
    return RichText(
      text: TextSpan(
        children: textspans,
      ),
    );
  }
}
