import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter/material.dart';

Deadline deadline() {
  return Deadline('123', 'text!', 1, Colors.black,
      MyDateController.nowDate.addOrRemoveDays(1));
}

AgainWeekDay week() {
  return AgainWeekDay(
      '123',
      'text!',
      1,
      Colors.black,
      MyDateController.nowDate.weekday,
      MyDateController.nowDate.addOrRemoveDays(20),
      MyDateController.nowDate.addOrRemoveDays(40),
      null, {
    MyDateController.nowDate.addOrRemoveDays(20): [0]
  });
}

AgainYearDay year() {
  return AgainYearDay(
      '123',
      'text!',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(12).day,
      MyDateController.nowDate.addOrRemoveDays(12).month,
      MyDateController.nowDate.addOrRemoveDays(20),
      MyDateController.nowDate.addOrRemoveDays(40),
      null, {
    MyDateController.nowDate.addOrRemoveDays(20): [0]
  });
}

AgainMonthDay month() {
  return AgainMonthDay(
      '123',
      'text!',
      1,
      Colors.black,
      23,
      MyDateController.nowDate.addOrRemoveDays(20),
      MyDateController.nowDate.addOrRemoveDays(40),
      null, {
    MyDateController.nowDate.addOrRemoveDays(20): [0]
  });
}

AgainWeird weird() {
  return AgainWeird(
      '123',
      'text!',
      1,
      Colors.black,
      1,
      MyDateController.nowDate.addOrRemoveDays(20),
      MyDateController.nowDate.addOrRemoveDays(40),
      null, {
    MyDateController.nowDate.addOrRemoveDays(20): [0]
  });
}

AgainAmountDay day() {
  return AgainAmountDay(
      '123',
      'text!',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(10),
      11,
      MyDateController.nowDate.addOrRemoveDays(20),
      MyDateController.nowDate.addOrRemoveDays(40), {
    MyDateController.nowDate.addOrRemoveDays(20): [0]
  });
}

BasicButton note() {
  return BasicButton('123', 'text!', 1, Colors.black);
}

///test version of 'turn x into a controller'
EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}
