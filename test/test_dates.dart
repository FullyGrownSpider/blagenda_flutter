import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> input = ['jan 2', '02 1', '2 1'];
List<String> relativeInput = ['1e', '5', '5+', 'ma', 'ma++'];

void main() {
  test('test normal input', testInput);
  test('test normal input with a year', testInputWYear);
  test('from now', testRelativeInput);
}

///this test will fail on january first
void testInput() {
  var defaultDate = MyDateController(MyDateController.today.year + 1, 1, 2);
  var jan = MyDateController.translate(input[0]);
  var rad = MyDateController.translate(input[1]);
  var norm = MyDateController.translate(input[2]);
  expect(defaultDate, jan);
  expect(defaultDate, rad);
  expect(defaultDate, norm);
}

void testInputWYear() {
  var defaultDate = MyDateController(MyDateController.today.year + 2, 1, 2);
  var jan = MyDateController.translate('${input[0]} ${MyDateController.today.year + 2}');
  var rad = MyDateController.translate('${input[1]} ${MyDateController.today.year + 2}');
  var norm = MyDateController.translate('${input[2]} ${MyDateController.today.year + 2}');
  expect(defaultDate, jan);
  expect(defaultDate, rad);
  expect(defaultDate, norm);
}

void testRelativeInput() {
  var ord = MyDateController.translate(relativeInput[0]);
  var fromNow = MyDateController.translate(relativeInput[1]);
  var fromNowAndWeek = MyDateController.translate(relativeInput[2]);
  var fromNowMondayNext = MyDateController.translate(relativeInput[3]);
  var fromNowMondayNextInTwoWeeks = MyDateController.translate(relativeInput[4]);
  expect(1, ord!.day);
  expect(5, fromNow!.daysLeftUntil());
  expect(12, fromNowAndWeek!.daysLeftUntil());
  expect(1, fromNowMondayNext!.weekday);
  expect(1, fromNowMondayNextInTwoWeeks!.weekday);
  expect(true, fromNowMondayNextInTwoWeeks.daysLeftUntil() >= 14);
}
