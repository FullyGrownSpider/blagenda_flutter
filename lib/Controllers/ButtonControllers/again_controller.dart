import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

import '../../Commons/Models/Buttons/skippable_button.dart';
import 'end_based_controller.dart';

class AgainYearController extends SkippableEndBasedController<AgainYearDay> {
  AgainYearController(AgainYearDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainYearController(button);

  int get month => button.month!;

  @override
  void create() {
    var nowDate = MyDateController.nowDate;
    if (nowDate.isDayThisYear(month, day)) {
      dateController = MyDateController.fromDM(month, day);
    } else {
      dateController = MyDateController.fromDMY(
          MyDateController.nowDate.year + 1, month, day);
    }
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button = AgainYearDay(job, toDos, id, color, day, month, null);
    }
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    if (calculatedDay == daysLeft) {
      return true;
    }
    var counter = 1;
    var newLeft = MyDateController(dateController.year + counter,
            dateController.month, dateController.day)
        .timeLeftUntil();
    while (newLeft < calculatedDay) {
      counter++;
      newLeft = MyDateController(dateController.year + counter,
              dateController.month, dateController.day)
          .timeLeftUntil();
    }
    return newLeft == calculatedDay;
  }
}

class AgainWeekController extends SkippableEndBasedController<AgainWeekDay> {
  AgainWeekController(AgainWeekDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainWeekController(button);

  @override
  void create() {
    var nowDate = MyDateController.nowDate;
    int weekdaysForCalc = day;
    if (nowDate.weekday > weekdaysForCalc) {
      weekdaysForCalc += 7;
    }
    dateController =
        nowDate.add(Duration(days: weekdaysForCalc - nowDate.weekday));
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button = AgainWeekDay(job, toDos, id, color, day, null);
    }
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) =>
      (calculatedDay - daysLeft) % 7 == 0;
}

class AgainAmountController
    extends SkippableEndBasedController<AgainAmountDay> {
  AgainAmountController(AgainAmountDay button) : super(button);

  MyDateController get date => button.date!;

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainAmountController(button);

  @override
  void create() {
    dateController = button.date!;
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button = AgainAmountDay(job, toDos, id, color, dateController, day, null);
    }
    var date = button.date!.add(const Duration(hours: 2));
    var toAdd = 0;
    while (date.isBefore(MyDateController.yesterday)) {
      date.addOrRemoveDays(day);
      toAdd += day;
    }
    if (toAdd == 0) return;
    dateController = dateController.addOrRemoveDays(toAdd);
    requiresChange = true;
    button = AgainAmountDay(
        job, toDos, id, color, dateController, day, button.dateToSkip);
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    return (calculatedDay >= daysLeft && (calculatedDay - daysLeft) % day == 0);
  }
}

class AgainMonthController extends SkippableEndBasedController<AgainMonthDay> {
  AgainMonthController(AgainMonthDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainMonthController(button);

  @override
  void create() {
    var nowDate = MyDateController.nowDate;
    var newLeft = MyDateController(nowDate.year, nowDate.month, day);
    if (newLeft.day < nowDate.day) {
      newLeft = MyDateController(nowDate.year, nowDate.month + 1, day);
    }
    dateController = newLeft;
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button = AgainMonthDay(job, toDos, id, color, day, null);
    }
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    if (calculatedDay == daysLeft) {
      return true;
    }
    var counter = 1;
    var date = MyDateController(dateController.year,
        dateController.month + counter, dateController.day);
    var newLeft = date.timeLeftUntil();
    while (newLeft < calculatedDay) {
      counter++;
      date = MyDateController(dateController.year,
          dateController.month + counter, dateController.day);
      newLeft = date.timeLeftUntil();
    }
    return newLeft == calculatedDay;
  }
}

bool buttonCheck(DateTime? dateToSkip, DateTime today) {
  if (dateToSkip == null) {
    return false;
  }
  return dateToSkip.isBefore(today);
}
