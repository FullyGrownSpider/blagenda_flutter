import 'dart:io';

import 'package:external_path/external_path.dart';

String _addDashes(String path) {
  var dashes = '/';
  if (!path.contains(dashes)) {
    dashes = '\\';
  }
  return path + dashes;
}

Future<void> saveInStorage(List<String> buttons) async {
  var folder = await getPath_2();
  String localPath = '${_addDashes((folder))}allYouData.byd';

  File fileDef = File(localPath);
  await fileDef.create(recursive: true);
  await fileDef.writeAsString(buttons.join('\n'));
}

Future<String> loadFromInStorage() async {
  var folder = await getPath_2();
  String localPath = '${_addDashes((folder))}allYouData.byd';

  File fileDef = File(localPath);
  if (!fileDef.existsSync()) return '';
  return fileDef.readAsString();
}

// To get public storage directory path
Future<String> getPath_2() async {
  return await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOCUMENTS);
}