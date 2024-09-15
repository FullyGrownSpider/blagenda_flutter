import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'basic_button.dart';

abstract class SkippableButton extends BasicButton {
  SkippableButton(
      [super.job,
      super.toDos,
      super.id,
      super.color,
      this.day,
      this.dateToSkip,
      this.endingDate,
      this.startDate,
      this.dates,
      bool important = false]);

  int? day;
  MyDateController? dateToSkip;
  MyDateController? endingDate;
  MyDateController? startDate;
  Map<MyDateController, List<int>>? dates;
}
