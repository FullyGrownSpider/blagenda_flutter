import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Loading/dropbox_client.dart';
import 'package:blagenda_flutter_simple/Loading/loading_storage.dart';

import '../Commons/Models/entity.dart';
import '../Commons/store_able.dart';
import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'conversion_base.dart';

mixin loading {
  static const DropboxClient _client = DropboxClient();
  static const LoadingFromStorage _local = LoadingFromStorage();
  static final List<Type> _uploader = [];

  Future<bool> deleteButton(BasicButtonController but) async {
    if ((await _local.getItems(Entity)).any((ent) => _searchFactorButton(ent, but))) {
      return false;
    }
    await _local.deleteItem(but.button);
    await _upload(but.button.runtimeType);
    return true;
  }

  Future<void> deleteButtons(List<BasicButtonController> buts) async {
    if (buts.isEmpty) return;
    var entities = await _local.getItems(Entity);
    buts.removeWhere((but) => _searchFactorButton(entities.join('\n'), but));
    if (buts.isEmpty) return;
    await _local.deleteItems(buts.map((e) => e.button).toList());
    await _upload(buts.first.button.runtimeType);
  }

  Future<void> updateData(StoreAble but) async {
    await _local.updateItem(but);
    await _upload(but.runtimeType);
  }

  Future<void> updateButtons(List<BasicButtonController> buts) async {
    if (buts.isEmpty) return;
    await _local.updateItems(buts.map((e) => e.button).toList());
    await _upload(buts.first.button.runtimeType);
  }

  Future<void> storeData(StoreAble but) async {
    await _local.addItem(but);
    await _upload(but.runtimeType);
  }

  Future<List<t>> _getButtons<t extends StoreAble>() async {
    return (await _local.getItems(t)).map((e) => importGenerator<t>(e)).toList();
  }

  Future<void> deleteEntity(
      EntityController toDelete, List<EntityController> controllerList) async {
    if (_searchFactorEntity(toDelete, controllerList).isNotEmpty) return;
    await _local.deleteItem(toDelete.myEntity);
    await _upload(Entity);
  }

  Future<List<dynamic>> getData<t extends StoreAble>() async {
    return ((await _getButtons<t>()).map((e) => dataToController(e)).toList());
  }

  Future<void> _upload(Type t) async {
    if (_uploader.contains(t)) {
      return;
    }
    _uploader.add(t);
    await Future.delayed(const Duration(milliseconds: 10));
    await _client.uploadFile(typeToFile(t));
    _uploader.remove(t);
  }

  Future<void> downloadDatabaseFiles() async {
    List<Future> results = [];
    for (var type in typeList) {
      results.add(_client.downloadFile(typeToFile(type)));
    }
    for (var download in results) {
      await download;
    }
  }

  Future<bool> downloadDatabaseFilesCarefully() async {
    List<Future> results = [];
    bool update = true;
    for (var type in typeList) {
      results.add(_client
          .downloadFileCarefully(typeToFile(type), '${typeToFile(type)}.backup')
          .then((value) => {
                results.add(_local
                    .shouldKeepFirstFile(typeToFile(type), '${typeToFile(type)}.backup')
                    .then((value) => value ? update = false : update = update))
              }));
    }
    for (int i = 0; i < results.length; i++) {
      await results[i];
    }
    if (!update) {
      results.clear();
      for (var type in typeList) {
        await _client.uploadFile(typeToFile(type));
      }
      for (int i = 0; i < results.length; i++) {
        await results[i];
      }
    }
    return update;
  }

  List<EntityController> _searchFactorEntity(
      EntityController toFind, List<EntityController> controller) {
    return controller
        .where((ent) => ent.tags.any((e) =>
            (e.data is EntityController && e.data.id == toFind.id) ||
            (e.data is TagObjectReference &&
                e.data.indexInList == 'EntityController' &&
                e.data.itd == toFind.id)))
        .toList(growable: false);
  }

  bool _searchFactorButton(String line, BasicButtonController controller) =>
      line.contains(dataExportGenerator(
              TagObjectReference(controller.runtimeType.toString(), controller.id),
              StringBuffer(),
              '')
          .toString()
          .substring(1));
}
