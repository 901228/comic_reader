import 'dart:io';

import 'package:comic_reader/add_page/paths.dart';
import 'package:comic_reader/fileViewer_page/fileViewer.dart';
import 'package:comic_reader/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Directory> rootPath;

  final bool isDesktop = !(Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    rootPath = await getPaths();
    context
        .read(storageStatusProvider)
        .setDirectories(StorageDirectory.INTERNAL_DIRECTORY, rootPath[0]);
    context
        .read(storageStatusProvider)
        .setDirectories(StorageDirectory.EXTERNAL_DIRECTORY, rootPath[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Folder list',
            style: GoogleFonts.comfortaa(),
          ),
        ),
        bottomNavigationBar: Container(
          height: kToolbarHeight,
          child: MaterialButton(
            color: Colors.white,
            textColor: Colors.blue,
            child: Icon(
              Icons.add,
              size: kToolbarHeight * 0.6,
            ),
            onPressed: () async {
              await selectStorage(context).then((value) async {
                Navigator.pushNamed(
                  context,
                  '/fileViewer',
                  arguments: {
                    "rootDirectory": watch(storageStatusProvider).nowDirectory,
                    "showFsType": FileSystemType.ALL,
                    "selectableFsType": FileSystemType.FOLDER,
                  },
                ).then((value) {
                  context.read(fileViewerProvider).disposeNowDirectory();

                  if (value != null) {
                    context
                        .read(filePathProvider)
                        .addNewDirectory(value as Directory);
                  }
                });
              });
            },
          ),
        ),
        body: ListView.builder(
            itemCount: watch(filePathProvider).directories.length,
            itemBuilder: (context, index) {
              final nowDirectory =
                  watch(filePathProvider).directories.elementAt(index);
              return Slidable(
                direction: Axis.horizontal,
                startActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        context
                            .read(filePathProvider)
                            .deleteDirectory(nowDirectory);
                      },
                      icon: Icons.delete,
                      label: "Delete",
                      autoClose: true,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    )
                  ],
                  extentRatio: 0.2,
                ),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        context
                            .read(filePathProvider)
                            .deleteDirectory(nowDirectory);
                      },
                      icon: Icons.delete,
                      label: "delete",
                      autoClose: true,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    )
                  ],
                  extentRatio: 0.2,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/fileViewer',
                      arguments: {
                        "rootDirectory": nowDirectory,
                        "showFsType": FileSystemType.ALL,
                        "selectableFsType": FileSystemType.IMAGE,
                      },
                    ).then((value) {
                      context.read(fileViewerProvider).disposeNowDirectory();

                      if (value != null) {
                        final Directory _nowDirectory = (value as File).parent;

                        var list = _nowDirectory.listSync();
                        list.removeWhere((e) =>
                            (e is! File || !PhotoSliderProc.isImage(e.path)));
                        list.sort((a, b) => a.path.compareTo(b.path));

                        if (list.length != 0) {
                          context.read(photoSliderProvider).init(list
                              .indexWhere((e) => e.path == value.path)
                              .toDouble());

                          Navigator.pushNamed(
                            context,
                            '/viewer',
                            arguments: {
                              "nowDirectory": _nowDirectory,
                              "maxPage": list.length.toDouble(),
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Error"),
                              content: Text(
                                  "There is not any images in this folder."),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK")),
                              ],
                            ),
                          );
                        }
                      }
                    });
                  },
                  title: Text(watch(filePathProvider)
                      .directories
                      .elementAt(index)
                      .path),
                ),
              );
            }),
      );
    });
  }

  int getDBLength(BuildContext context) {
    context.read(filePathProvider).init();
    return context.read(filePathProvider).directories.length;
  }
}
