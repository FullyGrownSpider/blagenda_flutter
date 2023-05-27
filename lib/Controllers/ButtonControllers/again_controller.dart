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
    if (button.month < nowDate.month ||
        button.month == nowDate.month && button.day < nowDate.day) {
      dateController = MyDateController.fromDMY(
          MyDateController.nowDate.year + 1, button.month, button.day);
    } else {
      dateController = MyDateController.fromDM(button.month, button.day);
    }
    buttonCheck(button, dateController);
    if (buttonCheck(button, dateController)) requiresChange = true;
  }

  @override
  bool isInLeft(int calculatedDay) {
    if (calculatedDay == left) {
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
      button.job, button.toDos, button.id, button.color, button.day, button.month, dateController);
}

class AgainWeekController extends SkippableEndBasedController<AgainWeekDay> {
  AgainWeekController(AgainWeekDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainWeekController(button);

  @override
  void create() {
    var nowDate = MyDateController.nowDate;
    int weekdaysForCalc = button.day;
    if (nowDate.weekday > weekdaysForCalc) weekdaysForCalc += 7;
    dateController =
        nowDate.add(Duration(days: weekdaysForCalc - nowDate.weekday));
    if (buttonCheck(button, dateController)) requiresChange = true;
  }

  @override
  bool isInLeft(int calculatedDay) => (calculatedDay - left) % 7 == 0;

  @override
  String gettingTheStringMed() {
    String calc;
    if (left == 0) {
      calc = "\nToday ";
    } else if (left == 1) {
      calc = "\nTomorrow ";
    } else {
      calc = '\nevery ' + dateController.dayDisplay();
    }
    return displayJob() + calc;
  }

  @override
  void newSkip(MyDateController dateController) => button =
      AgainWeekDay(button.job, button.toDos, button.id, button.color, button.day, dateController);
}

class AgainAmountController
    extends SkippableEndBasedController<AgainAmountDay> {
  AgainAmountController(AgainAmountDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainAmountController(button);

  @override
  void create() {
    var date = button.date.add(const Duration(hours: 4));
    if (date.isBefore(MyDateController.yesterday)) {
      dateController = date;
      while (dateController.isBefore(MyDateController.yesterday)) {
        dateController = dateController.addOrRemoveDays(button.day);
        requiresChange = true;
      }
      button = AgainAmountDay(button.job, button.toDos, button.id, button.color, dateController,
          button.day, dateController);
      if (buttonCheck(button, dateController)) requiresChange = true;
    } else {
      dateController = date;
    }
  }

  @override
  bool isInLeft(int calculatedDay) {
    return (calculatedDay >= left && (calculatedDay - left) % button.day == 0);
  }

  @override
  void newSkip(MyDateController dateController) => button = AgainAmountDay(
      button.job, button.toDos, button.id, button.color, button.date, button.day, dateController);
}

class AgainMonthController extends SkippableEndBasedController<AgainMonthDay> {
  AgainMonthController(AgainMonthDay button) : super(button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainMonthController(button);

  @override
  void create() {
    var nowDate = MyDateController.nowDate;
    var newLeft = MyDateController(nowDate.year, nowDate.month, button.day);
    if (newLeft.day < nowDate.day) {
      newLeft = MyDateController(nowDate.year, nowDate.month + 1, button.day);
    }
    dateController = newLeft;
    if (buttonCheck(button, dateController)) requiresChange = true;
  }

  @override
  bool isInLeft(int calculatedDay) {
    if (calculatedDay == left) {
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
  void newSkip(MyDateController dateController) => button =
      AgainMonthDay(button.job, button.toDos, button.id, button.color, button.day, dateController);
}

bool buttonCheck(SkippableButton button, DateTime today) {
  if (button.dateToSkip == null) {
    return false;
  }
  return button.dateToSkip!.isBefore(today);
}
