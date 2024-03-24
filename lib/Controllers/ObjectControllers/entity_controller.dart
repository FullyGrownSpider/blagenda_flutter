import 'dart:ui';

import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/mix_search_able.dart';

import '../../Commons/Models/entity.dart';
import '../../Commons/store_able.dart';
import '../../common_items.dart';
import '../ScreensControllers/mix_input_handler.dart.dart';
import 'ButtonControllers/basic_button_controller.dart';

class EntityController extends SearchAble {
  Entity myEntity;

  List<Tag> get tags => myEntity.tags!;

  @override
  int get id => myEntity.id!;

  EntityController(this.myEntity);

  ///changes the tags to a list with the reference objects
  void tagsAsReferences() {
    if (tags.any((e) => e.data is TagObjectReference)) return;
    Iterable<Tag> copyTag = tags.map((e) {
      Tag nT = Tag(e.name, e.data);
      if (e.data is BasicButtonController || e.data is EntityController) {
        nT.data = TagObjectReference(e.data.runtimeType.toString(), e.data.id);
      }
      return nT;
    });
    myEntity.tags = copyTag.toList(growable: false);
  }

  ///changes the tags to a list with the actual objects
  void tagsToObjects(List<BasicButtonController> buttons) {
    if (tags.any((e) => e.data is StoreAble)) return;
    myEntity.tags = tags.map((e) {
      Tag nT = Tag(e.name, e.data);
      if (nT.data is TagObjectReference) {
        nT.data = buttons.firstWhere(
            (ee) => ee.id == nT.data.itd && ee.runtimeType.toString() == nT.data.type);
      }
      return nT;
    }).toList();
  }

  static String getNickname(dynamic tagToUse) {
    var value = StringBuffer();
    if (tagToUse is EntityController) {
      value.write(getNickname(tagToUse.tags.first));
    } else if (tagToUse is BasicButtonController) {
      value.write(tagToUse.gettingTheStringShort());
    } else {
      value.write(tagToUse.data);
    }
    return value.toString();
  }

  @override
  int searchHere(SearchTypes searchType, dynamic value) {
    if (searchType == SearchTypes.date) {
      return dateSearch(this, value);
    }
    if (searchType == SearchTypes.tag) {
      return tagSearch(this, value);
    }
    return 0;
  }

  @override
  List<SearchTypes> possibleSearches() {
    return [SearchTypes.tag, SearchTypes.date];
  }

  @override
  String searchDisplay() {
    return getNickname(tags.first);
  }

  static int tagSearch(EntityController item, List<String> text) {
    int total = 0;
    for (Tag t in item.tags) {
      if (text.last.isNotEmpty) {
        total += 10 *
            text.last
                .split('\n')
                .where((text) => getNickname(t).toLowerCase().contains(text.trim()))
                .length;
      }
      if (text.first.isNotEmpty) {
        total += 5 *
            text.first
                .split('\n')
                .where((text) => t.name!.toLowerCase().contains(text.trim()))
                .length;
      }
    }
    return total;
  }

  static int dateSearch(EntityController item, DateRange range) {
    int total = 0;
    for (Tag t in item.tags.where((tag) => tag.data is EndBasedController)) {
      EndBasedController data = t.data;
      total += data.searchHere(SearchTypes.date, range);
    }
    return total;
  }

  @override
  Color displayColor() => usedColors.first;

  @override
  bool shouldShowWhenStarting() => false;
}
