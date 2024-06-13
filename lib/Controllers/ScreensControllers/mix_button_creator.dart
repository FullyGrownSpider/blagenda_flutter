import 'package:flutter/material.dart';

import '../blagenda_uniform_button.dart';

mixin ButtonCreator {
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
}