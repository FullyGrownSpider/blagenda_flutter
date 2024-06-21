import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import '../../../Commons/Models/Buttons/skippable_button.dart';
import 'end_based_controller.dart';

class AgainYearController extends SkippableEndBasedController<AgainYearDay> {
  AgainYearController(super.button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainYearController(button);

  int get month => button.month!;

  @override
  void create() {
    dateController = MyDateController.fromDM(month, day);
  }

  @override
  bool isLastTime() => false;

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    if (daysLeft == calculatedDay) return true;
    var calcDay = MyDateController.fromDaysFromNow(calculatedDay);
    return dateController.month == calcDay.month && dateController.day == calcDay.day;
  }

  @override
  MyDateController getNextTime(MyDateController? thisTimeDate) {
    return MyDateController(thisTimeDate!.year + 1, thisTimeDate.month, thisTimeDate.day);
  }

  @override
  void addOrRemoveDaysDo(int amount) {
    var newDate = dateController.addOrRemoveDays(amount);
    button.day = newDate.day;
    button.month = newDate.month;
  }
}

class AgainWeekController extends SkippableEndBasedController<AgainWeekDay> {
  AgainWeekController(super.button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainWeekController(button);

  @override
  bool isLastTime() =>
      endingDate != null && endingDate!.isBefore(dateController.addOrRemoveDays(7));

  @override
  void create() {
    dateController =
        MyDateController.today.add(Duration(days: day - MyDateController.today.weekday));
    if (startDate != null) {
      while (dateController.isBefore(startDate!)) {
        dateController = dateController.add(const Duration(days: 7));
      }
    }
  }

  @override
  MyDateController getNextTime(MyDateController? thisTimeDate) {
    return thisTimeDate!.addOrRemoveDays(7);
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    return (super.isHappeningOnDayFromNow(calculatedDay)) &&
        (calculatedDay - altLeft) % 7 == 0;
  }

  @override
  void addOrRemoveDaysDo(int amount) => button.day = (day + amount) % 7;
}

class AgainAmountController extends SkippableEndBasedController<AgainAmountDay> {
  AgainAmountController(super.button);

  /// internally uses start date because it already uses it the way it has to
  /// . didn't want to have values 2 times
  MyDateController get date => button.startDate!;

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainAmountController(button);

  @override
  bool isLastTime() =>
      endingDate != null && endingDate!.isBefore(dateController.add(Duration(days: day)));

  @override
  void create() {
    while (startDate!.isBefore(MyDateController.yesterday.addOrRemoveDays(-1))) {
      button.startDate = button.startDate!.addOrRemoveDays(day);
      requiresChange = true;
    }
    dateController = button.startDate!;
  }

  @override
  MyDateController getNextTime(MyDateController? thisTimeDate) {
    requiresChange = true;
    return thisTimeDate!.addOrRemoveDays(day);
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    return (endingDate == null || endingDate!.daysLeftUntil() >= calculatedDay) &&
        (daysLeft - calculatedDay) % day == 0;
  }

  @override
  void addOrRemoveDaysDo(int amount) =>
      button.startDate = startDate!.addOrRemoveDays(amount);
}

class AgainMonthController extends SkippableEndBasedController<AgainMonthDay> {
  AgainMonthController(super.button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainMonthController(button);

  @override
  bool isLastTime() =>
      endingDate != null &&
      endingDate!
          .isBefore(MyDateController(dateController.year, dateController.month + 1, day));

  @override
  void create() {
    if (startDate != null) {
      dateController = MyDateController(startDate!.year, startDate!.month, day);
      if (dateController.isBefore(startDate!)) {
        dateController = MyDateController(startDate!.year, startDate!.month + 1, day);
      }
    } else {
      dateController = MyDateController(
          MyDateController.today.year, MyDateController.today.month, day);
    }

    if (dateController.day != day && !job.contains('+')) {
      //if this month does not have 31 days get the last one
      int daysInMonth = DateTimeRange(
              start: MyDateController(
                  MyDateController.today.year, MyDateController.today.month),
              end: MyDateController(
                  MyDateController.today.year, MyDateController.today.month + 1))
          .duration
          .inDays;
      dateController = MyDateController(
          MyDateController.today.year, MyDateController.today.month, daysInMonth);
    }
  }

  @override
  MyDateController getNextTime(MyDateController? thisTimeDate) {
    return MyDateController(thisTimeDate!.year, thisTimeDate.month + 1, thisTimeDate.day);
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    var can = super.isHappeningOnDayFromNow(calculatedDay);
    if (!can) return false;
    var calcDay = MyDateController.fromDaysFromNow(calculatedDay);
    return calcDay.day == day;
  }

  @override
  void addOrRemoveDaysDo(int amount) => button.day = ((day + amount - 1) % 31) + 1;
}
