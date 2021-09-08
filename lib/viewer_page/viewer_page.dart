import 'dart:io';

import 'package:comic_reader/backButton.dart';
import 'package:comic_reader/viewer_page/animatedAppBar.dart';
import 'package:comic_reader/viewer_page/bottomToolBar.dart';
import 'package:comic_reader/viewer_page/photo_viewer.dart';
import 'package:comic_reader/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as Pa;

class Viewer extends StatefulWidget {
  final Directory nowDirectory;
  final double maxPage;

  Viewer({required this.nowDirectory, required this.maxPage});

  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {
  final bool isDesktop = !(Platform.isAndroid || Platform.isIOS);

  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) => Scaffold(
        appBar: AnimatedAppBar(
          direction: BarAlignment.top,
          visible: watch(appBarVisibilityProvider).visible,
          controller: animationController,
          child: AppBar(
            title: Text(Pa.basename(widget.nowDirectory.path)),
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
        ),
        bottomNavigationBar: Container(
          height: kToolbarHeight * 2,
          child: AnimatedAppBar(
            direction: BarAlignment.bottom,
            visible: watch(appBarVisibilityProvider).visible,
            controller: animationController,
            child: BottomToolBar(maxPage: widget.maxPage),
          ),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: PhotoViewer(
          nowDirectory: widget.nowDirectory,
          maxPage: widget.maxPage,
        ),
      ),
    );
  }
}
