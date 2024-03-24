import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';

mixin Export {
  String addDashes(String path) {
    var dashes = '/';
    if (!path.contains(dashes)) {
      dashes = '\\';
    }
    return path + dashes;
  }

  Future<void> saveInStorage(List<String> buttons) async {
    if (!await hasPermission()) {
      return;
    }
    var folder = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String localPath = '${addDashes((folder))}allYouData.byd';

    File fileDef = File(localPath);
    await fileDef.create(recursive: true);
    await fileDef.writeAsString(buttons.join('\n'));
  }

  Future<String> loadFromInStorage() async {
    if (!await hasPermission()) {
      return '';
    }
    var folder = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String localPath = '${addDashes((folder))}allYouData.byd';

    File fileDef = File(localPath);
    if (!fileDef.existsSync()) return '';
    return fileDef.readAsString();
  }

  Future<bool> hasPermission() async {
    return !await Permission.manageExternalStorage.isRestricted;
  }
}
