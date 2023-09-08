import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Loading/dropbox_client.dart';
import 'package:blagenda_flutter_simple/Loading/loading_storage.dart';

import '../Controllers/ButtonControllers/basic_button_controller.dart';

class Loading {
  final DropboxClient _client = const DropboxClient();
  final LoadingFromStorage _local = const LoadingFromStorage();
  final List<Type> typeList = [
    AgainMonthDay,
    AgainWeekDay,
    AgainYearDay,
    AgainAmountDay,
    Deadline,
    BasicButton
  ];
  final List<Type> uploader = [];

  Future<void> deleteButton(BasicButtonController but) async {
    await _local.deleteButton(but.button);
    await _upload(but.button.runtimeType);
  }

  Future<void> deleteButtons(List<BasicButtonController> buts) async {
    if (buts.isEmpty) return;
    await _local.deleteButtons(buts.map((e) => e.button).toList());
    await _upload(buts.first.button.runtimeType);
  }

  Future<void> updateButton(BasicButtonController but) async {
    await _local.updateButton(but.button);
    await _upload(but.button.runtimeType);
  }

  Future<void> updateButtons(List<BasicButtonController> buts) async {
    if (buts.isEmpty) return;
    await _local.updateButtons(buts.map((e) => e.button).toList());
    await _upload(buts.first.button.runtimeType);
  }

  Future<void> addButton(BasicButtonController but) async {
    await _local.addButton(but.button);
    await _upload(but.button.runtimeType);
  }

  Future<List<t>> _getButtons<t extends BasicButton>() async {
    return _local.getItems<t>();
  }

  late final Map<Type, Future<List> Function()> _fileToGet = {
    AgainAmountController: () => _getButtons<AgainAmountDay>(),
    AgainWeekController: () => _getButtons<AgainWeekDay>(),
    AgainYearController: () => _getButtons<AgainYearDay>(),
    AgainMonthController: () => _getButtons<AgainMonthDay>(),
    DeadlineController: () => _getButtons<Deadline>(),
    NoteController: () => _getButtons<BasicButton>(),
  };

  Future<List<t>> getButtons<t extends BasicButtonController>() async {
    return (await _fileToGet[t]!())
        .map((e) => Loading.buttonToController[t]!(e) as t)
        .toList();
  }

  Future<void> _upload(Type t) async {
    if (!typeList.contains(t)) {
      throw FormatException('Type: ${t.toString()} is not found');
    }
    if (uploader.contains(t)) {
      return;
    }
    uploader.add(t);
    await Future.delayed(const Duration(milliseconds: 10));
    await _client.uploadFile('${t.toString()}.byd');
    uploader.remove(t);
  }

  Future<void> downloadDatabaseFiles() async {
    List<Future> results = [];
    for (var type in typeList) {
      results.add(_client.downloadFile('${type.toString()}.byd'));
    }
    for (var download in results) {
      await download;
    }
  }

  Future<List<EndBasedController>> getEndBasedButtons() async {
    List<Future<Iterable<EndBasedController>>> getButtonList = [];
    List<EndBasedController> results = [];
    getButtonList.add(getButtons<DeadlineController>());
    getButtonList.add(getButtons<AgainAmountController>());
    getButtonList.add(getButtons<AgainYearController>());
    getButtonList.add(getButtons<AgainWeekController>());
    getButtonList.add(getButtons<AgainMonthController>());
    for (var toAwait in getButtonList) {
      results.addAll((await toAwait));
    }
    return results;
  }

  static final Map<Type, BasicButtonController Function(BasicButton)>
      buttonToController = {
    AgainAmountController: (button) =>
        AgainAmountController(button as AgainAmountDay),
    AgainWeekController: (button) =>
        AgainWeekController(button as AgainWeekDay),
    AgainYearController: (button) =>
        AgainYearController(button as AgainYearDay),
    AgainMonthController: (button) =>
        AgainMonthController(button as AgainMonthDay),
    DeadlineController: (button) => DeadlineController(button as Deadline),
    NoteController: (button) => NoteController(button),
  };

  Future<bool> downloadDatabaseFilesCarefully() async {
    List<Future> results = [];
    bool update = true;
    for (var type in typeList) {
      results.add(_client
          .downloadFileCarefully('${type.toString()}.byd',
              '${type.toString()}.backup.byd')
          .then((value) => {
                results.add(_local.shouldKeepFirstFile('${type.toString()}.byd',
                    '${type.toString()}.backup').then((value) => value ? update = false : update = update))
              }));
    }
    for (var download in results) {
      await download;
    }
    return update;
  }
}
