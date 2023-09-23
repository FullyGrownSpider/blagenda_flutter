import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import 'basic_button.dart';

abstract class SkippableButton extends BasicButton {
  SkippableButton(
      [String? job,
      List<String>? toDos,
      int? id,
      Color? color,
      this.day,
      this.dateToSkip,
      this.endingDate,
      this.startDate,
      important])
      : super(job, toDos, id, color);

  int? day;
  MyDateController? dateToSkip;
  MyDateController? endingDate;
  MyDateController? startDate;
}
