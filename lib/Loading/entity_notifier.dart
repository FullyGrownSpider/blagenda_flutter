import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:flutter/material.dart';
import '../Commons/Models/entity.dart';
import 'button_notifier.dart';
import 'loading.dart';

class EntityNotifier
    with ChangeNotifier
    implements StoreAbleNotifier<EntityController> {
  final List<EntityController> _entities = [];

  final Loading _loading = Loading();

  Future<void> init() {
    return _loading.getData<Entity>().then((x) {
      _entities.addAll(x.whereType<EntityController>());
      notifyListeners();
    });
  }

  List<Tag> tagsUsable() => _entities
      .map((e) => e.tags.where((t) => t.data is! String).toList())
      .expand((element) => element)
      .toList(growable: false);

  @override
  void addOrUpdate(EntityController entity) {
    _entities.add(entity);
    _loading.updateData(entity);
    notifyListeners();
  }

  @override
  void delete(EntityController entity) {
    _entities.removeWhere(
        (e) => e.runtimeType == entity.runtimeType && e.id == entity.id);
    _loading.deleteEntity(entity, _entities);
    notifyListeners();
  }

  int getNewEntityId() {
    _entities.sort((a, b) => a.id.compareTo(b.id));
    for (int i = 0; i < _entities.length; i++) {
      if (_entities[i].id != i) {
        return i;
      }
    }
    return _entities.length;
  }

  @override
  List<EntityController> getData() => _entities;
}
