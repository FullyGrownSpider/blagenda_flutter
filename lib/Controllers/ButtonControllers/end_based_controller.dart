import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';

import 'package:flutter/material.dart';
import '../../Commons/Models/Buttons/skippable_button.dart';
import '../my_date_controller.dart';
import 'basic_button_controller.dart';

abstract class EndBasedController<t extends BasicButton>
    extends BasicButtonController<t> implements Comparable<EndBasedController> {
  static final RegExp _completeReg = RegExp(
      r'(([0-9]{1,2})[:.,-]([0-9]){2} ?([a,p]m)?)|([0-9]{1,2}( )?[a,p]m)');
  static final RegExp _regBig =
      RegExp(r'([0-9]{1,2})[:.,-]([0-9]){2} ?([a,p]m)?\b');
  static final RegExp _regSmall = RegExp(r'([0-9]{1,2}) ?([a,p]m)\b');
  static final RegExp _replaceAPm = RegExp(r'[a,p]m$');
  static final RegExp _regFix = RegExp(r'[-,.]');
  static const String _splitString = ":";
  static const int showDayOfWeek = 6;
  static const int showDayTime = 4;
  MyDateController? _notNewTime;
  bool requiresChange = false;
  int timeOfDay = -1;
  int left = -1;
  late MyDateController dateController;

  @override
  Color get color {
    if (left != -1) {
      return button.color;
    }
    return Color.lerp(button.color, Colors.black38, 0.3) as Color;
  }

  bool wasJustAdded(MyDateController now) {
    return _notNewTime?.isAfter(now) == true;
  }

  void setToMakeNew() {
    _notNewTime = MyDateController.now().add(const Duration(minutes: 4));
    setTimeOfDay(button);
  }

  EndBasedController(t button) : super(button) {
    rebuild();
  }

  void rebuild() {
    create();
    left = howMuchLeft();
    setTimeOfDay(button);
  }

  void create();

  int howMuchLeft() => dateController.timeLeftUntil();

  bool isInLeft(int calculatedDay) => left == calculatedDay;

  void setTimeOfDay(BasicButton but) {
    //turn it into a 12 hour clock
    for (int j = 0; j < but.toDos.length; j++) {
      var itemsList = but.toDos[j]
          .toLowerCase()
          .replaceAll(_regFix, _splitString)
          .split(' ');
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
        return;
      }
      //remove all items that are found in the correct reg
      var items = correctReg;
      int result;
      //remove Am and Pm
      int indexOfAPm = items.indexOf(_replaceAPm);
      bool isPm = false;
      if (indexOfAPm != -1) {
        isPm = items.substring(indexOfAPm).startsWith('pm');
        items = items.substring(0, indexOfAPm);
      }
      if (items.contains(_splitString)) {
        result =
            int.parse(items.substring(0, items.indexOf(_splitString))) * 60 +
                int.parse(items.substring(items.indexOf(_splitString) + 1));
      } else {
        result = int.parse(items) * 60;
      }
      if (isPm) {
        if (result <= 720) result += 720;
      }
      if (result < 0 || result > 1440) return;
      //if time is 2.00 its not 2am its 2 pm. 7 is the earliest
      if (result < 420 && !but.toDos[j].contains(_replaceAPm)){
        result += 720;
      }
      timeOfDay = result;
      return;
    }
  }

  String displayJob() {
    if (left < showDayTime || _notNewTime != null) {
      return displayWithTimeJob();
    }
    return job;
  }

  String displayWithTimeJob() {
    if (timeOfDay == -1) return job;
    var dur = Duration(minutes: timeOfDay);
    String minutes = (timeOfDay % 60).toString();
    if (minutes.length == 1) minutes = '0' + minutes;
    return dur.inHours.toString() + _splitString + minutes + ' - ' + job;
  }

  @override
  String gettingTheStringShort() => BasicButtonController.displayGenericJob(
      displayJob(), BasicButtonController.maxValueCheck);

  String gettingTheStringShortWithTime() =>
      BasicButtonController.displayGenericJob(
          displayWithTimeJob(), BasicButtonController.maxValueCheck);

  String extensiveDate([bool withYear = false]) =>
      dateController.fullDisplayWithCal(withYear);

  @override
  String gettingTheStringSelected() =>
      gettingTheStringShortWithTime() + todosToString();

  String gettingTheStringShortWithDate() =>
      dateController.fullDisplayWithCal() + '\n' +
      gettingTheStringShortWithTime() ;

  @override
  String todosToString() {
    var result = super.todosToString();
    if (timeOfDay != -1 || _notNewTime != null) {
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
    if (result.startsWith('\n\n')) result = result.replaceFirst('\n', '');
    return result;
  }

  @override
  int compareTo(EndBasedController b) {
    var thisLeft = this is SkippableEndBasedController
        ? (this as SkippableEndBasedController).altLeft
        : left;
    var bLeft = b is SkippableEndBasedController ? b.altLeft : b.left;
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
}

abstract class SkippableEndBasedController<t extends SkippableButton>
    extends EndBasedController<t> {
  SkippableEndBasedController(super.button);

  SkippableEndBasedController createNew(MyDateController displayDate) {
    var clone = callConstructor(button);
    clone.dateController = displayDate;
    clone.altLeft = clone.howMuchLeft();
    clone.dateController = dateController;
    return clone;
  }

@override
  String gettingTheStringShortWithDate() =>
      dateController.fullDisplayWithCal() + '\n' +
          gettingTheStringShortWithTime() + '\n(Repeats)';

  @override
  void rebuild() {
    super.rebuild();
    if (altLeft == -1) altLeft = left;
  }

  @override
  String writeEmpty() =>
      "\n" +
      emogjiList[(job +
                  MyDateController.fromDaysFromNow(altLeft)
                      .microsecondsSinceEpoch
                      .toString())
              .hashCode %
          emogjiList.length];

  SkippableEndBasedController callConstructor(button);

  void newSkip(MyDateController dateController);

  MyDateController? skipDate() => button.dateToSkip;
  late int altLeft = -1;

  bool inTheNextDays(int days){
    for(int i = 0;i <= days;i++) {
      if (isInLeft(i)) return true;
    }
    return false;
  }

  @override
  String displayJob() {
    if (altLeft < EndBasedController.showDayTime || _notNewTime != null) {
      return displayWithTimeJob();
    }
    return job;
  }

//returns true if you should skip
  static bool skipCheck(SkippableButton button, DateTime date) =>
      button.dateToSkip!.day == date.day &&
      button.dateToSkip!.month == date.month &&
      button.dateToSkip!.year == date.year;

//returns true if you should skip
  bool skipCheckNotSure(int calc, int left) =>
      button.dateToSkip != null &&
      calc == left &&
      skipCheck(button, DateTime.now().add(Duration(days: calc)));

  @override
  Color get color {
    if (altLeft != -1) {
      return button.color;
    }
    return Color.lerp(button.color, Colors.black38, 0.3) as Color;
  }
}
