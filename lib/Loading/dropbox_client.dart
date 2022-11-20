import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DropboxClient {
  const DropboxClient();

  static const String _authorization =
      '_oLKcuUTDakAAAAAAAABrQAlMYVpE7etvPcrMd3lmKTxPdBRpuo1kP7xOoD7F_zF';

  static const String _folder = "Blagenda Simple";

  static Future<String> pathEr(String filename) async {
    var dir = await getApplicationDocumentsDirectory();
    var dashes = '/';
    if (!dir.path.contains(dashes)) {
      dashes = '\\';
    }
    return dir.path + dashes + filename;
  }

  Future<bool> downloadFile(String filename) async {
    var downloadURL =
        Uri.parse('https://content.dropboxapi.com/2/files/download');
    try {
      var file = File(await pathEr(filename));
      if (file.existsSync()) {
        file.deleteSync();
      }
      var client = http.Client();
      var response = await client.get(downloadURL, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + _authorization,
        "Dropbox-API-Arg":
            "{\"path\": \"/" + _folder + "/" + filename + ".txt\"}"
      });
      file.writeAsBytesSync(response.bodyBytes);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> uploadFile(String filename) async {
    var uploadURL = Uri.parse('https://content.dropboxapi.com/2/files/upload');
    try {
      var value = await File(await pathEr(filename)).readAsString();
      var valueC = utf8.encoder.convert(value);
      var client = http.Client();
      await client.post(uploadURL, body: valueC, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + _authorization,
        "Content-Type": "application/octet-stream",
        "Dropbox-API-Arg": "{\"path\": \"/" +
            _folder +
            "/" +
            filename +
            ".txt\", \"mode\": \"overwrite\"}"
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> createFolder() async {
    var folderURL =
        Uri.parse('https://api.dropboxapi.com/2/files/create_folder_v2');
    try {
      var client = http.Client();
      var body = json.encode({'path': '/' + _folder});
      await client.post(folderURL,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ' + _authorization,
            'Content-Type': 'application/json'
          },
          body: body);
    } catch (e) {
      //if folder can't be created then that's an issue but there is nothing we can do
    }
  }
}
