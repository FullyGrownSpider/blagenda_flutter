import 'package:blagenda_flutter_simple/Commons/Models/Buttons/skippable_button.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import 'basic_button.dart';

class AgainAmountDay extends SkippableButton {
  const AgainAmountDay(String job, List<String> toDos, int id, Color color, this.date,
      int day, MyDateController? dateToSkip)
      : super(job, toDos, id, color, day, dateToSkip);

  static AgainAmountDay fromButton(BasicButton but, MyDateController lastTimeDate,
          int daysAmount, MyDateController? dateToSkip) =>
      AgainAmountDay(but.job, but.toDos, but.id, but.color, lastTimeDate,
          daysAmount, dateToSkip);
  final MyDateController date;
}

class AgainWeekDay extends SkippableButton {
  const AgainWeekDay(String job, List<String> toDos, int id, Color color, int day,
      MyDateController? dateToSkip)
      : super(job, toDos, id, color, day, dateToSkip);

  static AgainWeekDay fromButton(
          BasicButton but, int day, MyDateController? dateToSkip) =>
      AgainWeekDay(but.job, but.toDos, but.id, but.color, day, dateToSkip);
}

class AgainYearDay extends SkippableButton {
  const AgainYearDay(String job, List<String> toDos, int id, Color color, int day,
      this.month, MyDateController? dateToSkip)
      : super(job, toDos, id, color, day, dateToSkip);

  static AgainYearDay fromButton(
          BasicButton but, int day, int month, MyDateController? dateToSkip) =>
      AgainYearDay(
          but.job, but.toDos, but.id, but.color, day, month, dateToSkip);
  final int month;
}

class AgainMonthDay extends SkippableButton {
  const AgainMonthDay(String job, List<String> toDos, int id, Color color, int day,
      MyDateController? dateToSkip)
      : super(job, toDos, id, color, day, dateToSkip);

  static AgainMonthDay fromButton(
          BasicButton but, int day, MyDateController? dateToSkip) =>
      AgainMonthDay(but.job, but.toDos, but.id, but.color, day, dateToSkip);
}