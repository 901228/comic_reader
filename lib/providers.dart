import 'dart:io';

import 'package:comic_reader/add_page/directories_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

final ChangeNotifierProvider<StorageStatus> storageStatusProvider =
    ChangeNotifierProvider((_) => StorageStatus());

enum StorageDirectory { INTERNAL_DIRECTORY, EXTERNAL_DIRECTORY }

class StorageStatus extends ChangeNotifier {
  StorageDirectory nowDir = StorageDirectory.INTERNAL_DIRECTORY;

  List<Directory> directories =
      List<Directory>.filled(StorageDirectory.values.length, Directory(""));

  Directory get nowDirectory => directories[nowDir.index];

  void changeDirectory(StorageDirectory changeToDir) {
    if (nowDir != changeToDir) {
      nowDir = changeToDir;
      notifyListeners();
    }
  }

  void setDirectories(StorageDirectory sd, Directory dir) {
    directories[sd.index] = dir;
  }
}

final ChangeNotifierProvider<FilePath> filePathProvider =
    ChangeNotifierProvider((_) => FilePath());

class FilePath extends ChangeNotifier {
  Directory? _nowDir;
  List<Directory> _directories = [];
  bool isInit = false;

  FilePath() {
    init();
  }

  void init() async {
    _nowDir = await getApplicationDocumentsDirectory();
    _directories = await DirectoryDBHelpler.paths().then((value) {
      notifyListeners();
      return value;
    });
    isInit = true;
  }

  Directory? get nowDirectory => _nowDir;

  set nowDirectory(Directory? changeToDir) {
    if (_nowDir == null || _nowDir != changeToDir) {
      _nowDir = changeToDir;
      notifyListeners();
    }
  }

  void addNewDirectory(Directory newDir) {
    _directories.add(newDir);
    DirectoryDBHelpler.insert(newDir);
    DirectoryDBHelpler.update(newDir);
    notifyListeners();
  }

  void deleteDirectory(Directory dir) {
    _directories.remove(dir);
    DirectoryDBHelpler.delete(dir);
    DirectoryDBHelpler.update(dir);
    notifyListeners();
  }

  List<Directory> get directories => _directories;
}

final ChangeNotifierProvider<TapPosProc> tapPosProvider =
    ChangeNotifierProvider((_) => TapPosProc());

enum TapArea { RIGHT, MIDDLE, LEFT, NONE }

class TapPosProc extends ChangeNotifier {
  TapArea _tapDown = TapArea.NONE;
  TapArea _tapUp = TapArea.NONE;

  set tapDownArea(TapArea pos) {
    _tapDown = pos;
  }

  set tapUpArea(TapArea pos) {
    _tapUp = pos;
    if (_tapDown == _tapUp) notifyListeners();
  }

  TapArea isTap() {
    if (_tapDown == _tapUp)
      return _tapUp;
    else
      return TapArea.NONE;
  }
}

final ChangeNotifierProvider<PhotoSliderProc> photoSliderProvider =
    ChangeNotifierProvider((_) => PhotoSliderProc());

class PhotoSliderProc extends ChangeNotifier {
  double _nowPage = 0;

  double get nowPage => _nowPage;

  set nowPage(double newValue) {
    _nowPage = newValue;
    notifyListeners();
  }

  void init(double initPage) {
    _nowPage = initPage;
    _pageController.dispose();
    _pageController = PageController(initialPage: initPage.toInt());
  }

  PageController _pageController = PageController();

  PageController get pageController => _pageController;

  static bool isImage(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType?.startsWith('image/') ?? false;
  }
}

final ChangeNotifierProvider<AppBarVisibility> appBarVisibilityProvider =
    ChangeNotifierProvider((_) => AppBarVisibility());

class AppBarVisibility extends ChangeNotifier {
  bool _visible = false;

  bool get visible => _visible;

  void switchVisible() {
    _visible = !_visible;
    notifyListeners();
  }
}
