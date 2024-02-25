import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';

import '../../../Commons/Models/Buttons/skippable_button.dart';
import '../../my_date_controller.dart';
import 'end_based_controller.dart';

class AgainWeirdController extends SkippableEndBasedController<AgainWeird> {
  AgainWeirdController(super.button);

  @override
  SkippableEndBasedController<SkippableButton> callConstructor(button) =>
      AgainWeirdController(button);

  @override
  void create() {
    dateController = getDateFromMonth(MyDateController.today.year,
        MyDateController.today.month, MyDateController.today.day);
  }

  MyDateController getDateFromMonth(int year, int month, int checkFrom) {
    var firstDate = MyDateController(year, month, 1);
    var nextWeekday =
        firstDate.add(Duration(days: (day - firstDate.weekday) % 7 + day - (day % 7)));
    if (nextWeekday.day <= checkFrom) {
      return getDateFromMonth(nextWeekday.year, month + 1, 0);
    }
    return nextWeekday;
  }

  @override
  bool isLastTime() {
    return endingDate != null &&
        endingDate!.isBefore(getDateFromMonth(
            dateController.year, dateController.month, dateController.day + 1));
  }

  @override
  bool isHappeningOnDayFromNow(int calculatedDay) {
    var date = MyDateController.fromDaysFromNow(calculatedDay);
    if (date.weekday != day % 7) return false;
    var nextDate = getDateFromMonth(date.year, date.month, date.day - 1);
    return MyDateController.aboutEqual(date, nextDate);
  }

  @override
  MyDateController getNextTime(MyDateController? thisTimeDate) {
    return getDateFromMonth(thisTimeDate!.year, thisTimeDate.month, thisTimeDate.day);
  }
}
