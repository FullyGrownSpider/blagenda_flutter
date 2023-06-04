import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:flutter/material.dart';

import '../Controllers/ScreensControllers/common_screen_controller.dart';
import '../Controllers/my_date_controller.dart';

Map<String, String> lineConversion(String line) {
  var map = <String, String>{};
  map.addEntries(line
      .split(storageSep)
      .where((e) => e.length > 2 && e.contains(storageIdentifier))
      .map((e) {
    var strings = e.split(storageIdentifier);
    return MapEntry(strings[0], strings[1]);
  }));
  return map;
}

t buttonImportGenerator<t extends BasicButton>(String line) {
  var list = lineConversion(line);
  dynamic but = BasicButton(
      dataImportGenerator<String>(list[_basicValuesToString(_BasicValues.job)]),
      dataImportGenerator<List>(list[_basicValuesToString(_BasicValues.td)])
          as List<String>,
      dataImportGenerator<int>(list[_basicValuesToString(_BasicValues.id)]),
      dataImportGenerator<Color>(list[_basicValuesToString(_BasicValues.col)]));
  if (buttonCreatingMap.containsKey(t)) {
    but = buttonCreatingMap[t]!(but, list);
  }
  return but;
}

Map<Type, BasicButton Function(BasicButton, Map<String, String>)>
    buttonCreatingMap = {
  AgainMonthDay: (but, list) => AgainMonthDay.fromButton(
      but,
      dataImportGenerator<int>(list[_basicValuesToString(_BasicValues.fV)]),
      dataImportDateGenerator(list[_basicValuesToString(_BasicValues.sS)])),
  AgainWeekDay: (but, list) => AgainWeekDay.fromButton(
      but,
      dataImportGenerator<int>(list[_basicValuesToString(_BasicValues.fV)]),
      dataImportDateGenerator(list[_basicValuesToString(_BasicValues.sS)])),
  AgainAmountDay: (but, list) => AgainAmountDay.fromButton(
      but,
      dataImportGenerator<MyDateController>(
          list[_basicValuesToString(_BasicValues.fV)]),
      dataImportGenerator<int>(list[_basicValuesToString(_BasicValues.sV)]),
      dataImportDateGenerator(list[_basicValuesToString(_BasicValues.sS)])),
  AgainYearDay: (but, list) => AgainYearDay.fromButton(
      but,
      dataImportGenerator<int>(list[_basicValuesToString(_BasicValues.fV)]),
      dataImportGenerator<int>(list[_basicValuesToString(_BasicValues.sV)]),
      dataImportDateGenerator(list[_basicValuesToString(_BasicValues.sS)])),
  Deadline: (but, list) => Deadline.fromButton(
      but,
      dataImportGenerator<MyDateController>(
          list[_basicValuesToString(_BasicValues.fV)]),
      dataImportGenerator<String>(list[_basicValuesToString(_BasicValues.sV)])),
};

String buttonExportGenerator(BasicButton line) {
  var buf = StringBuffer();
  buf.write(
      dataExportGenerator(line.job, _basicValuesToString(_BasicValues.job)));
  buf.write(
      dataExportGenerator(line.id, _basicValuesToString(_BasicValues.id)));
  buf.write(
      dataExportGenerator(line.toDos, _basicValuesToString(_BasicValues.td)));
  buf.write(
      dataExportGenerator(line.color, _basicValuesToString(_BasicValues.col)));
  if (_dataExportMap.containsKey(line.runtimeType)) {
    _dataExportMap[line.runtimeType]!(line, buf);
  }
  buf.write(storageSep);
  return buf.toString();
}

_basicValuesToString(_BasicValues val) => val.toString().split('.').last;

String uniquePart<t extends BasicButton>(t line) =>
    dataExportGenerator(line.id, _basicValuesToString(_BasicValues.id)) +
    storageSep;

///enumeration used to give data names in map structure
enum _BasicValues { job, td, id, col, fV, sV, sS }

///class used to turn the values used by buttons into string and back
const String storageSep = '◘';
const String storageIdentifier = '○';
const String storageListSep = '•';

MyDateController? dataImportDateGenerator(String? line) {
  if (line == null) {
    return null;
  } else {
    List<String> x = line.split(storageListSep);
    return MyDateController(dataImportGenerator<int>(x[0]),
        dataImportGenerator<int>(x[1]), dataImportGenerator<int>(x[2]));
  }
}

t dataImportGenerator<t>(String? line) =>
    _dataImportGeneratorMap[t]!(line) as t;

final Map<Type, dynamic Function(String?)> _dataImportGeneratorMap = {
  Color: (s) {
    if (s == null) {
      return usedColors.first;
    } else {
      List<String> x = s.split(storageListSep);
      return Color.fromARGB(
          255, int.parse(x[0]), int.parse(x[1]), int.parse(x[2]));
    }
  },
  List: (s) {
    if (s == null) {
      return [];
    } else {
      return s.split(storageListSep);
    }
  },
  String: (s) {
    if (s == null) {
      return '';
    } else {
      return s;
    }
  },
  int: (s) {
    if (s == null) {
      return -1;
    } else {
      return int.parse(s);
    }
  },
  bool: (s) => s == 't',
  MyDateController: (s) {
    if (s == null) {
      return MyDateController.now();
    } else {
      List<String> x = s.split(storageListSep);
      return MyDateController(dataImportGenerator<int>(x[0]),
          dataImportGenerator<int>(x[1]), dataImportGenerator<int>(x[2]));
    }
  }
};

final Map<Type, void Function(dynamic, StringBuffer)> _dataExportMap = {
  List<String>: (value, buf) => buf.write(value.join(storageListSep)),
  Color: (value, buf) {
    buf.write(value.red);
    buf.write(storageListSep);
    buf.write(value.green);
    buf.write(storageListSep);
    buf.write(value.blue);
  },
  MyDateController: (value, buf) {
    buf.write(value.year);
    buf.write(storageListSep);
    buf.write(value.month);
    buf.write(storageListSep);
    buf.write(value.day);
  },
  bool: (value, buf) => buf.write(value ? 't' : ''),
  Deadline: (value, buf) {
    buf.write(
        dataExportGenerator(value.date, _basicValuesToString(_BasicValues.fV)));
    buf.write(dataExportGenerator(
        value.calendar, _basicValuesToString(_BasicValues.sV)));
  },
  AgainMonthDay: (value, buf) {
    buf.write(
        dataExportGenerator(value.day, _basicValuesToString(_BasicValues.fV)));
    buf.write(dataExportGenerator(
        value.dateToSkip, _basicValuesToString(_BasicValues.sS)));
  },
  AgainYearDay: (value, buf) {
    buf.write(
        dataExportGenerator(value.day, _basicValuesToString(_BasicValues.fV)));
    buf.write(dataExportGenerator(
        value.month, _basicValuesToString(_BasicValues.sV)));
    buf.write(dataExportGenerator(
        value.dateToSkip, _basicValuesToString(_BasicValues.sS)));
  },
  AgainWeekDay: (value, buf) {
    buf.write(
        dataExportGenerator(value.day, _basicValuesToString(_BasicValues.fV)));
    buf.write(dataExportGenerator(
        value.dateToSkip, _basicValuesToString(_BasicValues.sS)));
  },
  AgainAmountDay: (value, buf) {
    buf.write(
        dataExportGenerator(value.date, _basicValuesToString(_BasicValues.fV)));
    buf.write(
        dataExportGenerator(value.day, _basicValuesToString(_BasicValues.sV)));
    buf.write(dataExportGenerator(
        value.dateToSkip, _basicValuesToString(_BasicValues.sS)));
  }
};

String dataExportGenerator(dynamic value, String valueName) {
  if (value == null) return '';
  StringBuffer buf = StringBuffer(storageSep + valueName + storageIdentifier);
  if (_dataExportMap.containsKey(value.runtimeType)) {
    _dataExportMap[value.runtimeType]!(value, buf);
  } else if (value is Color) {
    _dataExportMap[Color]!(value, buf);
  } else {
    buf.write(value);
  }
  return buf.toString();
}
