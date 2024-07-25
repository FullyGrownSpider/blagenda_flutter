import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_day_creator.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';

import '../../Commons/Models/entity.dart';
import '../../Loading/entity_notifier.dart';
import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../blagenda_uniform_button.dart';
import 'mix_button_creator.dart';
import 'mix_input_handler.dart.dart';

class AddingEntityScreenController extends ChangeNotifier
    with ButtonCreator, DayCreator, InputHandler {
  late final InputObject<String, String> _nextName;
  late final InputObject<int, int> _nextAddButton;

  String nextName = '';
  late final EntityController? Function() getEntity;
  late int _id;
  final List<TagCreateInfo> _info = [];
  final Map<String, dynamic> _storedValues = {};

  static const String _tagListText = 'Tag type', _newNameText = 'New tag name';

  final Future<BasicButtonController> Function()
      _openButtonSearch;

  final ButtonNotifier _notifier;
  final EntityNotifier _entityNotifier;

  final Future<dynamic> Function(dynamic) _openButtonEdit;

  AddingEntityScreenController(EntityController? entity, this._entityNotifier,
      this._notifier, this._openButtonSearch, this._openButtonEdit) {
    if (entity == null) {
      _fillStoredValuesNoEntity();
    } else {
      entity.tagsToObjects(_notifier.getData());
      _fillStoredValues(entity);
      _id = entity.id;
    }
    Set<String> names = {};
    for (entity in _entityNotifier.getData()) {
      names.addAll(entity.tags.map((e) => e.name!));
    }
    _nextName = itemForStringAutoComplete(_newNameText, () => nextName,
        (s) => nextName = s, names.toList(growable: false));

    _nextAddButton = itemForIntFromList(types, _tagListText, () => -1, (s) {
      if (s == null) return;
      _addNewTag(s);
    }, false);

    getEntity = () {
      var tagList = <Tag>[];
      for (var item in _info) {
        var value = item.destinedInput.getValue();
        if (value == null) {
          //important value is not filled
          return null;
        }
        tagList.add(Tag(item.name, value));
      }
      if (_id == -1) {
        _id = _entityNotifier.getNewEntityId();
      }
      var myEntity = Entity(tagList, _id);
      return EntityController(myEntity);
    };
    notifyListeners();
  }

  void _fillStoredValuesNoEntity() {
    _storedValues['0'] = '';
    _storedValues['n0'] = 'Nickname';
    var inputObject = itemForString(
        'Description', () => _storedValues['0'], (s) => _storedValues['0'] = s);
    _info.add(TagCreateInfo(
        0, //only one item
        inputObject,
        BlagendaUniformButton(
            usedColors.first, () => _storedValues['n0'], () => _deleteTag(0)),
        _storedValues['n0'],
        0));
    _id = -1;
  }

  //try to call this only once
  void _fillStoredValues(EntityController entity) {
    for (int i = 0; i < entity.tags.length; i++) {
      int type;
      InputObject inputObject;
      _storedValues[i.toString()] = entity.tags[i].data;
      if (entity.tags[i].data is String) {
        if (entity.tags[i].data.contains('\n')) {
          type = 1;
          inputObject = itemForStringList(
              'Description',
                  () => _storedValues[i.toString()],
                  (s) => _storedValues[i.toString()] = s);
        } else {
          type = 0;
          inputObject = itemForString(
              'Description',
                  () => _storedValues[i.toString()],
                  (s) => _storedValues[i.toString()] = s);
        }
      } else if (entity.tags[i].data is BasicButtonController) {
        type = 2;
        inputObject = itemForReferenceAbleList(
            () => _storedValues[i.toString()],
            (s) => _storedValues[i.toString()] = s,
            () => _openButtonSearch().then((item) => _fillInputItem(item, i)),
            EntityController.getNickname);
      } else {
        throw UnimplementedError('Unkown Type requested');
      }
      _storedValues['n$i'] = entity.tags[i].name!;
      _info.add(TagCreateInfo(
          i,
          inputObject,
          BlagendaUniformButton(usedColors.first, () => _storedValues['n$i'],
              () => _deleteTag(i)),
          _storedValues['n$i'],
          type));
    }
  }

  List<Widget> createScreenWidgets() {
    List<Widget> widgetList = [];
    for (var item in _info) {
      widgetList.add(item.nameDisplay);
      widgetList.add(notQuiteFull(Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: usedColors.first, width: 3))),
          child: item.destinedInput.displayWidget)));
      widgetList.add(smallBlankSplit);
    }
    widgetList.add(splitterTextField);
    widgetList.add(_nextName.displayWidget);
    widgetList.add(_nextAddButton.displayWidget);
    return widgetList;
  }

  void _addNewTag(int toMake) {
    final InputObject inputObject;
    final int i = _info.length;
    if (toMake == 3) {
      //a date
      _storedValues['$i'] = null;
      inputObject = itemForReferenceAbleList(
          () => _storedValues[i.toString()],
          (s) => _storedValues[i.toString()] = s,
          () => _openButtonSearch().then((item) => _fillInputItem(item, i)),
          (b) => b.searchDisplay());
    } else if (toMake == 2) {
      //a long note
      _storedValues['$i'] = '';
      inputObject = itemForStringList(
          'Description',
          () => _storedValues[i.toString()],
          (s) => _storedValues[i.toString()] = s);
    } else {
      //a note
      _storedValues['$i'] = '';
      inputObject = itemForString(
          'Description',
          () => _storedValues[i.toString()],
          (s) => _storedValues[i.toString()] = s);
    }
    if (_nextName.getValue() == '') {
      _storedValues['n$i'] = 'No name';
    } else {
      _storedValues['n$i'] = _nextName.getValue();
      _nextName.setValue('');
    }
    _info.add(TagCreateInfo(
        i,
        inputObject,
        BlagendaUniformButton(
            usedColors.first, () => _storedValues['n$i'], () => _deleteTag(i)),
        _storedValues['n$i'],
        toMake));
    ();
    notifyListeners();
  }

  Future<dynamic> _fillInputItem(BasicButtonController item, int i) async {
    _storedValues['$i'] = item;
    var inputObject = itemForReferenceAbleList(
        () => _storedValues[i.toString()],
        (s) => _storedValues[i.toString()] = s,
        () => _openButtonSearch().then((item) => _fillInputItem(item, i)),
        EntityController.getNickname);
    _info[i].destinedInput = inputObject;
    notifyListeners();
  }

  void _deleteTag(int fromWhere) {
    if (_info[fromWhere].type == 3 &&
        _storedValues[fromWhere.toString()] == null) {
      _openButtonEdit((t) {
        _fillInputItem(t, fromWhere);
        ();
      }).then((value) => null);
      return;
    }
    //delete the tag combo from the list of name+data things
    _info.removeAt(fromWhere);
    //in stored values move it all back as if it is a list by changing the the "number" to one lower for all
    for (int i = fromWhere; i < _info.length; i++) {
      _storedValues[i.toString()] = _storedValues[(i + 1).toString()];
      _storedValues['n$i'] = _storedValues['n${i + 1}'];
    }
    _storedValues.removeWhere((key, value) => value == null);

    //change it so the tag items have the correct reference in to the stored values relating to their new int
    for (int i = 0; i < _info.length; i++) {
      _info[i] = (TagCreateInfo(
          i,
          _info[i].destinedInput,
          BlagendaUniformButton(usedColors.first, () => _storedValues['n$i'],
              () => _deleteTag(i)),
          _storedValues['n$i'],
          _info[i].type));
    }
    notifyListeners();
  }

  static const List<String> types = ['A Note', 'A Long Note', 'A Date'];
}

class TagCreateInfo {
  final int indexInList;

  final int type;
  final String name;
  InputObject destinedInput;
  final Widget nameDisplay;

  TagCreateInfo(this.indexInList, this.destinedInput, this.nameDisplay,
      this.name, this.type);
}
