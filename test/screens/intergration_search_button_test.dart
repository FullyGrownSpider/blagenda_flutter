import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/weird_again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/mix_search_able.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_input_handler.dart.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

import 'default_buttons.dart';
import 'overview4test.dart';

///test both searching and the adding_screen
void main() {
  test('searching button testing', _searchButtons);
  test('searching button weekday testing', _searchButtonsWeekday);
}

void _searchButtons() {
  var testList = <BasicButtonController>[
    _dead(1),
    _dead(2),
    _dead(11),
    _amount(1),
    _weird(0),
    _month(1),
    _week(12),
    _year(1)
  ];
  SearchScreenController searcher =
      SearchScreenController((_) async {}, testList, (_) {});
  setSearches(searcher, testList, 'job', const DateRange(-1, -1, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length);

  setSearches(searcher, testList, 'job', const DateRange(0, 100, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length);

  setSearches(searcher, testList, '', const DateRange(0, 100, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length);

  setSearches(searcher, testList, '', const DateRange(-1, -1, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 0);

  setSearches(
      searcher, testList, 'FAIL', const DateRange(0, 100, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 0);

  setSearches(searcher, testList, 'job', const DateRange(0, 0, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length == 5 || searcher.foundItems.length == 4, true);

  setSearches(searcher, testList, '1', const DateRange(-1, -1, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 6);

  setSearches(searcher, testList, '11', const DateRange(-1, -1, []), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 1);
}

void _searchButtonsWeekday() {
  var testList = <BasicButtonController>[
    _dead(1),
    _dead(2),
    _dead(11),
    make(Deadline('14', '', 12, usedColors.first, MyDateController.today.addOrRemoveDays(14))),
    make(Deadline('2', '', 13, usedColors.first, MyDateController.today.addOrRemoveDays(2))),
    _year(114)
  ];
  SearchScreenController searcher =
      SearchScreenController((_) async {}, testList, (_) {});
  setSearches(
      searcher,
      testList,
      '',
      DateRange(0, 0, [
        MyDateController.today.weekday,
        (MyDateController.today.weekday + 1) % 7
      ]),
      ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length - 2);

  setSearches(
      searcher,
      testList,
      '',
      DateRange(0, 10, [
        MyDateController.today.weekday,
        (MyDateController.today.weekday + 1) % 7
      ]),
      ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length - 1);

  setSearches(
      searcher,
      testList,
      'job',
      DateRange(0, 10, [
        MyDateController.today.weekday,
        (MyDateController.today.weekday + 1) % 7
      ]),
      ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length - 2);
}

setSearches(SearchScreenController searcher, List<SearchAble> testList,
    String s, DateRange r, List<String> tag) {
  Set searchesSet = {};
  for (var e in testList) {
    searchesSet.addAll(e.possibleSearches());
  }
  for (var key in searchesSet) {
    if (searcher.searches[key] == null) continue;
    if (key == SearchTypes.date) {
      searcher.searches[key]!.getValue = () => r;
    } else if (key == SearchTypes.string) {
      searcher.searches[key]!.getValue = () => s;
    } else if (key == SearchTypes.tag) {
      searcher.searches[key]!.getValue = () => tag;
    }
  }
}

AddingScreenController makeController(BasicButton but) {
  final FakeEntityNotifier entityNotifier = FakeEntityNotifier();
  final FakeButtonNotifier notifier = FakeButtonNotifier(entityNotifier);
  return AddingScreenController(but, notifier, true);
}

void goToNote(AddingScreenController controller) {
  controller.buttonType.value = BasicButton;
  controller.switchButtonType(controller.buttonType.value);
}

DeadlineController _dead(int numb) => DeadlineController(Deadline("job$numb",
    "asfd\nasdf\nhaha\n", numb, usedColors.first, MyDateController.today));

AgainWeirdController _weird(int numb) => AgainWeirdController(AgainWeird(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    15,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

AgainYearController _year(int numb) => AgainYearController(AgainYearDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    MyDateController.today.day,
    MyDateController.today.month));

AgainWeekController _week(int numb) => AgainWeekController(AgainWeekDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    3,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

AgainAmountController _amount(int numb) => AgainAmountController(AgainAmountDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    MyDateController.today.addOrRemoveDays(20),
    15,
    null,
    MyDateController.today.addOrRemoveDays(10)));

AgainMonthController _month(int numb) => AgainMonthController(AgainMonthDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    15,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));
