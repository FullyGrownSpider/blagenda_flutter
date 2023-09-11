import 'dart:ui';

import 'package:blagenda_flutter_simple/Commons/Models/Buttons/skippable_button.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';


class AgainAmountDay extends SkippableButton {
  AgainAmountDay([String? job, List<String>? toDos, int? id, Color? color, this.date,
      int? day, MyDateController? dateToSkip])
      : super(job, toDos, id, color, day, dateToSkip);
  MyDateController? date;
}

class AgainWeekDay extends SkippableButton {
  AgainWeekDay([String? job, List<String>? toDos, int? id, Color? color, int? day,
      MyDateController? dateToSkip])
      : super(job, toDos, id, color, day, dateToSkip);
}

class AgainYearDay extends SkippableButton {
  AgainYearDay([String? job, List<String>? toDos, int? id, Color? color, int? day,
      this.month, MyDateController? dateToSkip])
      : super(job, toDos, id, color, day, dateToSkip);
  int? month;
}

class AgainMonthDay extends SkippableButton {
  AgainMonthDay([String? job, List<String>? toDos, int? id, Color? color, int? day,
      MyDateController? dateToSkip])
      : super(job, toDos, id, color, day, dateToSkip);
}
