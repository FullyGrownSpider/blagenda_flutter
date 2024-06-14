import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/entity.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_entity_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

import 'overview4test.dart';

void main() {
  test('entiteis testing', addEntities);
}

void addEntities() {
  var b1 = makeController(entit()).getEntity()!;
  expect(b1.tags.first.data == entit().tags.first.data, true);
  expect(b1.tags[1].data == entit().tags[1].data, true);
  expect(
      BasicButtonController.equals(
          b1.tags.last.data.button, entit().tags.last.data.button),
      true);
}

AddingEntityScreenController makeController(EntityController but) {
  final FakeEntityNotifier entityNotifier = FakeEntityNotifier();
  final FakeButtonNotifier notifier = FakeButtonNotifier(entityNotifier);
  var screen = AddingEntityScreenController(
      but, entityNotifier, notifier, () async {}, (_) async {});
  screen.createScreenWidgets();
  return screen;
}

EntityController entit() => EntityController(Entity([
      Tag('oi', 'whatsallthisthen'),
      Tag('oino', '1\n2\n3\n'),
      Tag('what the what', dead(1))
    ], 1));

DeadlineController dead(int numb) => DeadlineController(Deadline(
    "job$numb", "asfd\nasdf\nhaha\n", numb, usedColors.first, MyDateController.today));

List<BasicButtonController> possibleButtons = [dead(1)];
