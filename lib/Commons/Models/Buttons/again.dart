import 'dart:ui';

import 'package:blagenda_flutter_simple/Commons/Models/Buttons/skippable_button.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

class AgainAmountDay extends SkippableButton {
  AgainAmountDay(
      [String? job,
      String? toDos,
      int? id,
      Color? color,
      MyDateController? startDate,
      int? day,
      MyDateController? dateToSkip,
      MyDateController? endingDate,
      bool important = false])
      : super(job, toDos, id, color, day, dateToSkip, endingDate, startDate, important);
}

class AgainWeekDay extends SkippableButton {
  AgainWeekDay(
      [super.job,
      super.toDos,
      super.id,
      super.color,
      super.day,
      super.dateToSkip,
      super.endingDate,
      super.startDate,
      super.important]);
}

class AgainYearDay extends SkippableButton {
  AgainYearDay(
      [super.job,
      super.toDos,
      super.id,
      super.color,
      super.day,
      this.month,
      super.dateToSkip,
      super.endingDate,
      super.startDate,
      super.important]);

  int? month;
}

class AgainMonthDay extends SkippableButton {
  AgainMonthDay(
      [super.job,
      super.toDos,
      super.id,
      super.color,
      super.day,
      super.dateToSkip,
      super.endingDate,
      super.startDate,
      super.important]);
}
