import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:flutter/material.dart';

import '../../../Commons/Models/Buttons/skippable_button.dart';
import '../../my_date_controller.dart';
import '../mix_search_able.dart';
import 'basic_button_controller.dart';
import 'deadline_controller.dart';

abstract class EndBasedController<t extends BasicButton> extends BasicButtonController<t>
    implements Comparable<EndBasedController> {
  static final RegExp _completeReg =
      RegExp(r'(([0-9]{1,2})[:.,-]([0-9]){2} ?([a,p]m)?)|([0-9]{1,2}( )?[a,p]m)');
  static final RegExp _regBig = RegExp(r'([0-9]{1,2})[:.,-]([0-9]){2} ?([a,p]m)?\b');
  static final RegExp _regSmall = RegExp(r'([0-9]{1,2}) ?([a,p]m)\b');
  static final RegExp _replaceAPm = RegExp(r'[a,p]m$');
  static final RegExp _regFix = RegExp(r'[-,.]');
  static const String _splitString = ':';
  static const int showDayOfWeek = 6;
  static const int showDayTime = 4;
  bool requiresChange = false;
  int timeOfDay = -1;
  int daysLeft = -20;
  late MyDateController dateController;

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
  }

  void create();

  int howMuchLeft() => dateController.daysLeftUntil();

  bool isHappeningOnDayFromNow(int calculatedDay) => daysLeft == calculatedDay;

  void _setTimeOfDay() {
    var toDos = this.toDos.split('\n');
    //turn it into a 12 hour clock
    for (int j = 0; j < toDos.length; j++) {
      var itemsList = toDos[j].toLowerCase().replaceAll(_regFix, _splitString).split(' ');
      String correctReg = '';
      for (int i = 0; i < itemsList.length; i++) {
        if (itemsList.length - 1 != i) {
          if (itemsList[i + 1].startsWith(_replaceAPm)) {
            itemsList[i] += itemsList[i + 1];
          }
        }
        //see in what way time is written down either 10:00, 10:00am, 10am, 10 am or 10:00 am
        correctReg = itemsList[i].splitMapJoin(_regBig,
            onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '');
        if (correctReg == '') {
          correctReg = itemsList[i].splitMapJoin(_regSmall,
              onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '');
        }
        if (correctReg != '') {
          break;
        }
      }
      if (correctReg == '') {
        continue;
      }
      //remove all items that are found in the correct reg
      var items = correctReg;
      int result;
      //remove Am and Pm
      int indexOfAPm = items.indexOf(_replaceAPm);
      bool isPm = false;
      bool isAm = false;
      if (indexOfAPm != -1) {
        isPm = items.substring(indexOfAPm).startsWith('pm');
        isAm = !isPm;
        items = items.substring(0, indexOfAPm);
      }
      if (items.contains(_splitString)) {
        var timeOfMinutes = int.parse(items.substring(items.indexOf(_splitString) + 1));
        if (timeOfMinutes > 59) return;
        var timeOfHours = int.parse(items.substring(0, items.indexOf(_splitString)));
        result = timeOfHours * 60 + timeOfMinutes;
      } else {
        result = int.parse(items) * 60;
      }
      if (isPm) {
        if (result <= 720) result += 720;
      } else if (isAm && result >= 720) {
        return;
      }
      //if you have 1204pm you want 1204am and here that fix is done
      if (result > 1440 && indexOfAPm != -1) result -= 720;
      if (result < 0 || result > 1440) return;
      //if time is 2.00 its not 2am its 2 pm. 7 is the earliest
      if (result < 420 && indexOfAPm == -1) result += 720;
      timeOfDay = result;
      return;
    }
  }

  @visibleForTesting
  String displayJob() =>
      (daysLeft < showDayTime ? _displayWithTimeJob() : super.gettingTheStringShort())
          .trim();

  String _displayWithTimeJob() {
    if (timeOfDay == -1) return super.gettingTheStringShort();
    var dur = Duration(minutes: timeOfDay);
    String minutes = (timeOfDay % 60).toString().padLeft(2, '0');
    return '${dur.inHours.toString()}$_splitString$minutes - ${super.gettingTheStringShort()}';
  }

  String _gettingTheStringShortWithTime() =>
      (entitied != -1 ? BasicButtonController.entityIndicator : '') +
      displayGenericText(displayJob(), BasicButtonController.maxValueCheck);

  @override
  String gettingTheStringSelected() =>
      '${_gettingTheStringShortWithTime()}\n\n${todosToString()}'.trim();

  String gettingTheStringShortWithDate() =>
      '${dateController.stringFullDisplayWithCal()} - ${_gettingTheStringShortWithTime()}';

  @override
  String gettingTheStringShort() => _gettingTheStringShortWithTime();

  @override
  String todosToString() {
    var result = super.todosToString();
    if (timeOfDay != -1) {
      var results = result.split('\n');
      for (int i = 0; i < results.length; i++) {
        //it equals the complete reg
        if (results[i].startsWith(_completeReg)) {
          results[i] = results[i].replaceFirst(_completeReg, '');
          if (results[i].trim().isEmpty) {
            results.removeAt(i);
            if (results.length < i && results[i + 1].isEmpty) {
              results.removeAt(i + 1);
            }
            result = results.join('\n');
            if (result.trim().isEmpty) result = writeEmpty();
          }
          break;
        }
      }
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

//returns true if you should skip the copy
  bool skipCheckNotSure(int calc, int left) =>
      button.dateToSkip != null &&
      calc == left &&
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
