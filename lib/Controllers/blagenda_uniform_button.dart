import 'dart:math';

import 'package:flutter/material.dart';

const TextStyle bigTextStyle = TextStyle(
    fontSize: 22.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent);
const TextStyle bigTextStyleYesterday = TextStyle(
    fontSize: 22.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.white30);
const TextStyle secondaryBigTextStyle = TextStyle(
    fontSize: 18.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent);
const TextStyle normalTextStyle = TextStyle(
    fontSize: 14.0,
    height: 1.1,
    fontWeight: FontWeight.bold,
    color: Colors.black);
const TextStyle normalTextStyleBold = TextStyle(
    fontSize: 14.0,
    height: 1.1,
    fontWeight: FontWeight.w900,
    color: Colors.black);
const TextStyle smallStyle = TextStyle(fontSize: 2.0, color: Colors.green);

const TextStyle extraDayButton = TextStyle(
    fontSize: 8.0,
    height: 1.1,
    fontWeight: FontWeight.w900,
    color: Colors.black);

const Text splitterTextField =
    Text('    ', style: TextStyle(fontSize: 8.0, color: Colors.green));

const Text bigSplitterTextField = Text('≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡',
    style: TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green));

const Text smallBlankSplit = Text('            ', style: smallStyle);
const Text medBlankSplit = Text('\n\n\n\n            ', style: smallStyle);

///will not set its own selected. If you want it to select make the onPress change the isSelected value
class BlagendaUniformButton extends StatefulWidget {
  // FWI: A standard playing card is 57.1mm x 88.9mm.
  // This is unrelated to the application.

  const BlagendaUniformButton(this.color, this.text, this.pressed,
      {this.isSmall = false, this.isSelected, super.key});

  final String Function() text;
  final ValueNotifier<bool>? isSelected;
  final bool isSmall;
  final Color color;
  final void Function() pressed;

  @override
  State<StatefulWidget> createState() => _BlagendaUniformButton();
}

class _BlagendaUniformButton extends State<BlagendaUniformButton> {
  //selected version of color
  Color _getSelectedVersionOfColor(Color color) {
    return Color.lerp(color, Colors.white, 0.6) as Color;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSmall) {
      var text = widget.text().trim().replaceAll('\n', '');
      //this means its a very small button and can not be selected
      text = '${text.substring(0, min(4, text.length))}..';
      ElevatedButton(
          onPressed: widget.pressed,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(left: 13, right: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: widget.color),
          child:
              Text(text, style: normalTextStyle, textAlign: TextAlign.center));
    }
    if (widget.isSelected != null) {
      return ValueListenableBuilder(
          valueListenable: widget.isSelected!,
          builder: (context, isSelected, child) {
            var text = widget.text().trim();
            return _theButt(isSelected, text.contains('\n\n'), text);
          });
    } else {
      var text = widget.text().trim();
      final isDoubleLined = text.contains('\n\n');
      return _theButt(false, isDoubleLined, text);
    }
  }

  Widget _theButt(bool isSelected, bool isDoubleLined, String text) =>
      ElevatedButton(
          onPressed: widget.pressed,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(left: 13, right: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDoubleLined ? 30 : 10)),
              backgroundColor: isSelected
                  ? _getSelectedVersionOfColor(widget.color)
                  : widget.color),
          child: isDoubleLined
              ? Column(children: [
                  smallBlankSplit,
                  Text(text.substring(0, text.indexOf('\n\n')),
                      style: normalTextStyleBold, textAlign: TextAlign.center),
                  medBlankSplit,
                  Text(text.substring(text.indexOf('\n\n') + 2),
                      style: normalTextStyle, textAlign: TextAlign.center),
                  const Text(
                    '-\n\n-',
                    style: smallStyle,
                  )
                ])
              : Text(text,
                  style: normalTextStyle, textAlign: TextAlign.center));
}
