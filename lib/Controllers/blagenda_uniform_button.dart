import 'dart:math';

import 'package:flutter/material.dart';

const TextStyle bigTextStyle = TextStyle(
    fontSize: 22.0, height: 1.7, fontWeight: FontWeight.bold, color: Colors.greenAccent);
const TextStyle bigTextStyleYesterday = TextStyle(
    fontSize: 22.0, height: 1.7, fontWeight: FontWeight.bold, color: Colors.white30);
const TextStyle secondaryBigTextStyle = TextStyle(
    fontSize: 18.0, height: 1.7, fontWeight: FontWeight.bold, color: Colors.greenAccent);
const TextStyle normalTextStyle = TextStyle(
    fontSize: 14.0, height: 1.1, fontWeight: FontWeight.bold, color: Colors.black);
const TextStyle normalTextStyleBold = TextStyle(
    fontSize: 14.0, height: 1.1, fontWeight: FontWeight.w900, color: Colors.black);
const TextStyle smallStyle = TextStyle(fontSize: 2.0, color: Colors.green);

const TextStyle extraDayButton = TextStyle(
    fontSize: 8.0, height: 1.1, fontWeight: FontWeight.w900, color: Colors.black);

const Text splitterTextField =
    Text('    ', style: TextStyle(fontSize: 8.0, color: Colors.green));

const Text bigSplitterTextField = Text('≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡',
    style: TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green));

const Text smallBlankSplit = Text('            ', style: smallStyle);
const Text medBlankSplit = Text('\n\n\n\n            ', style: smallStyle);

class BlagendaUniformButton extends StatefulWidget {
  // A standard playing card is 57.1mm x 88.9mm.

  static const String smollButStartText = '••';

  const BlagendaUniformButton(this.isSelected, this.color, this.text, this.pressed,
      {super.key});

  final String text;
  final bool isSelected;
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
    var text = widget.text.trim();
    if (text.endsWith(BlagendaUniformButton.smollButStartText)) {
      text =
          '${text.replaceAll('\n', '').replaceFirst(BlagendaUniformButton.smollButStartText, '').substring(0, min(4, text.length - BlagendaUniformButton.smollButStartText.length))}..';
      ElevatedButton(
          onPressed: pressed,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(left: 13, right: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: widget.color),
          child: Text(text, style: normalTextStyle, textAlign: TextAlign.center));
    }
    return ElevatedButton(
        onPressed: pressed,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: 13, right: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(text.contains('\n\n') ? 30 : 10)),
            backgroundColor: widget.isSelected
                ? _getSelectedVersionOfColor(widget.color)
                : widget.color),
        child: text.contains('\n\n')
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
            : Text(text, style: normalTextStyle, textAlign: TextAlign.center));
  }

  void pressed() {
    widget.pressed();
    setState(() {});
  }
}
