import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/photo_deadline.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> input = ["jan 2", "02 1", "2 1"];
List<String> relativeInput = ["1e", "5", "5+", "ma", "ma++"];

void main() {
  test('test normal input', testInput);
  test('test normal input with a year', testInputWYear);
  test('from now', testRelativeInput);

  test('test normal input Photo', photoNormal);
  test('test normal numeric input Photo', photoNumeric);
  test('test normal numeric input with a year Photo', photoNumericYear);
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
  var jan = MyDateController.translate(
      "${input[0]} ${MyDateController.today.year + 2}");
  var rad = MyDateController.translate(
      "${input[1]} ${MyDateController.today.year + 2}");
  var norm = MyDateController.translate(
      "${input[2]} ${MyDateController.today.year + 2}");
  expect(defaultDate, jan);
  expect(defaultDate, rad);
  expect(defaultDate, norm);
}

void testRelativeInput() {
  var ord = MyDateController.translate(relativeInput[0]);
  var fromNow = MyDateController.translate(relativeInput[1]);
  var fromNowAndWeek = MyDateController.translate(relativeInput[2]);
  var fromNowMondayNext = MyDateController.translate(relativeInput[3]);
  var fromNowMondayNextInTwoWeeks =
      MyDateController.translate(relativeInput[4]);
  expect(1, ord!.day);
  expect(5, fromNow!.timeLeftUntil());
  expect(12, fromNowAndWeek!.timeLeftUntil());
  expect(1, fromNowMondayNext!.weekday);
  expect(1, fromNowMondayNextInTwoWeeks!.weekday);
  expect(true, fromNowMondayNextInTwoWeeks.timeLeftUntil() >= 14);
}

void photoNormal() {
  var one = createDateFromText("asfdjoasiejfpo october 10th");
  var two = createDateFromText("asfdjoasiejfpo 12! october 10th");
  var three = createDateFromText("asfdjoasiejfpo 10th october asefsef");
  var four = createDateFromText("asfdjoasiejfpo 2023 october 10 asefsef");
  var five =
      createDateFromText("asfd 23-11 joasiejfpo 2023 october 10 asefsef");

  expect(one, two);
  expect(three, four);
  expect(one, five);
  expect(one, four);
}

void photoNumeric() {
  var one = createDateFromText("asfdjoasiejfpo20-08");
  var two = createDateFromText("asfdjoasiejfpo08-20");
  var three = createDateFromText("asfdjoasiejfpo10-08");

  expect(one, two);
  expect(MyDateController.fromDM(10, 8), three);
}

void photoNumericYear() {
  var one = createDateFromText("asfdjoasiejfpo20-08-3040");
  var two = createDateFromText("asfdjoasiejfpo08-20-3040");
  var three = createDateFromText("asfdjoasiejfpo3040-20-08");
  var four = createDateFromText("asfdjoasiejfpo3040-08-20");

  var five = createDateFromText("asfdjoasiejfpo3040-10-08");
  var six = createDateFromText("asfdjoasiejfpo08-10-3040");

  expect(one, two);
  expect(three, four);
  expect(one, four);
  expect(five, six);
}
