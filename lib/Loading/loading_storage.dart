import 'dart:io';

import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:date_format/date_format.dart';
import 'package:path_provider/path_provider.dart';

import 'button_conversion.dart';

class LoadingFromStorage {
  const LoadingFromStorage();

  Future<void> deleteButton(BasicButton but) async =>
      await SuperStorage(but.runtimeType.toString()).delete(uniquePart(but));

  Future<void> deleteButtons(List<BasicButton> buts) async {
    if (buts.isEmpty) return;
    List<String> items = buts.map((e) => uniquePart(e)).toList();
    await SuperStorage(buts.first.runtimeType.toString()).deleteAll(items);
  }

  Future<void> updateButton(BasicButton but) async =>
      await SuperStorage(but.runtimeType.toString())
          .update(buttonExportGenerator(but), uniquePart(but));

  Future<void> updateButtons(List<BasicButton> buts) async {
    if (buts.isEmpty) return;
    List<String> items = [];
    List<String> parts = [];
    for (var butt in buts) {
      items.add(buttonExportGenerator(butt));
      parts.add(uniquePart(butt));
    }
    await SuperStorage(buts.first.runtimeType.toString()).updateAll(items, parts);
  }

  Future<void> addButton(BasicButton but) async =>
      await SuperStorage(but.runtimeType.toString())
          .addItem(buttonExportGenerator(but));

  Future<List<t>> getItems<t extends BasicButton>() async {
    var file = SuperStorage(t.toString());
    List<String> allData = await file.readAllData();
    return allData.map((e) => buttonImportGenerator<t>(e)).toList();
  }

  Future<bool> shouldKeepFirstFile(String fileOne, String fileTwo) async {
    var one = SuperStorage(fileOne);
    var two = SuperStorage(fileTwo);
    if ((await one.lastUpdate()).isBefore(await two.lastUpdate())){
      var path = ('${await one._localPath}/${one._fileName}');
      (await two._localFile).copy(path).then((value) async => (await two._localFile).deleteSync());
      return false;
    }
    (await two._localFile).delete();
    return true;
  }
}

class SuperStorage {
  final String _fileName;
  String _startLine = 'Byrd';
  bool working = false;

  SuperStorage(this._fileName);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName.byd');
  }

  Future<DateTime> _lastUpdate() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return DateTime.now().subtract(const Duration(days: 300));
      // Read the date
      var dateText = (await file.readAsLines()).first;
      return DateTime.parse(dateText.replaceFirst('Byrd', ''));
    } catch (e) {
      return DateTime.now().subtract(const Duration(days: 300));
    }
  }
  Future<DateTime> lastUpdate() async {
    return await _doAction(() => _lastUpdate());
  }

  Future<List<String>> readAllData() async {
    return await _doAction(() => _readAllData());
  }

  Future<List<String>> _readAllData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      // Read the file
      return (await file.readAsLines()).sublist(1);
    } catch (e) {
      // If we encounter an error, return 0
      return [];
    }
  }

  Future<void> _writeStrings(List<String> items) async {
    _startLine = 'Byrd${formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])}';
    final file = await _localFile;
    items.insert(0, _startLine);
    await file.writeAsString(items.join('\n'));
  }

  Future<void> addItem(String string) async {
    await _doAction(() => _addItem(string));
  }

  Future<void> _addItem(String string) async {
    var values = await _readAllData();
    values.add(string);
    await _writeStrings(values);
  }

  Future<void> update(String newItem, String uniquePart) async {
    await _doAction(() => _update(newItem, uniquePart));
  }
  Future _doAction(Future Function() method) async {
    await waitTurn();
    working = true;
    var value = await method();
    working = false;
    return value;
  }
  Future<void> _update(String newItem, String uniquePart) async {
    var values = await _readAllData();
    var index = values.indexWhere((e) => e.contains(uniquePart));
    if (index == -1) {
      values[index] = newItem;
      await _writeStrings(values);
    } else {
      _addItem(newItem);
    }
  }

  Future<void> updateAll(List<String> newItem, List<String> uniquePart) async {
    await _doAction(() => _updateAll(newItem, uniquePart));
  }

  Future<void> _updateAll(List<String> newItem, List<String> uniquePart) async {
    var values = await _readAllData();
    for(int i = 0;i < newItem.length;i++){
      var index = values.indexWhere((e) => e.contains(uniquePart[i]));
      values[index] = newItem[i];
    }
    await _writeStrings(values);
  }

  Future<void> delete(String uniquePart) async {
    await _doAction(() => _delete(uniquePart));
  }

  Future<void> deleteAll(List<String> uniquePart) async {
    await _doAction(() => _deleteAll(uniquePart));
  }

  Future<void> _deleteAll(List<String> uniqueParts) async {
    var values = await _readAllData();
    for (var uniquePart in uniqueParts) {
      values.removeAt(values.indexWhere((e) => e.contains(uniquePart)));
    }
    await _writeStrings(values);
  }

  Future<void> _delete(String uniquePart) async {
    var values = await _readAllData();
    values.removeAt(values.indexWhere((e) => e.contains(uniquePart)));
    await _writeStrings(values);
  }

  Future<void> waitTurn() async {
    while (working) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
