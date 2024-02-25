import 'package:flutter/material.dart';

import '../../common_items.dart';

mixin buttonCreator {
  //selected version of color
  Color _getSelectedVersionOfColor(Color color) {
    return Color.lerp(color, Colors.white, 0.6) as Color;
  }

  ///the default look of the buttons
//for easy searching defaultBlagendaButton ButtonBlagendaDefault defaultButton
  Widget blagendaUniformButton(
      bool isSelected, Color c, String text, void Function() pressed) {
    text = text.trim();
    return ElevatedButton(
        onPressed: pressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(text.contains('\n\n') ? 30 : 10)),
            backgroundColor: isSelected ? _getSelectedVersionOfColor(c) : c),
        child: text.contains('\n\n')
            ? Column(children: [
                Text(text.substring(0, text.indexOf('\n\n')),
                    style: normalTextStyleBold, textAlign: TextAlign.center),
                smallBlankSplit,
                smallBlankSplit,
                Text(text.substring(text.indexOf('\n\n') + 2),
                    style: normalTextStyle, textAlign: TextAlign.center),
                const Text(
                  '-\n\n-',
                  style: smallStyle,
                )
              ])
            : Text(text, style: normalTextStyle, textAlign: TextAlign.center));
  }

  Widget _createColorButton(int index, void Function() setStateMethod,
          void Function(int) onPressed, int chosenIndex) =>
      blagendaUniformButton(chosenIndex == index, usedColors[index], '', () {
        onPressed(index);
        setStateMethod();
      });

  List<Widget> globalCreateColorButtons(
      void Function() setStateMethod, void Function(int) onPressed, int chosenIndex) {
    return addAsRow((i) => _createColorButton(i, setStateMethod, onPressed, chosenIndex),
        usedColors.length);
  }

  List<Row> addAsRow(Widget Function(int index) addWidget, int size,
      [int Function(int)? getLength, int rowLength = 27]) {
    getLength ??= (_) => 0;
    List<Widget> row = [];
    List<Row> items = [];
    int counter = 0;
    row.add(const Spacer());
    for (int i = 0; i < size; i++) {
      counter += getLength(i) + 9;
      if (counter > rowLength && row.length > 2) {
        //1 1 3 ex
        counter = getLength(i) + 1;
        row.add(const Spacer());
        items.add(Row(children: row));
        row = [const Spacer(), addWidget(i), smallBlankSplit];
        continue;
      }
      row.add(addWidget(i));
      if (counter >= rowLength) {
        counter = 0;
        row.add(const Spacer());
        items.add(Row(children: row));
        row = [const Spacer()];
      } else {
        row.add(smallBlankSplit);
      }
    }
    if (row.isNotEmpty) {
      row.add(const Spacer());
      items.add(Row(children: row));
      row = [];
    }
    return items;
  }

  static const TextStyle bigTextStyle = TextStyle(
      fontSize: 22.0,
      height: 1.7,
      fontWeight: FontWeight.bold,
      color: Colors.greenAccent);
  static const TextStyle secondaryBigTextStyle = TextStyle(
      fontSize: 18.0,
      height: 1.7,
      fontWeight: FontWeight.bold,
      color: Colors.greenAccent);
  static const TextStyle bigTextStyleYesterday = TextStyle(
      fontSize: 22.0, height: 1.7, fontWeight: FontWeight.bold, color: Colors.white30);
  static const TextStyle normalTextStyle = TextStyle(
      fontSize: 14.0, height: 1.4, fontWeight: FontWeight.bold, color: Colors.black);
  static const TextStyle normalTextStyleBold = TextStyle(
      fontSize: 14.0, height: 1.4, fontWeight: FontWeight.w900, color: Colors.black);
  static const TextStyle smallStyle = TextStyle(fontSize: 4.0, color: Colors.green);

  static const Text splitterTextField =
      Text('              ', style: TextStyle(fontSize: 8.0, color: Colors.green));
  static const Text bigSplitterTextField = Text('≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡',
      style: TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green));

  static const Text smallBlankSplit = Text('            ', style: smallStyle);
  static const Text smallerBlankSplit =
      Text(' ', style: TextStyle(fontSize: 2.0, color: Colors.green));
}
