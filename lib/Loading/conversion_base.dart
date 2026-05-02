import 'package:blagenda_flutter_simple/Commons/store_able.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/weird_again_controller.dart';
import 'package:blagenda_flutter_simple/Loading/loading_storage.dart';
import 'package:flutter/material.dart';

import '../Commons/Models/Buttons/again.dart';
import '../Commons/Models/Buttons/basic_button.dart';
import '../Commons/Models/Buttons/deadline.dart';
import '../Commons/Models/Buttons/weird_again.dart';
import '../Commons/Models/entity.dart';
import '../Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import '../Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import '../Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import '../Controllers/ObjectControllers/entity_controller.dart';
import '../Controllers/my_date_controller.dart';
import '../common_items.dart';

class ImportExportLogic {
  final Type type;
  final String butVal;
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

  const ImportExportLogic(this.type, this._toAssign, this.butVal, this._toGet);
}

String enumToString(dynamic val) =>
    val
        .toString()
        .split('.')
        .last;

Map<String, dynamic> itemToStoringMap(dynamic button) {
  return Map.fromEntries(
      _allDataConversion.map((as) => MapEntry(as.butVal, as.toGet(button))))
    ..removeWhere((key, value) => value == null);
}

///class used to turn the values used by buttons into string and back
const String storageSep = '◘';
const String storageIdentifier = '○';
const String storageListSep = '•';

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

dataImportGenerator(String? line, Type t) => dataImportGeneratorMap[t]!(line);

final Map<Type, dynamic Function(String?)> dataImportGeneratorMap = {
  Color: (s) {
    if (s == null) {
      return usedColors.first;
    }
    List<String> x = s.split(storageListSep);
    return Color.fromARGB(
        255, int.parse(x[0]), int.parse(x[1]), int.parse(x[2]));
  },
  String: (s) {
    if (s == null) {
      return '';
    }
    return s.replaceAll(storageListSep, '\n');
  },
  int: (s) {
    if (s == null) {
      return -1;
    }
    return int.parse(s);
  },
  bool: (s) => s == 't',
  MyDateController: (s) {
    if (s == null) {
      return MyDateController.now();
    }
    List<String> x = s.split(storageListSep);
    return MyDateController(dataImportGenerator(x[0], int),
        dataImportGenerator(x[1], int), dataImportGenerator(x[2], int));
  },
  List<Tag>: (s) {
    var list = <Tag>[];
    if (s == null) return list;
    var tempList = s.split(storageListSep + storageListSep);
    tempList.removeLast();
    list.addAll(tempList.map((newString) {
      var tagWithData = newString.split(storageListSep);
      tagWithData.removeWhere((e) => e.isEmpty);
      return Tag(
          tagWithData.first,
          tagWithData.length == 2
              ? tagWithData.last.replaceAll('\\n', '\n')
              : tagWithData.length == 1
              ? ''
              : TagObjectReference(
              tagWithData[1], int.parse(tagWithData[2])));
    }));
    return list;
  },
  Map<MyDateController, List<int>>: (s) {
    var map = <MyDateController, List<int>>{};
    if (s == null) return map;
    var tempList = s.split(storageListSep + storageListSep).where((e) => e.isNotEmpty);
    for (var item in tempList) {
      var values = item.split(storageListSep);
      var date = dataImportGenerator(values.sublist(0,3).join(storageListSep), MyDateController);
      var items = values.sublist(3).map((e) => int.parse(e)).toList();
      map.addAll({date: items});
    }
    return map;
  }
};

void _dataExportMap(dynamic value, StringBuffer buf) {
  switch (value.runtimeType) {
    case const (MaterialColor) :
    case const (MaterialAccentColor) :
    case const (Color) :
      buf.write(value.red);
      buf.write(storageListSep);
      buf.write(value.green);
      buf.write(storageListSep);
      buf.write(value.blue);
      return;
    case
    const (String):
      buf.write(
          value.toString().replaceAll(SuperStorage.lineEnd, storageListSep));
      return;
    case const (MyDateController):
      buf.write(value.year);
      buf.write(storageListSep);
      buf.write(value.month);
      buf.write(storageListSep);
      buf.write(value.day);
      return;
    case const (int):
      buf.write(value);
      return;
    case const (bool):
      buf.write(value ? 't' : '');
      return;
    case const (List<Tag>):
      value.forEach((e) {
        buf.write(e.name! + storageListSep);
        if (e.data is TagObjectReference) {
          _dataExportMap(e.data, buf);
        } else {
          buf.write(e.data.toString().replaceAll(SuperStorage.lineEnd, '\\n'));
        }
        buf.write(storageListSep + storageListSep);
      });
      return;
    case const (TagObjectReference):
      buf.write(value.type.toString());
      buf.write(storageListSep);
      buf.write(value.itd);
      return;
    default:
      if (value is Map<MyDateController, List<int>>) {
        Map<MyDateController, List<int>> values = value;
        for (var item in values.keys) {
          _dataExportMap(item, buf);
          buf.write(storageListSep);
          buf.write(values[item]!.map((e) => e.toString()).join(storageListSep));
          buf.write(storageListSep);
          buf.write(storageListSep);
        }
        return;
      }

      throw Exception('Unknown type is asked for');
  }
}

  String uniquePart<t extends StoreAble>(t line) =>
      dataExportGenerator(line.id, StringBuffer(), 'id').toString() +
          storageSep;

  StringBuffer dataExportGenerator(dynamic value, StringBuffer buf,
      String keyName) {
    if (value == null) return buf;
    buf.write(storageSep + keyName + storageIdentifier);
    _dataExportMap(value, buf);
    return buf;
  }

  String exportGenerator(StoreAble button) {
    StringBuffer buf = StringBuffer();
    itemToStoringMap(button).forEach((key, value) {
      dataExportGenerator(value, buf, key);
    });
    return buf.toString();
  }

  t itemImportGenerator<t extends StoreAble>(String line, dynamic toFill,
      List<ImportExportLogic> importExportLogic) {
    Map<String, String> value = lineConversion(line);
    for (var assignable in importExportLogic) {
      var stringVal = assignable.butVal;
      if (value.containsKey(stringVal)) {
        assignable.toAssign(
            toFill, dataImportGenerator(value[stringVal], assignable.type));
      }
    }
    return toFill;
  }

  dynamic createEmptyStoreAble(Type t) {
    switch (t) {
      case const (Deadline):
        return Deadline();
      case const (AgainAmountDay):
        return AgainAmountDay();
      case const (AgainMonthDay):
        return AgainMonthDay();
      case const (AgainWeekDay):
        return AgainWeekDay();
      case const (AgainYearDay):
        return AgainYearDay();
      case const (AgainWeird):
        return AgainWeird();
      case const (Entity):
        return Entity();
      default:
        return BasicButton();
    }
  }

  dynamic dataToController(StoreAble item) {
    Type T = item.runtimeType;
    switch (T) {
      case const (AgainWeekDay):
        return AgainWeekController(item as AgainWeekDay);
      case const (AgainAmountDay):
        return AgainAmountController(item as AgainAmountDay);
      case const (AgainYearDay):
        return AgainYearController(item as AgainYearDay);
      case const (AgainMonthDay):
        return AgainMonthController(item as AgainMonthDay);
      case const (Deadline):
        return DeadlineController(item as Deadline);
      case const (Entity):
        return EntityController(item as Entity);
      case const (AgainWeird):
        return AgainWeirdController(item as AgainWeird);
      default:
        return NoteController(item as BasicButton);
    }
  }

  final List<Type> typeList = [
    AgainMonthDay,
    AgainWeekDay,
    AgainYearDay,
    AgainAmountDay,
    AgainWeird,
    Deadline,
    BasicButton,
    Entity
  ];

  t importGenerator<t extends StoreAble>(String line) =>
      itemImportGenerator(line, createEmptyStoreAble(t), _allDataConversion);

  List<ImportExportLogic> _allDataConversion = [
    ImportExportLogic(String, (button, value) => button.job = value,
        enumToString(PossibleValues.job), (button) => button.job),
    ImportExportLogic(String, (button, value) => button.toDos = value,
        enumToString(PossibleValues.todo), (button) => button.toDos),
    ImportExportLogic(int, (button, value) => button.id = value,
        enumToString(PossibleValues.id), (button) => button.id),
    ImportExportLogic(Color, (button, value) => button.color = value,
        enumToString(PossibleValues.col), (button) => button.color),
    ImportExportLogic(int, (button, value) => button.month = value,
        enumToString(PossibleValues.mon), (button) => button.month),
    ImportExportLogic(MyDateController, (button, value) => button.date = value,
        enumToString(PossibleValues.dat), (button) => button.date),
    ImportExportLogic(int, (button, value) => button.day = value,
        enumToString(PossibleValues.day), (button) => button.day),
    ImportExportLogic(
        MyDateController,
            (button, value) => button.dateToSkip = value,
        enumToString(PossibleValues.skp),
            (button) => button.dateToSkip),
    ImportExportLogic(
        MyDateController,
            (button, value) => button.endingDate = value,
        enumToString(PossibleValues.end),
            (button) => button.endingDate),
    ImportExportLogic(
        MyDateController,
            (button, value) => button.startDate = value,
        enumToString(PossibleValues.str),
            (button) => button.startDate),
    ImportExportLogic(bool, (button, value) => button.important = value,
        enumToString(PossibleValues.imp), (button) => button.important),
    ImportExportLogic(List<Tag>, (entity, value) => entity.tags = value,
        enumToString(PossibleValues.list), (entity) => entity.tags),
    ImportExportLogic(Map<MyDateController, List<int>>, (button, value) =>
    button.dates = value,
        enumToString(PossibleValues.dlst), (button) => button.dates),
  ];

  enum PossibleValues {
  job,
  id,
  mon,
  day,
  skp,
  str,
  end,
  dat,
  todo,
  col,
  imp,
  list,
  dlst
  }

  String typeToFile(Type t) {
  if (!typeList.contains(t)) {
  throw FormatException('Type: ${t.toString()} is not found');
  }
  return '$t.byd';
  }

  dynamic map2Data(Map<String, dynamic> data, Type t) {
  dynamic button = createEmptyStoreAble(t);
  for (var assignable in _allDataConversion) {
  assignable.toAssign(button, data[assignable.butVal]);
  }
  return button;
  }
