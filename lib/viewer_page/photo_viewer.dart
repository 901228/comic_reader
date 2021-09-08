import 'dart:io';

import 'package:comic_reader/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path/path.dart' as Pa;
import 'package:preload_page_view/preload_page_view.dart';

class PhotoViewer extends StatefulWidget {
  final Directory nowDirectory;
  final double maxPage;

  PhotoViewer({required this.nowDirectory, required this.maxPage});

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  List<Widget> photoList = [];

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      photoList = imageList(widget.nowDirectory.listSync(), context);
      Offset scale = Offset(0.25, 0.25);

      return GestureDetector(
        onTapDown: (details) {
          context.read(tapPosProvider).tapDownArea = TapPosProc.nowArea(
              details.localPosition, MediaQuery.of(context).size, scale);
        },
        onTapUp: (details) {
          context.read(tapPosProvider).tapUpArea = TapPosProc.nowArea(
              details.localPosition, MediaQuery.of(context).size, scale);
        },
        onTap: () {
          if (watch(tapPosProvider).isTap() == TapArea.MIDDLE &&
              !watch(appBarVisibilityProvider).visible)
            context.read(appBarVisibilityProvider).switchVisible();
          else {
            if (watch(appBarVisibilityProvider).visible)
              context.read(appBarVisibilityProvider).switchVisible();
            if (watch(tapPosProvider).isTap() == TapArea.RIGHT) {
              watch(photoSliderProvider).pageController.nextPage(
                  duration: Duration(microseconds: 1), curve: Curves.linear);
            } else if (watch(tapPosProvider).isTap() == TapArea.LEFT) {
              watch(photoSliderProvider).pageController.previousPage(
                  duration: Duration(microseconds: 1), curve: Curves.linear);
            }
          }
        },
        onTapCancel: () {
          if (watch(appBarVisibilityProvider).visible)
            context.read(appBarVisibilityProvider).switchVisible();
        },
        child: Stack(
          children: [
            PreloadPageView.builder(
              itemCount: photoList.length,
              preloadPagesCount: 2,
              controller: watch(photoSliderProvider).pageController,
              onPageChanged: (value) {
                context.read(photoSliderProvider).nowPage = value.toDouble();
              },
              itemBuilder: (context, index) => photoList[index],
              pageSnapping: true,
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: Container(
                child: Text(
                  '${Pa.basename(widget.nowDirectory.path)}  ${watch(photoSliderProvider).nowPage.toInt() + 1} / ${widget.maxPage.toInt()}  ${DateTime.now().hour}:${DateTime.now().minute}',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color(0x92000000),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 6,
                  top: 2,
                  bottom: 2,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> imageList(List<FileSystemEntity> list, BuildContext context) {
    List<PhotoView> result = List<PhotoView>.empty(growable: true);
    list.sort((a, b) => a.path.compareTo(b.path));
    list.forEach((e) {
      if (e is File && PhotoSliderProc.isImage(e.path)) {
        result.add(PhotoView(
          imageProvider: FileImage(e),
          loadingBuilder: (context, event) => Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ));
      }
    });

    return result;
  }
}
