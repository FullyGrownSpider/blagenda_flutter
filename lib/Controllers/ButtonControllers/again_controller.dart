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
    startedChecking(() {
      int dif = startDate!.year;
      dateController = MyDateController.fromDMY(dif, month, day);
    });
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button.dateToSkip = null;
    }
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    var can = super.isHappeningOnDayFromNow(calculatedDay);
    if (!can) return false;
    var counter = 1;
    var newLeft = MyDateController(dateController.year + counter,
            dateController.month, dateController.day)
        .daysLeftUntil();
    while (newLeft < calculatedDay) {
      counter++;
      newLeft = MyDateController(dateController.year + counter,
              dateController.month, dateController.day)
          .daysLeftUntil();
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
    var nowDate = MyDateController.today;
    int weekdaysForCalc = day;
    if (nowDate.weekday > weekdaysForCalc) {
      weekdaysForCalc += 7;
    }
    dateController =
        nowDate.add(Duration(days: weekdaysForCalc - nowDate.weekday));
    startedChecking(() {
      // because we need to go TO the day its -7
      dateController = startDate!.add(Duration(days: weekdaysForCalc - 7 - startDate!.weekday));
    });
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button.dateToSkip = null;
    }
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    return (super.isHappeningOnDayFromNow(calculatedDay)) &&
        (calculatedDay - altLeft) % 7 == 0;
  }
}

class AgainAmountController
    extends SkippableEndBasedController<AgainAmountDay> {
  AgainAmountController(AgainAmountDay button) : super(button);

  /// internally uses start date because it already uses it the way it has to
  /// . didn't want to have values 2 times
  MyDateController get date => button.startDate!;

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainAmountController(button);

  @override
  void create() {
    dateController = button.startDate!;
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button.dateToSkip = null;
    }
    var date = button.startDate!.add(const Duration(hours: 2));
    var toAdd = 0;
    while (date.isBefore(MyDateController.yesterday)) {
      date.addOrRemoveDays(day);
      toAdd += day;
    }
    if (toAdd == 0) return;
    dateController = dateController.addOrRemoveDays(toAdd);
    requiresChange = true;
    button.startDate = dateController;
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    return super.isHappeningOnDayFromNow(calculatedDay) &&
        (calculatedDay >= daysLeft && (calculatedDay - daysLeft) % day == 0);
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
    startedChecking(() {
      newLeft = MyDateController(nowDate.year, startDate!.month, day);
    });
    if (buttonCheck(dateToSkip, dateController)) {
      requiresChange = true;
      button.dateToSkip = null;
    }
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    var can = super.isHappeningOnDayFromNow(calculatedDay);
    if (!can) return false;
    var counter = 1;
    var date = MyDateController(dateController.year,
        dateController.month + counter, dateController.day);
    var newLeft = date.daysLeftUntil();
    while (newLeft < calculatedDay) {
      counter++;
      date = MyDateController(dateController.year,
          dateController.month + counter, dateController.day);
      newLeft = date.daysLeftUntil();
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
