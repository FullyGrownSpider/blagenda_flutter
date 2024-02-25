import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deadline', deadline);
  test('basic', basic);
}

void basic() {
  var x = BasicButtonController.splitByLength(
      'A VERY VERY VERY LONG STRING OMG IT IS SO BIG HOW DID IT GET THIS BIG LIKE WHAAAAT',
      20);
  var x1 = BasicButtonController.splitByLength(
      'AVERYVERYVERYLONGSTRINGOMGITISSOBIGHOWDIDITGETTHISBIGLIKEWHAAAAT', 20);
  var x2 = BasicButtonController.splitByLength(
      'AVERYVERYVERLONGSTRINGOMG IT IS SO BIG HOW DID IT GETTHISBIGLIKEWHAAAAT', 20);
  var x3 = BasicButtonController.splitByLength(
      'AVERYVERYVERLONGSTRINGOMG IT IS SO BIG\n HOW DID IT GETTHISBIGLIKEWHAAAAT', 20);

  expect(x.split('\n').length, 5);
  expect(x1.split('\n').length, 4);
  expect(x2.split('\n').length, 5);
  expect(x3.split('\n').length, 5);
}

void deadline() {
  var one = make(
      Deadline('normal', '', 1, usedColors.first, MyDateController(2023, 12, 27), false));
  var two = make(Deadline(
      'normal', '13pm', 1, usedColors.first, MyDateController(2023, 12, 27), false));
  two.rebuild();
  check(one, 'normal', 'normal\n\n🦏');
  check(two, '13:00 - normal', '13:00 - normal\n\n🦏');

  var oneText = make(Deadline('normal', 'hello sir\n', 1, usedColors.first,
      MyDateController(2023, 12, 27), false));
  var twoText = make(Deadline('normal', 'hello sir\n13pm', 1, usedColors.first,
      MyDateController(2023, 12, 27), false));
  check(oneText, 'normal', 'normal\n\nhello sir');
  check(twoText, '13:00 - normal', '13:00 - normal\n\nhello sir');

  var oneLong = make(Deadline('long 789-11-14-17-20-23-26-29-31-34-37-40', '', 1,
      usedColors.first, MyDateController(2023, 12, 27), false));
  var twoLong = make(Deadline('long 789-11-14-17-20-23-26-29-31-34-37-40', '13pm', 1,
      usedColors.first, MyDateController(2023, 12, 27), false));
  check(oneLong, 'long 789-11-14-17-20-23-26-29-31-34-37...',
      'long 789-11-14-17-20-23-26-29-31-34-37...\n\n🎨');
  check(twoLong, '13:00 - long 789-11-14-17-20-23-26-29-...',
      '13:00 - long 789-11-14-17-20-23-26-29-...\n\n🎨');

  var oneTextLong = make(Deadline('long 789-11-14-17-20-23-26-29-31-34-37-40',
      'hello sir\n', 1, usedColors.first, MyDateController(2023, 12, 27), false));
  var twoTextLong = make(Deadline('long 789-11-14-17-20-23-26-29-31-34-37-40',
      'hello sir\n13pm', 1, usedColors.first, MyDateController(2023, 12, 27), false));
  check(oneTextLong, 'long 789-11-14-17-20-23-26-29-31-34-37...',
      'long 789-11-14-17-20-23-26-29-31-34-37...\n\nhello sir');
  check(twoTextLong, '13:00 - long 789-11-14-17-20-23-26-29-...',
      '13:00 - long 789-11-14-17-20-23-26-29-...\n\nhello sir');
}

EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}

void check(EndBasedController it, String short, String selected) {
  expect(it.gettingTheStringShort(), short);
  expect(it.gettingTheStringSelected(), selected);
}
