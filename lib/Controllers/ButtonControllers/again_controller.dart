import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

import '../../Commons/Models/Buttons/skippable_button.dart';
import 'end_based_controller.dart';

class AgainYearController extends SkippableEndBasedController<AgainYearDay> {
  AgainYearController(AgainYearDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainYearController(button);

  @override
  void create() {
    var nowDate = MyDateController.nowDate;
    if (nowDate.isDayThisYear(button.month, day)) {
      dateController = MyDateController.fromDM(button.month, day);
    } else {
      dateController = MyDateController.fromDMY(
          MyDateController.nowDate.year + 1, button.month, day);
    }
    if (buttonCheck(dateToSkip, dateController)){
      requiresChange = true;
      button = AgainYearDay(job, toDos, id, color,
          day, button.month, null);
    }
  }

  @override
  bool isInLeft(int calculatedDay) {
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

  @override
  void newSkip(MyDateController dateController) => button = AgainYearDay(
      job,
      toDos,
      id,
      color,
      day,
      button.month,
      dateController);
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
    if (buttonCheck(dateToSkip, dateController)){
      requiresChange = true;
      button = AgainWeekDay(job, toDos, id, color,
          day, null);
    }
  }

  @override
  bool isInLeft(int calculatedDay) => (calculatedDay - daysLeft) % 7 == 0;

  @override
  void newSkip(MyDateController dateController) => button = AgainWeekDay(
      job,
      toDos,
      id,
      color,
      day,
      dateController);
}

class AgainAmountController
    extends SkippableEndBasedController<AgainAmountDay> {
  AgainAmountController(AgainAmountDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainAmountController(button);

  @override
  void create() {
    dateController = button.date;
    if (buttonCheck(dateToSkip, dateController)){
      requiresChange = true;
      button = AgainAmountDay(job, toDos, id, color,
          dateController, day, null);
    }
    var date = button.date.add(const Duration(hours: 2));
    var toAdd = 0;
    while (date.isBefore(MyDateController.yesterday)) {
      date.addOrRemoveDays(day);
      toAdd += day;
    }
    if (toAdd == 0) return;
    dateController = dateController.addOrRemoveDays(toAdd);
    requiresChange = true;
    button = AgainAmountDay(job, toDos, id, color,
        dateController, day, button.dateToSkip);
  }

  @override
  bool isInLeft(int calculatedDay) {
    return (calculatedDay >= daysLeft && (calculatedDay - daysLeft) % day == 0);
  }

  @override
  void newSkip(MyDateController dateController) {
    if (altLeft == daysLeft) {
      var date = button.date.addOrRemoveDays(day);
      button = AgainAmountDay(job, toDos, id, color,
          date, day, date);
    } else {
      button = AgainAmountDay(job, toDos, id, color,
          button.date, day, dateController);
    }
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
    if (buttonCheck(dateToSkip, dateController)){
      requiresChange = true;
      button = AgainMonthDay(job, toDos, id, color,
          day, null);
    }
  }

  @override
  bool isInLeft(int calculatedDay) {
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

  @override
  void newSkip(MyDateController dateController) => button = AgainMonthDay(
      job,
      toDos,
      id,
      color,
      day,
      dateController);
}

bool buttonCheck(DateTime? dateToSkip, DateTime today) {
  if (dateToSkip == null) {
    return false;
  }
  return dateToSkip.isBefore(today);
}
