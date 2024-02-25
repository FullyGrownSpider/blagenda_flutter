import 'package:blagenda_flutter_simple/Commons/store_able.dart';

class Entity extends StoreAble {
  List<Tag>? tags;

  Entity([this.tags, super.id]);
}

class Tag {
  String? name;
  dynamic data;

  Tag([this.name, this.data]);
}

//Used to indicate that there is a reference here
class TagObjectReference {
  String type;
  int itd;

  TagObjectReference(this.type, this.itd);
}
