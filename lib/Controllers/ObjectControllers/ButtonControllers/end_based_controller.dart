import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:flutter/material.dart';

import '../../../Commons/Models/Buttons/skippable_button.dart';
import '../../my_date_controller.dart';
import '../mix_search_able.dart';
import 'basic_button_controller.dart';
import 'deadline_controller.dart';

abstract class EndBasedController<t extends BasicButton> extends BasicButtonController<t>
    implements Comparable<EndBasedController> {
  static final RegExp _completeReg = RegExp(
      r"(?:(?<full>[0-2]?[0-9][-,.:][0-6][0-9](?: ?[apAP][mM])?)|(?<hour>[0-2]?[0-9] ?[apAP][mM]))(?:([^0-9]{0,5}(?:(?<full2>[0-2]?[0-9][-,.:][0-6][0-9] ?([apAP][mM])?)|(?<hour2>[0-2]?[0-9] ?[apAP][mM]))\b)|\b)");
  static final RegExp _regFix = RegExp(r'[-,.:]');
  static final RegExp _regNum = RegExp(r'[^0-9-,.:]');
  static final RegExp _daysReg =
      RegExp(r"((?:lasts|duurt|D|d) ?\d+)|\d+ ?(?:days|l[oa]ng|dagen|d\b|D\b)");

  static const int showDayOfWeek = 6;
  static const int showDayTime = 4;
  bool requiresChange = false;
  int timeOfDay = -1;
  int timeOfDayEnd = -1;
  int daysLeft = -20;
  late MyDateController dateController;
  @visibleForTesting
  @protected
  int extraDays = 1;

  EndBasedController(super.button) {
    rebuild();
  }

  @override
  Color get color {
    if (daysLeft != -1) {
      return button.color!;
    }
    return lerpIt(button.color as Color);
  }

  void rebuild() {
    create();
    daysLeft = howMuchLeft();
    _setTimeOfDay();
    _setExtraDays();
  }

  void create();

  int howMuchLeft() => dateController.daysLeftUntil();

  bool isHappeningOnDayFromNow(int calculatedDay) => daysLeft == calculatedDay;

  void _setTimeOfDay() {
    var match = _completeReg.firstMatch(toDos);
    timeOfDay = _getTime(match, 'full', 'hour');
    timeOfDayEnd = _getTime(match, 'full2', 'hour2');
    if (timeOfDayEnd != -1 && timeOfDayEnd < timeOfDay) {
      var calc = timeOfDay;
      timeOfDay = timeOfDayEnd;
      timeOfDayEnd = calc;
    }
  }

  bool extraGoingOn(int currentDay) {
    if (extraDays == 1) return false;
    int fromNow = dateController.daysLeftUntil();
    return fromNow < currentDay && fromNow + extraDays >= currentDay;
  }

  void _setExtraDays() {
    var match = _daysReg.firstMatch(toDos);
    if (match != null) extraDays = int.parse(match[0]!.replaceAll(_regNum, ''));
  }

  int _getTime(RegExpMatch? match, String full, String hour) {
    var text = match?.namedGroup(full);
    text ??= match?.namedGroup(hour);
    if (text == null) return -1;
    var split = text.replaceAll(_regNum, '').split(_regFix);
    return _timeSet(
        int.parse(split.first) * 60 + (split.length > 1 ? int.parse(split.last) : 0),
        text);
  }

  int _timeSet(int result, String text) {
    if ((text.contains('p') && result < 721) || (!text.contains('a') && result < 420)) {
      result += 720;
    }
    if (result > 1440) return -1;
    return result;
  }

  @visibleForTesting
  String displayJob() =>
      (daysLeft < showDayTime ? _displayWithTimeJob() : super.gettingTheStringShort())
          .trim();

  String _displayWithTimeJob() {
    return (timeOfDay != -1
            ? '${timeOfDay ~/ 60}:${(timeOfDay % 60).toString().padLeft(2, '0')}${timeOfDayEnd != -1 ? '-${timeOfDayEnd ~/ 60}:${(timeOfDayEnd % 60).toString().padLeft(2, '0')} ~ ' : ' ~ '}'
            : '') +
        super.gettingTheStringShort();
  }

  String _gettingTheStringShortWithTime([bool overrideTime = false]) =>
      (entitied != -1 ? BasicButtonController.entityIndicator : '') +
      displayGenericText(overrideTime ? _displayWithTimeJob() : displayJob(),
          BasicButtonController.maxValueCheck);

  @override
  String gettingTheStringSelected() =>
      '${_gettingTheStringShortWithTime(true)}\n\n${todosToString()}'.trim();

  String gettingTheStringShortWithDate() =>
      '${dateController.stringFullDisplayWithCal()} - ${_gettingTheStringShortWithTime()}';

  @override
  String gettingTheStringShort() => _gettingTheStringShortWithTime();

  @override
  String todosToString() {
    var result = super.todosToString();
    if (timeOfDay != -1) {
      result = result.replaceFirst(_completeReg, '').replaceFirst('\n\n', '\n').trim();
      if (result.trim().isEmpty) result = writeEmpty();
    }
    return result;
  }

  @override
  int compareTo(EndBasedController b) {
    var thisLeft = this is SkippableEndBasedController
        ? (this as SkippableEndBasedController).altLeft
        : daysLeft;
    var bLeft = b is SkippableEndBasedController ? b.altLeft : b.daysLeft;
    if (thisLeft == bLeft) {
      //same time then i want deadlines first
      if (timeOfDay == b.timeOfDay) {
        var value = 0;
        if (this is DeadlineController) value--;
        if (b is DeadlineController) value++;
        return value;
      }
      //if either one doesn't have a time it needs to be at the bottom
      if (timeOfDay == -1) return 1;
      if (b.timeOfDay == -1) return -1;
      //and then things that come first at the top
      return timeOfDay.compareTo(b.timeOfDay);
    }
    return thisLeft.compareTo(bLeft);
  }

  @override
  int searchHere(SearchTypes searchType, dynamic value) {
    if (searchType == SearchTypes.string) {
      return (job.toLowerCase().contains(value) ? 9 : 0) +
          (toDos.toLowerCase().contains(value) ? 1 : 0);
    }
    if (searchType == SearchTypes.date) {
      for (int date = value.myDateFromNow;
          date <= value.myDateFromNow + value.range;
          date++) {
        if (isHappeningOnDayFromNow(date)) {
          return 10;
        }
      }
    }
    return 0;
  }

  @override
  List<SearchTypes> possibleSearches() {
    return [SearchTypes.string, SearchTypes.date];
  }

  @override
  String searchDisplay() =>
      '${dateController.stringFullDisplayWithCal(true)}\n--\n${gettingTheStringSelected()}';

  void addOrRemoveDays(int amount) {
    addOrRemoveDaysDo(amount);
    rebuild();
  }

  @protected
  void addOrRemoveDaysDo(int amount);
}

//----------------------------------

abstract class SkippableEndBasedController<t extends SkippableButton>
    extends EndBasedController<t> {
  SkippableEndBasedController(super.button);

  SkippableEndBasedController createNew(int fromNow) {
    var clone = callConstructor(button);
    clone.altLeft = fromNow;
    return clone;
  }

  @override
  String gettingTheStringShortWithDate() =>
      '${dateController.stringFullDisplayWithCal()} - ${_gettingTheStringShortWithTime()}\n(Repeats)';

  @override
  void rebuild() {
    var daysDif = daysLeft;
    create();
    _setTimeOfDay();
    _setExtraDays();
    dateController = dateController.add(const Duration(hours: 4));

    while (dateController.isBefore(MyDateController.today)) {
      dateController = getNextTime(dateController);
    }
    daysLeft = howMuchLeft();

    if (startDate != null &&
        startDate!.addOrRemoveDays(3).isBefore(MyDateController.today)) {
      requiresChange = true;
      button.startDate = null;
    }

    if (dateToSkip != null) {
      if (dateToSkip!.daysLeftUntil() == daysLeft) {
        dateController = getNextTime(dateController);
        daysLeft = howMuchLeft();
      } else if (buttonCheck(dateToSkip!, dateController)) {
        requiresChange = true;
        button.dateToSkip = null;
        altLeft += (daysLeft - daysDif);
        return;
      }
    }

    altLeft += (daysLeft - daysDif);
    if (wantDeleteMe()) {
      requiresChange = true;
    }
  }

  MyDateController getNextTime(MyDateController? thisTimeDate);

  bool wantDeleteMe() {
    return endingDate != null && endingDate!.isBefore(MyDateController.today);
  }

  @override
  String writeEmpty() => emogjiList[
      (job + MyDateController.fromDaysFromNow(altLeft).microsecondsSinceEpoch.toString())
              .hashCode %
          emogjiList.length];

  SkippableEndBasedController callConstructor(button);

  void makeNewSkip(MyDateController newSkip) {
    button.dateToSkip = newSkip;
  }

  MyDateController? get endingDate => button.endingDate;

  MyDateController? get startDate => button.startDate;

  late int altLeft = -20;

  bool inTheNextDays(int days) {
    for (int i = 0; i <= days; i++) {
      if (isHappeningOnDayFromNow(i)) return true;
    }
    return false;
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    return (dateToSkip == null || dateToSkip!.daysLeftUntil() != calculatedDay) &&
        (endingDate == null || endingDate!.daysLeftUntil() >= calculatedDay) &&
        (startDate == null || startDate!.daysLeftUntil() <= calculatedDay);
  }

  @override
  bool extraGoingOn(int currentDay) {
    if (extraDays == 1) return false;
    for (int i = 2; i <= extraDays; i++) {
      if (isHappeningOnDayFromNow(currentDay - i)) {
        return true;
      }
    }
    return false;
  }

  @override
  String displayJob() {
    var xtr = '';
    if (isLastTime()) {
      xtr = '⚈ ';
    }
    return xtr + super.displayJob();
  }

  //returns true if you should skip
  static bool skipCheck(SkippableButton button, DateTime date) =>
      MyDateController.aboutEqual(button.dateToSkip!, date);

  //check if you are checking the "today" is the copy's today too then check if the skipDate is the actually same date as the skipDate
  ///returns true if you should skip the copy
  bool skipCheckNotSure(int calc) =>
      button.dateToSkip != null &&
      calc == altLeft &&
      skipCheck(button, DateTime.now().add(Duration(days: calc)));

  @override
  Color get color {
    if (altLeft < 0) {
      return lerpIt(button.color as Color);
    }
    return button.color!;
  }

  int get day => button.day!;

  MyDateController? get dateToSkip => button.dateToSkip;

  bool isLastTime();

  static bool buttonCheck(DateTime dateToSkip, DateTime today) {
    return dateToSkip.add(const Duration(days: 1)).isBefore(today);
  }
}

//if yesterday or earlier
Color lerpIt(Color c) {
  return Color.lerp(c, Colors.black38, 0.3) as Color;
}
