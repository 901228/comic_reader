import 'dart:async';
import 'dart:io';

import 'package:comic_reader/backButton.dart';
import 'package:comic_reader/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as Pa;

final ChangeNotifierProvider<FileViewerProvider> fileViewerProvider =
    ChangeNotifierProvider((_) => FileViewerProvider());

class FileViewerProvider extends ChangeNotifier {
  Directory? _nowDirectory;

  Directory? get nowDirectory => _nowDirectory;

  void initNowDirectory(Directory? initDirectory) {
    _nowDirectory ??= initDirectory;
  }

  void setNowDirectory(Directory? newDirectory) {
    _nowDirectory = newDirectory;
    notifyListeners();
  }

  void disposeNowDirectory() {
    _nowDirectory = null;
  }
}

enum FileSystemType { ALL, FOLDER, IMAGE }

class FileViewer extends StatelessWidget {
  final Directory rootDirectory;
  final FileSystemType showFsType;
  final FileSystemType selectableFsType;

  FileViewer(
      {required this.rootDirectory,
      required this.showFsType,
      required this.selectableFsType});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      watch(fileViewerProvider).initNowDirectory(rootDirectory);
      Directory? nowDirectory = watch(fileViewerProvider).nowDirectory;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            nowDirectory!.path,
            style: GoogleFonts.comfortaa(),
          ),
          leading: MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              backIconData(Theme.of(context).platform),
              color: Colors.white,
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: kToolbarHeight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context, nowDirectory);
            },
            child: Text('Choose this folder'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => Theme.of(context).appBarTheme.backgroundColor),
              foregroundColor: MaterialStateProperty.resolveWith(
                  (states) => Theme.of(context).appBarTheme.foregroundColor),
            ),
          ),
        ),
        body: FutureBuilder(
            future: _dirContents(nowDirectory, showFsType),
            builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
              if (snapshot.hasData) {
                bool isRoot =
                    nowDirectory.absolute.path == rootDirectory.absolute.path;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length + (isRoot ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (!isRoot && index == 0)
                      return ListTile(
                        onTap: () {
                          context.read(fileViewerProvider).setNowDirectory(
                              Directory((nowDirectory.path
                                      .split(Platform.pathSeparator)
                                        ..removeLast())
                                  .join(Platform.pathSeparator)));
                        },
                        title: Text('..'),
                        leading: Icon(Icons.arrow_upward),
                      );
                    return ListTile(
                      onTap: () {
                        if (snapshot.data!.elementAt(index - (isRoot ? 0 : 1))
                            is Directory)
                          context.read(fileViewerProvider).setNowDirectory(
                              snapshot.data!.elementAt(index - (isRoot ? 0 : 1))
                                  as Directory);
                        if ((selectableFsType == FileSystemType.ALL ||
                                selectableFsType == FileSystemType.IMAGE) &&
                            PhotoSliderProc.isImage(snapshot.data!
                                .elementAt(index - (isRoot ? 0 : 1))
                                .path)) {
                          Navigator.pop(
                              context,
                              snapshot.data!
                                  .elementAt(index - (isRoot ? 0 : 1)));
                        }
                      },
                      title: Text(Pa.basename(snapshot.data!
                          .elementAt(index - (isRoot ? 0 : 1))
                          .path)),
                      leading: fileIcon(
                          snapshot.data!.elementAt(index - (isRoot ? 0 : 1))),
                    );
                  },
                );
              } else
                return const Center(
                  child: const CircularProgressIndicator(),
                );
            }),
      );
    });
  }

  Future<List<FileSystemEntity>> _dirContents(
      Directory? rootDirectory, FileSystemType fsType) {
    var files = <FileSystemEntity>[];
    var completer = new Completer<List<FileSystemEntity>>();
    var lister = rootDirectory?.list(recursive: false);
    lister?.listen(
      (file) {
        final mimeType = lookupMimeType(file.path);

        if (fsType == FileSystemType.ALL)
          files.add(file);
        else if (fsType == FileSystemType.FOLDER && file is Directory)
          files.add(file);
        else if (fsType == FileSystemType.IMAGE &&
            mimeType!.startsWith('image/')) files.add(file);
      },
      onDone: () {
        files.sort((a, b) => a.path.compareTo(b.path));
        completer.complete(files);
      },
    );
    return completer.future;
  }

  Icon fileIcon(FileSystemEntity fs) {
    if (fs is Directory)
      return Icon(
        Icons.folder,
        color: Colors.teal,
      );
    else {
      final mimeType = lookupMimeType(fs.path);

      if (mimeType?.startsWith('image/') ?? false)
        return Icon(
          Icons.photo,
          color: Colors.pink,
        );

      return Icon(Icons.text_snippet);
    }
  }
}

Future selectStorage(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("Internal Storage"),
              onTap: () {
                context
                    .read(storageStatusProvider)
                    .changeDirectory(StorageDirectory.INTERNAL_DIRECTORY);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("External Storage"),
              onTap: () {
                context
                    .read(storageStatusProvider)
                    .changeDirectory(StorageDirectory.EXTERNAL_DIRECTORY);
                Navigator.pop(context);
              },
            ),
          ],
          shrinkWrap: true,
        ),
      ),
    ),
  );
}
