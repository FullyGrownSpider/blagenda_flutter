import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class MyDateController extends DateTime {
  static MyDateController lookTime = MyDateController.now();
  static MyDateController today =
      MyDateController(lookTime.year, lookTime.month, lookTime.day, 2);

  static final RegExp letters = RegExp(r'[a-z]+\b');
  static final RegExp comp = RegExp(r'\b[0-9]+[a-z]+\b');

  static MyDateController yesterday = _dateTimeToMyDateController(
      MyDateController(lookTime.year, lookTime.month, lookTime.day, 2)
          .subtract(const Duration(days: 1)));

  MyDateController(super.year,
      [super.month = 1, super.day = 1, super.hour = 0, super.minute]);

  static bool didDayPass() {
    lookTime = MyDateController.now();
    return !aboutEqual(lookTime, today);
  }

  static bool didHourPass(int lastHour) {
    return lookTime.hour != lastHour || lookTime.day != today.day;
  }

  static MyDateController fromDaysFromNow(int fromNow) =>
      MyDateController.today.addOrRemoveDays(fromNow);

  static int monthCalc(int fromNow) {
    var month = fromDaysFromNow(fromNow).month;
    return DateTimeRange(
                start: DateTime(today.year, month), end: DateTime(today.year, month + 1))
            .duration
            .inDays -
        1;
  }

  @override
  MyDateController add(Duration duration) =>
      _dateTimeToMyDateController(super.add(duration));

  static MyDateController now() => _dateTimeToMyDateController(DateTime.now());

  static _dateTimeToMyDateController(DateTime d) =>
      MyDateController(d.year, d.month, d.day, d.hour, d.minute);

  static void resetDate() {
    lookTime = MyDateController.now();
    today = MyDateController(lookTime.year, lookTime.month, lookTime.day, 2);
  }

  static MyDateController get nowDate => today;

  int daysLeftUntil() {
    return isAfter(today) ? _daysLeftUntil(today, this) : -_daysLeftUntil(this, today);
  }

  int _daysLeftUntil(MyDateController low, MyDateController high) =>
      Duration(hours: high.difference(low).inHours + 5).inDays;

  MyDateController addOrRemoveDays(int days) => add(Duration(days: days));

  String inputDisplayString(bool showYear) {
    var monthValue = month.toRadixString(16);
    var dayValue = day.toString().padLeft(2, '0');
    return '$dayValue - $monthValue ${(showYear ? ' - ${year.toString()}' : '')}';
  }

  String fullDisplayWithCal([bool withYear = true]) => formatDate(this,
      [D, ' ', d, ' - ', m, ' (', M, ')', withYear ? ' - ' : '', withYear ? yy : '']);

  String dayDisplay() => '${formatDate(this, [D])}: ';

  /// will translate a representation of a date to an actual usable date
  /// will change + to 7 extra days and * to 2
  /// so 'su+' is the sunday after next sunday
  /// 'su##' will be sunday after 4 days
  static MyDateController? translate(String myNumb) {
    int toAdd = '+'.allMatches(myNumb).length * 7;
    myNumb = myNumb.replaceAll('+', '');
    toAdd += '*'.allMatches(myNumb).length * 2;
    myNumb = myNumb.replaceAll('*', '');
    myNumb = myNumb.replaceAll('-', ' ').replaceAll('.', ' ').replaceAll(',', ' ').trim();
    List<String> parts = myNumb.toLowerCase().split(' ');
    parts.removeWhere((e) => e.isEmpty);
    if (parts.length > 3) {
      return null;
    }
    if (parts.length == 1) {
      MyDateController? theDate =
          _ifDateOnlyOneChar(parts.first) ?? _endsOrdinal(parts.first);
      return theDate?.add(Duration(days: toAdd));
    }

    int? dateY = _consumeYear(parts);
    int? dateM = _consumeMonthLetter(parts) ?? _consumeMonth(parts, dateY == null);
    if (parts.isEmpty || dateM == null) return null;
    int? dateD = int.tryParse(parts.last);
    if (dateD == null) return null;
    return _createDate(dateY, dateM, dateD).add(Duration(days: toAdd));
  }

  static int? _consumeYear(List<String> parts) {
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].length >= 4) {
        return int.tryParse(parts.removeAt(i));
      }
    }
    return null;
  }

  static MyDateController _createDate(int? dateY, int dateM, int dateD) {
    MyDateController cal;
    if (dateY == null) {
      dateY = nowDate.year;
      cal = MyDateController(dateY, dateM, dateD);
      if (cal.isBefore(nowDate)) {
        dateY += 1;
        return MyDateController(dateY, dateM, dateD);
      }
    }
    return MyDateController(dateY, dateM, dateD);
  }

  static int? _consumeMonthLetter(List<String> parts) {
    for (int i = 0; i < 12; i++) {
      for (int ii = 0; ii < parts.length; ii++) {
        if (parts[ii].contains(months[i].toLowerCase()) ||
            parts[ii].contains(monthsNL[i].toLowerCase())) {
          int dateM = i;
          parts.removeAt(ii);
          return dateM + 1;
        }
      }
    }
    return null;
  }

  static int? _consumeMonth(List<String> parts, bool fullTest) {
    if (fullTest) {
      for (int i = parts.length - 1; i > -1; i--) {
        if (parts[i].length == 1) {
          return int.tryParse(parts.removeAt(i), radix: 16);
        }
      }
    }
    if (parts.isEmpty) return null;
    return int.tryParse(parts.removeLast());
  }

  static MyDateController? _ifDateOnlyOneChar(String word) {
    //its a number that needs to be added to today like its in 5 days
    int? daysUntilDay = int.tryParse(word);
    if (daysUntilDay != null && daysUntilDay < 0) {
      return MyDateController.nowDate.addOrRemoveDays(daysUntilDay);
    }
    if (daysUntilDay == null) {
      for (int i = 0; i < 7; i++) {
        if (word.startsWith(_daysEn[i]) || word.startsWith(_daysNe[i])) {
          daysUntilDay = ((i - nowDate.weekday) % 7);
          if (daysUntilDay <= 1) {
            daysUntilDay = 7 + daysUntilDay;
          }
          break;
        }
      }
    }
    if (daysUntilDay != null) {
      return nowDate.addOrRemoveDays(daysUntilDay);
    }
    for (int i = 0; i < 12; i++) {
      if (word.startsWith(months[i].toLowerCase()) ||
          word.startsWith(monthsNL[i].toLowerCase())) {
        var d = MyDateController(nowDate.year, i + 1);
        if (d.isBefore(MyDateController.today)) {
          d = MyDateController(nowDate.year + 1, i + 1);
        }
        return d;
      }
    }
    return null;
  }

  static MyDateController? _endsOrdinal(String word) {
    if (!comp.hasMatch(word)) return null;
    word = word.replaceAll(letters, '');
    var numb = int.parse(word);
    var now = MyDateController.now();
    var timeMeant =
        MyDateController(now.year, now.month, 1).add(Duration(days: numb - 1));
    if (timeMeant.month != now.month) return null;
    if (timeMeant.isBefore(now)) {
      timeMeant =
          MyDateController(now.year, now.month + 1, 1).add(Duration(days: numb - 1));
    }
    return timeMeant;
  }

  static MyDateController fromDMY(int year, int month, int day) =>
      MyDateController(year, month, day);

  static MyDateController fromDM(int month, int day) =>
      MyDateController(nowDate.year, month, day);

  static MyDateController fromDMNextTime(int month, int day) {
    var now = nowDate;
    var date = MyDateController(now.year, month, day);
    if (date.isBefore(now)) {
      date = MyDateController(now.year + 1, month, day);
    }
    return date;
  }

  //----------------------------------------------------------------------

  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  static const List<String> monthsNL = [
    'Jan',
    'Feb',
    'Maa',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  static const List<String> monthsNLFull = [
    'january',
    'february',
    'maart',
    'april',
    'mei',
    'juni',
    'july',
    'augustus',
    'september',
    'october',
    'november',
    'december',
  ];
  static const List<String> monthsENFull = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];
  static const List<String> monthDays = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31'
  ];
  static const List<String> daysEn = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const List<String> _daysEn = ['su', 'mo', 'tu', 'we', 'th', 'fr', 'sa'];
  static const List<String> _daysNe = ['zo', 'ma', 'di', 'wo', 'do', 'vr', 'za'];

  static bool aboutEqual(DateTime first, DateTime second) {
    return first.day == second.day &&
        first.month == second.month &&
        first.year == second.year;
  }
}
