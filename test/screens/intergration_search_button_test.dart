import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/weird_again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/mix_search_able.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_input_handler.dart.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

import 'overview4test.dart';

///test both searching and the adding_screen
void main() {
  test('searching button testing', _searchButtons);
}

void _searchButtons() {
  var testList = <BasicButtonController>[
    dead(1),
    dead(2),
    dead(11),
    amount(1),
    weird(0),
    month(1),
    week(12),
    year(1)
  ];
  SearchScreenController searcher =
      SearchScreenController((_) async {}, testList, (_) {});
  setSearches(searcher, testList, 'job', const DateRange(-1, -1), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length);

  setSearches(searcher, testList, 'job', const DateRange(0, 100), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length);

  setSearches(searcher, testList, '', const DateRange(0, 100), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, testList.length);

  setSearches(searcher, testList, '', const DateRange(-1, -1), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 0);

  setSearches(searcher, testList, 'FAIL', const DateRange(0, 100), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 0);

  setSearches(searcher, testList, 'job', const DateRange(0, 0), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 4);

  setSearches(searcher, testList, '1', const DateRange(-1, -1), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 6);

  setSearches(searcher, testList, '11', const DateRange(-1, -1), ['', '']);
  searcher.resetSearch();
  expect(searcher.foundItems.length, 1);
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

NoteController note(int numb) => NoteController(
    BasicButton("job$numb", "asfd\nasdf\nhaha\n", numb, usedColors.first));

DeadlineController dead(int numb) => DeadlineController(Deadline("job$numb",
    "asfd\nasdf\nhaha\n", numb, usedColors.first, MyDateController.today));

AgainWeirdController weird(int numb) => AgainWeirdController(AgainWeird(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    15,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

AgainYearController year(int numb) => AgainYearController(AgainYearDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    MyDateController.today.day,
    MyDateController.today.month));

AgainWeekController week(int numb) => AgainWeekController(AgainWeekDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    3,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

AgainAmountController amount(int numb) => AgainAmountController(AgainAmountDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    MyDateController.today.addOrRemoveDays(20),
    15,
    null,
    MyDateController.today.addOrRemoveDays(10)));

AgainMonthController month(int numb) => AgainMonthController(AgainMonthDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    15,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));
