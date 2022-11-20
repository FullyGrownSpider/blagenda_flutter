import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

class DeadlineController extends EndBasedController<Deadline> {

  DeadlineController(Deadline button) : super(button);

  @override
  void create() {
    dateController = button.date;
    requiresChange = button.date
        .isBefore(MyDateController.nowDate.add(const Duration(days: -2)));
  }
}
