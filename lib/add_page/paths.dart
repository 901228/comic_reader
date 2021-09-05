import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<List<Directory>> getPaths() async {
  List<Directory> directories;
  String interPath = "";
  String exterPath = "";
  List<Directory> result = <Directory>[];

  try {
    if (Platform.isAndroid && await Permission.storage.isPermanentlyDenied)
      openAppSettings();

    await Permission.storage.request().isGranted.then((value) async {
      if (value) {
        directories = await getExternalStorageDirectories() ?? <Directory>[];

        List<String> dirs = directories[0].toString().split('/');
        interPath = '/' + dirs[1] + '/' + dirs[2] + '/' + dirs[3];

        dirs = directories[1].toString().split('/');
        exterPath = '/' + dirs[1] + '/' + dirs[2];
      }
    });
  } catch (error) {
    print(error);
  }

  if (interPath.isNotEmpty) result.add(Directory(interPath));
  if (exterPath.isNotEmpty) result.add(Directory(exterPath));

  return result;
}
