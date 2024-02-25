import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import 'blagenda_uniform_button.dart';

mixin MonthDayWidget {
  static const TextStyle normalTextStyle =
      TextStyle(fontSize: 14, color: Color(0xFFFF0000));
  static const TextStyle normalTextStyleBold =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black);

  static const TextStyle smollTextStyleBold = TextStyle(fontSize: 8, color: Colors.black);

  Widget buildMonthDayWidgets(int year, int currentMonth) {
    List<List<Text>> rowData = [];
    for (int i = 0; i < 3; i++) {
      List<Text> list = [];
      for (int ii = 0; ii < 4; ii++) {
        int nMonth = 1 + ii + i * 4;
        var monthNow = MyDateController(year, nMonth);
        int daysInMonth =
            DateTimeRange(start: monthNow, end: MyDateController(year, nMonth + 1))
                .duration
                .inDays;
        list.add(Text(monthNow.stringMonthSmallDisplay(), style: smollTextStyleBold));
        list.add(Text(daysInMonth.toString(),
            style: currentMonth == nMonth ? normalTextStyle : normalTextStyleBold));
        list.add(smallBlankSplit);
      }
      rowData.add(list..removeLast());
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowData
            .map((e) =>
                Row(mainAxisAlignment: MainAxisAlignment.center, children: e) as Widget)
            .toList()
          ..add(smallBlankSplit));
  }
}
