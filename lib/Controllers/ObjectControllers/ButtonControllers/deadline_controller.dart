import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

import 'end_based_controller.dart';

class DeadlineController extends EndBasedController<Deadline> {
  DeadlineController(super.button);

  @override
  void create() {
    dateController = button.date!;
    requiresChange =
        button.date!.isBefore(MyDateController.nowDate.add(const Duration(days: -3)));
  }

  @override
  void addOrRemoveDaysDo(int amount) =>
      button.date = button.date!.addOrRemoveDays(amount);
}
