import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import 'basic_button.dart';

class Deadline extends BasicButton {
  const Deadline(job, toDos, id, Color color, this.date, this.calendar)
      : super(job, toDos, id, color);

  static Deadline fromButton(BasicButton but, MyDateController date, String calendar) =>
      Deadline(but.job, but.toDos, but.id, but.color, date, calendar);
  final MyDateController date;
  final String calendar;
}
