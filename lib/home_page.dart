import 'dart:io';

import 'package:comic_reader/add_page/paths.dart';
import 'package:comic_reader/backButton.dart';
import 'package:comic_reader/fileViewer_page/fileViewer.dart';
import 'package:comic_reader/providers.dart';
import 'package:comic_reader/viewer_page/viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as Pa;

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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                _FileViewCus(nowDirectory: nowDirectory)));
                    // Navigator.pushNamed(
                    //   context,
                    //   '/fileViewer',
                    //   arguments: {
                    //     "rootDirectory": nowDirectory,
                    //     "showFsType": FileSystemType.ALL,
                    //     "selectableFsType": FileSystemType.IMAGE,
                    //   },
                    // ).then((value) {
                    //   context.read(fileViewerProvider).disposeNowDirectory();

                    //   if (value != null) {
                    //     final Directory _nowDirectory = (value as File).parent;

                    //     var list = _nowDirectory.listSync();
                    //     list.removeWhere((e) =>
                    //         (e is! File || !PhotoSliderProc.isImage(e.path)));
                    //     list.sort((a, b) => a.path.compareTo(b.path));

                    //     if (list.length != 0) {
                    //       context.read(photoSliderProvider).init(list
                    //           .indexWhere((e) => e.path == value.path)
                    //           .toDouble());

                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (_) => Viewer(
                    //                   nowDirectory: _nowDirectory,
                    //                   maxPage: list.length.toDouble())));
                    //     } else {
                    //       showDialog(
                    //         context: context,
                    //         builder: (context) => AlertDialog(
                    //           title: Text("Error"),
                    //           content: Text(
                    //               "There is not any images in this folder."),
                    //           actions: [
                    //             TextButton(
                    //                 onPressed: () {
                    //                   Navigator.pop(context);
                    //                 },
                    //                 child: Text("OK")),
                    //           ],
                    //         ),
                    //       );
                    //     }
                    //   }
                    // });
                  },
                  title: Text(Pa.basename(nowDirectory.path)),
                  subtitle: Text(nowDirectory.path),
                  leading: fileIcon(nowDirectory),
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

class _FileViewCus extends StatelessWidget {
  const _FileViewCus({required this.nowDirectory});

  final Directory nowDirectory;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      watch(fileViewerProvider).initNowDirectory(nowDirectory);
      Directory? _nowDirectory = watch(fileViewerProvider).nowDirectory;
      bool isRoot = _nowDirectory!.absolute.path == nowDirectory.absolute.path;

      return WillPopScope(
        onWillPop: () async {
          if (isRoot)
            return true;
          else {
            context.read(fileViewerProvider).setNowDirectory(Directory(
                (_nowDirectory.path.split(Platform.pathSeparator)..removeLast())
                    .join(Platform.pathSeparator)));

            return false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Container(
              alignment: Alignment.centerLeft,
              child: isRoot
                  ? Text(
                      Pa.basename(_nowDirectory.path),
                      style: GoogleFonts.comfortaa(),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Pa.relative(_nowDirectory.parent.path,
                                      from: nowDirectory.parent.path)
                                  .replaceAll("/", " > ") +
                              " >",
                          style: GoogleFonts.comfortaa(
                              fontSize: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .fontSize! *
                                  0.8),
                        ),
                        Text(
                          Pa.basename(_nowDirectory.path),
                          style: GoogleFonts.comfortaa(),
                        ),
                      ],
                    ),
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
          body: FutureBuilder(
              future: dirContents(_nowDirectory, FileSystemType.ALL),
              builder:
                  (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                if (snapshot.hasData) {
                  List<FileSystemEntity>? data = snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data!.length + (isRoot ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (!isRoot && index == 0) {
                        return ListTile(
                          onTap: () {
                            context.read(fileViewerProvider).setNowDirectory(
                                Directory((_nowDirectory.path
                                        .split(Platform.pathSeparator)
                                          ..removeLast())
                                    .join(Platform.pathSeparator)));
                          },
                          title: Text('..'),
                          leading: Icon(Icons.arrow_upward),
                        );
                      } else {
                        FileSystemEntity nowData =
                            data[index - (isRoot ? 0 : 1)];
                        return ListTile(
                          onTap: () {
                            if (nowData is Directory)
                              context
                                  .read(fileViewerProvider)
                                  .setNowDirectory(nowData);
                            if (PhotoSliderProc.isImage(nowData.path)) {
                              context
                                  .read(fileViewerProvider)
                                  .disposeNowDirectory();

                              final Directory _nowDirectory =
                                  (nowData as File).parent;

                              var list = _nowDirectory.listSync();
                              list.removeWhere((e) => (e is! File ||
                                  !PhotoSliderProc.isImage(e.path)));
                              list.sort((a, b) {
                                final ia = double.tryParse(Pa.basename(a.path));
                                final ib = double.tryParse(Pa.basename(b.path));
                                if (ia != null && ib == null)
                                  return -1;
                                else if (ia == null && ib != null)
                                  return 1;
                                else if (ia != null && ib != null) {
                                  return ia.compareTo(ib);
                                } else
                                  return Pa.basename(a.path)
                                      .compareTo(Pa.basename(b.path));
                              });

                              if (list.length != 0) {
                                context.read(photoSliderProvider).init(list
                                    .indexWhere((e) => e.path == nowData.path)
                                    .toDouble());

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => Viewer(
                                            nowDirectory: _nowDirectory,
                                            maxPage: list.length.toDouble())));
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
                          },
                          title: Text(Pa.basename(nowData.path)),
                          leading: fileIcon(nowData),
                        );
                      }
                    },
                  );
                } else
                  return const Center(
                    child: const CircularProgressIndicator(),
                  );
              }),
        ),
      );
    });
  }
}
