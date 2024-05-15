import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/entity.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

///test weather loading of entities works fine (.loading class)
void main() {
  test('entity conversion', entityTest);
}

void entityTest() {
  var guyToTest = EntityController(Entity(tagList, 2));
  guyToTest.tagsAsReferences();
  var line = exportGenerator(guyToTest.myEntity);
  var newGuy = importGenerator<Entity>(line);
  var controller = EntityController(newGuy);
  controller.tagsToObjects(buttonList);
  expect(newGuy.tags!.length == tagList.length, true);
  for (int i = 0; i < tagList.length; i++) {
    expect(newGuy.tags![i].name == tagList[i].name, true);
    expect(newGuy.tags![i].data.runtimeType == tagList[i].data.runtimeType, true);
  }
}

List<BasicButtonController> buttonList = [
  DeadlineController(Deadline('', '', 1, usedColors.first, MyDateController.yesterday)),
  AgainYearController(AgainYearDay('', '', 1, usedColors.first, 13, 1)),
];

List<Tag> tagList = [
  Tag('string value', 'string'),
  Tag('deadline Value', buttonList[0]),
  Tag('againYear Value', buttonList[1]),
];
