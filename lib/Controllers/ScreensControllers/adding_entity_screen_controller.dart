import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_day_creator.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';

import '../../Commons/Models/entity.dart';
import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../blagenda_uniform_button.dart';
import 'mix_button_creator.dart';
import 'mix_input_handler.dart.dart';

class AddingEntityScreenController with buttonCreator, dayCreator, inputHandler {
  late InputObject _nextName;
  late InputObject _nextAddButton;

  final void Function() _setStateMethod;

  EntityController? Function()? getEntity;
  late int _id;
  final int Function() _getNewId;
  final List<TagCreateInfo> _info = [];
  final Map<String, dynamic> _storedValues = {};

  static const String _tagListText = 'Tag type', _newNameText = 'New tag name';

  static void _doNothing() {}
  final Future<dynamic> Function(Future<dynamic> Function(dynamic)) _openButtonSearch;

  final List<EntityController> _entities;

  final List<BasicButtonController<BasicButton>> _buttons;

  final Future<dynamic> Function(dynamic) _openButtonEdit;

  AddingEntityScreenController(
      EntityController? entity,
      this._getNewId,
      this._setStateMethod,
      this._entities,
      this._buttons,
      this._openButtonSearch,
      this._openButtonEdit) {
    if (entity == null) {
      _fillStoredValuesNoEntity();
    } else {
      entity.tagsToObjects(_buttons);
      _fillStoredValues(entity);
      _id = entity.id;
    }
    Set<String> names = {};
    for (entity in _entities) {
      names.addAll(entity.tags.map((e) => e.name!));
    }
    _nextName = itemForStringAutoComplete('', _newNameText, _storedValues, _doNothing,
        'n', names.toList(growable: false), _setStateMethod);
    _nextAddButton = itemForIntFromList(
        types, _tagListText, 'o', _storedValues, _addNewTag, _doNothing);
  }

  void _fillStoredValuesNoEntity() {
    _storedValues['0'] = '';
    _storedValues['n0'] = 'Nickname';
    var inputObject =
        itemForString(_storedValues['0'], 'Description', _storedValues, _doNothing, '0');
    _info.add(TagCreateInfo(
        0, //only one item
        inputObject,
        BlagendaUniformButton(
            false, usedColors.first, _storedValues['n0'], () => _setStateAndDelete(0)),
        _storedValues['n0'],
        0));
    _id = -1;
  }

  //try to call this only once
  void _fillStoredValues(EntityController entity) {
    for (int i = 0; i < entity.tags.length; i++) {
      int type;
      InputObject inputObject;
      if (entity.tags[i].data is String) {
        if (entity.tags[i].data.contains('\n')) {
          type = 1;
          inputObject = itemForStringList(entity.tags[i].data, 'Description',
              i.toString(), _doNothing, _storedValues);
        } else {
          type = 0;
          inputObject = itemForString(entity.tags[i].data, 'Description', _storedValues,
              _doNothing, i.toString());
        }
      } else if (entity.tags[i].data is BasicButtonController) {
        _storedValues[i.toString()] = entity.tags[i].data;
        type = 2;
        inputObject = itemForReferenceAbleList(
            i.toString(),
            _storedValues,
            () => _openButtonSearch((item) => _fillInputItem(item, i)),
            EntityController.getNickname);
      } else {
        throw UnimplementedError('Unkown Type requested');
      }
      _storedValues['n$i'] = entity.tags[i].name!;
      _info.add(TagCreateInfo(
          i,
          inputObject,
          BlagendaUniformButton(
              false, usedColors.first, _storedValues['n$i'], () => _setStateAndDelete(i)),
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
              border: Border(bottom: BorderSide(color: usedColors.first, width: 3))),
          child: item.destinedInput.displayWidget)));
      widgetList.add(smallBlankSplit);
    }
    widgetList.add(splitterTextField);
    widgetList.add(_nextName.displayWidget);
    widgetList.add(_nextAddButton.displayWidget);
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
        _id = _getNewId();
      }
      var myEntity = Entity(tagList, _id);
      return EntityController(myEntity);
    };
    return widgetList;
  }

  Future<void> _addNewTag() async {
    final int toMake = _nextAddButton.getValue();
    final InputObject inputObject;
    final int i = _info.length;
    if (toMake == 3) {
      //a date
      _storedValues['$i'] = null;
      inputObject = itemForReferenceAbleList(
          i.toString(),
          _storedValues,
          () => _openButtonSearch((item) => _fillInputItem(item, i)),
          (b) => b.searchDisplay());
    } else if (toMake == 2) {
      //a long note
      _storedValues['$i'] = '';
      inputObject = itemForStringList(
          _storedValues['$i'], 'Description', i.toString(), _doNothing, _storedValues);
    } else {
      //a note
      _storedValues['$i'] = '';
      inputObject = itemForString(
          _storedValues['$i'], 'Description', _storedValues, _doNothing, i.toString());
    }
    if ((_storedValues['n'] ?? '') == '') {
      _storedValues['n$i'] = 'No name';
    } else {
      _storedValues['n$i'] = _storedValues['n'];
      //no text clear that is easy to reach so just rebuild it, who cares
      _nextName = itemForString('', _newNameText, _storedValues, _doNothing, 'n');
      _storedValues['n'] = '';
    }
    _info.add(TagCreateInfo(
        i,
        inputObject,
        BlagendaUniformButton(
            false, usedColors.first, _storedValues['n$i'], () => _setStateAndDelete(i)),
        _storedValues['n$i'],
        toMake));
    _setStateMethod();
  }

  Future<dynamic> _fillInputItem(BasicButtonController item, int i) async {
    _storedValues['$i'] = item;
    var inputObject = itemForReferenceAbleList(
        i.toString(),
        _storedValues,
        () => _openButtonSearch((item) => _fillInputItem(item, i)),
        EntityController.getNickname);
    _info[i].destinedInput = inputObject;
    _setStateMethod();
  }

  void _setStateAndDelete(int fromWhere) {
    if (_info[fromWhere].type == 3 && _storedValues[fromWhere.toString()] == null) {
      _openButtonEdit((t) {
        _fillInputItem(t, fromWhere);
        _setStateMethod();
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
          BlagendaUniformButton(
              false, usedColors.first, _storedValues['n$i'], () => _setStateAndDelete(i)),
          _storedValues['n$i'],
          _info[i].type));
    }
    _setStateMethod();
  }

  static const List<String> types = ['A Note', 'A Long Note', 'A Date'];
}

class TagCreateInfo {
  final int indexInList;

  final int type;
  final String name;
  InputObject destinedInput;
  final Widget nameDisplay;

  TagCreateInfo(
      this.indexInList, this.destinedInput, this.nameDisplay, this.name, this.type);
}
