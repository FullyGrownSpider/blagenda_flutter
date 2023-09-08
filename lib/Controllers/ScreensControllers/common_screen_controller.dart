import 'package:flutter/material.dart';

Color getSelectedVersionOfColor(Color color) {
  return Color.lerp(color, Colors.white, 0.6) as Color;
}

const List<Color> usedColors = [
  Colors.green,
  Colors.amber,
  Colors.red,
  Colors.blue,
  Colors.purple,
  Colors.grey,
  Colors.brown,
  Colors.tealAccent,
  Colors.deepOrangeAccent
];
const TextStyle bigTextStyle = TextStyle(
    fontSize: 22.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent);
const TextStyle secondaryBigTextStyle = TextStyle(
    fontSize: 18.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent);
const TextStyle bigTextStyleYesterday = TextStyle(
    fontSize: 22.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.white30);
const TextStyle normalTextStyle = TextStyle(
    fontSize: 14.0,
    height: 1.4,
    fontWeight: FontWeight.bold,
    color: Colors.black);
const TextStyle normalTextStyleBold = TextStyle(
    fontSize: 14.0,
    height: 1.4,
    fontWeight: FontWeight.w900,
    color: Colors.black);
const TextStyle smallStyle = TextStyle(fontSize: 4.0, color: Colors.green);

const Text splitterTextField = Text('              ',
    style: TextStyle(fontSize: 8.0, color: Colors.green));
const Text bigSplitterTextField = Text('≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡',
    style: TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green));

const Text smallBlankSplit = Text('            ', style: smallStyle);
const Text smallerBlankSplit =
    Text(' ', style: TextStyle(fontSize: 2.0, color: Colors.green));

///the default look of the buttons
Widget blagendaUniformButton(
        bool b, Color c, String s, void Function() pressed) =>
    ElevatedButton(
        onPressed: pressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: b ? getSelectedVersionOfColor(c) : c),
        child: s.contains('\n')
            ? Column(children: [
                Text(s.substring(0, s.indexOf('\n')),
                    style: normalTextStyleBold, textAlign: TextAlign.center),
                smallBlankSplit,
                smallBlankSplit,
                Text(s.substring(s.indexOf('\n') + 1),
                    style: normalTextStyle, textAlign: TextAlign.center),
                const Text(
                  '-\n\n-',
                  style: smallStyle,
                )
              ])
            : Text(s, style: normalTextStyle, textAlign: TextAlign.center));

Widget _createColorButton(int index, void Function() setStateMethod,
        void Function(int) onPressed, int chosenIndex) =>
    blagendaUniformButton(chosenIndex == index, usedColors[index], '', () {
      onPressed(index);
      setStateMethod();
    });

List<Widget> globalCreateColorButtons(void Function() setStateMethod,
    void Function(int) onPressed, int chosenIndex) {
  return addAsRow(
      (i) => _createColorButton(i, setStateMethod, onPressed, chosenIndex),
      usedColors.length);
}

List<Row> addAsRow(Widget Function(int index) addWidget, int size,
    [int Function(int)? getLength, int rowLength = 3]) {
  List<Widget> row = [];
  List<Row> items = [];
  int counter = 0;
  row.add(const Spacer());
  for (int i = 0; i < size; i++) {
    getLength == null ? counter++ : counter += getLength(i) + 1;
    if (counter > rowLength && row.length > 2) {
      //1 1 3 ex
      counter = getLength!(i) + 1;
      row.add(const Spacer());
      items.add(Row(children: row));
      row = [
        const Spacer(),
        addWidget(i),
        smallBlankSplit];
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
