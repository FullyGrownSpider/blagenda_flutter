import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:flutter/material.dart';

import '../Controllers/ButtonControllers/again_controller.dart';
import '../Controllers/ButtonControllers/basic_button_controller.dart';
import '../Controllers/ButtonControllers/deadline_controller.dart';
import '../Controllers/ButtonControllers/note_controller.dart';
import '../Controllers/ScreensControllers/common_screen_controller.dart';
import '../Controllers/my_date_controller.dart';

Map<String, String> _lineConversion(String line) {
  var map = <String, String>{};
  map.addEntries(line
      .split(_storageSep)
      .where((e) => e.length > 2 && e.contains(_storageIdentifier))
      .map((e) {
    var strings = e.split(_storageIdentifier);
    return MapEntry(strings[0], strings[1]);
  }));
  return map;
}

///class used to turn the values used by buttons into string and back
const String _storageSep = '◘';
const String _storageIdentifier = '○';
const String _storageListSep = '•';

_dataImportGenerator(String? line, Type t) => _dataImportGeneratorMap[t]!(line);

final Map<Type, dynamic Function(String?)> _dataImportGeneratorMap = {
  Color: (s) {
    if (s == null) {
      return usedColors.first;
    } else {
      List<String> x = s.split(_storageListSep);
      return Color.fromARGB(
          255, int.parse(x[0]), int.parse(x[1]), int.parse(x[2]));
    }
  },
  List<String>: (s) {
    if (s == null) {
      return [];
    } else {
      return s.split(_storageListSep);
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
  String: (s) => s ??= '',
  MyDateController: (s) {
    if (s == null) {
      return MyDateController.now();
    } else {
      List<String> x = s.split(_storageListSep);
      return MyDateController(_dataImportGenerator(x[0], int),
          _dataImportGenerator(x[1], int), _dataImportGenerator(x[2], int));
    }
  }
};

final Map<Type, void Function(dynamic, StringBuffer)> _dataExportMap = {
  List<String>: (value, buf) => buf.write(value.join(_storageListSep)),
  MaterialColor: (value, buf) {
    buf.write(value.red);
    buf.write(_storageListSep);
    buf.write(value.green);
    buf.write(_storageListSep);
    buf.write(value.blue);
  },
  MyDateController: (value, buf) {
    buf.write(value.year);
    buf.write(_storageListSep);
    buf.write(value.month);
    buf.write(_storageListSep);
    buf.write(value.day);
  },
  bool: (value, buf) => buf.write(value ? 't' : '')
};

String uniquePart<t extends BasicButton>(t line) =>
    dataExportGenerator(
            line.id, ValuesOfButtons.id, StringBuffer())
        .toString() +
    _storageSep;

StringBuffer dataExportGenerator(
    dynamic value, ValuesOfButtons enumValue, StringBuffer buf) {
  if (value == null) return buf;
  buf.write(_storageSep + _enumToString(enumValue) + _storageIdentifier);
  if (_dataExportMap.containsKey(value.runtimeType)) {
    _dataExportMap[value.runtimeType]!(value, buf);
  } else {
    buf.write(value);
  }
  return buf;
}

dynamic buttonCreator(Map<ValuesOfButtons, dynamic> data, Type t) {
  dynamic button = createEmptyButton(t);
  for (var assignable in _valueToType) {
    assignable.toAssign(button, data[assignable.butVal]);
  }
  return button;
}

t buttonImportGenerator<t extends BasicButton>(String line) {
  Map<String, String> value = _lineConversion(line);
  dynamic button = createEmptyButton(t);
  for (var assignable in _valueToType) {
    var stringVal = assignable.butValToString();
    if (value.containsKey(stringVal)) {
      assignable.toAssign(
          button, _dataImportGenerator(value[stringVal], assignable.type));
    }
  }
  return button;
}

List<_ImportExportLogic> _valueToType = [
  _ImportExportLogic(String, (button, value) => button.job = value,
      ValuesOfButtons.job, (button) => button.job),
  _ImportExportLogic(List<String>, (button, value) => button.toDos = value,
      ValuesOfButtons.todo, (button) => button.toDos),
  _ImportExportLogic(int, (button, value) => button.id = value,
      ValuesOfButtons.id, (button) => button.id),
  _ImportExportLogic(Color, (button, value) => button.color = value,
      ValuesOfButtons.col, (button) => button.color),
  _ImportExportLogic(int, (button, value) => button.month = value,
      ValuesOfButtons.mon, (button) => button.month),
  _ImportExportLogic(MyDateController, (button, value) => button.date = value,
      ValuesOfButtons.dat, (button) => button.date),
  _ImportExportLogic(int, (button, value) => button.day = value,
      ValuesOfButtons.day, (button) => button.day),
  _ImportExportLogic(String, (button, value) => button.calendar = value,
      ValuesOfButtons.cal, (button) => button.calendar)
];

class _ImportExportLogic {
  final Type type;
  final ValuesOfButtons butVal;
  final void Function(dynamic, dynamic) _toAssign;
  final dynamic Function(dynamic) _toGet;

  dynamic toGet(but) {
    try {
      return _toGet(but);
    } catch (e) {
      return null;
    }
  }

  void toAssign(but, val) {
    try {
      _toAssign(but, val);
    } catch (e) {
      //ignore me
    }
  }

  butValToString() => butVal.toString().split('.').last;

  const _ImportExportLogic(this.type, this._toAssign, this.butVal, this._toGet);
}

enum ValuesOfButtons { job, todo, id, col, mon, dat, day, cal }

_enumToString(ValuesOfButtons val) => val.toString().split('.').last;

dynamic buttonExportGenerator(dynamic button) {
  StringBuffer buf = StringBuffer();
  buttonToMap(button)
      .forEach((key, value) => dataExportGenerator(value, key, buf));
  return buf.toString();
}

Map<ValuesOfButtons, dynamic> buttonToMap(dynamic button) {
  return Map.fromEntries(
      _valueToType.map((as) => MapEntry(as.butVal, as.toGet(button))));
}

dynamic createEmptyButton(Type t) {
  switch (t) {
    case Deadline:
      return Deadline();
    case AgainAmountDay:
      return AgainAmountDay();
    case AgainMonthDay:
      return AgainMonthDay();
    case AgainWeekDay:
      return AgainWeekDay();
    case AgainYearDay:
      return AgainYearDay();
    default:
      return BasicButton();
  }
}

BasicButtonController buttonToController(Type t, BasicButton b) => _buttonToController[t]!(b);

final Map<Type, BasicButtonController Function(BasicButton)>
    _buttonToController = {
  AgainAmountDay: (button) =>
      AgainAmountController(button as AgainAmountDay),
  AgainWeekDay: (button) => AgainWeekController(button as AgainWeekDay),
  AgainYearDay: (button) => AgainYearController(button as AgainYearDay),
  AgainMonthDay: (button) =>
      AgainMonthController(button as AgainMonthDay),
  Deadline: (button) => DeadlineController(button as Deadline),
  BasicButton: (button) => NoteController(button),
};

// '${t.toString()}.byd'
String typeToFile(Type t){
  if (!typeList.contains(t)) {
    throw FormatException('Type: ${t.toString()} is not found');
  }
  return "$t.byd";
}

final List<Type> typeList = [
  AgainMonthDay,
  AgainWeekDay,
  AgainYearDay,
  AgainAmountDay,
  Deadline,
  BasicButton
];