import 'package:comic_reader/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomToolBar extends StatelessWidget implements PreferredSizeWidget {
  final double maxPage;

  BottomToolBar({required this.maxPage});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) => Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              max: maxPage - 1,
              min: 0,
              divisions: maxPage.toInt() > 1 ? maxPage.toInt() - 1 : 1,
              label: watch(photoSliderProvider).nowPage.toInt().toString(),
              value: watch(photoSliderProvider).nowPage,
              onChanged: (value) {
                context.read(photoSliderProvider).nowPage = value;
              },
              onChangeEnd: (value) {
                watch(photoSliderProvider)
                    .pageController
                    .jumpToPage(value.toInt());
              },
            ),
            Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      //TODO: something
                    },
                    child: Icon(
                      Icons.ac_unit,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      //TODO: something
                    },
                    child: Icon(
                      Icons.access_time_filled_sharp,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(2000);
}
