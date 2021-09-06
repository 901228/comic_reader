import 'package:comic_reader/fileViewer_page/fileViewer.dart';
import 'package:comic_reader/home_page.dart';
import 'package:comic_reader/viewer_page/viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(
    child: MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xAA000000),
          foregroundColor: Colors.white,
        ),
        sliderTheme: SliderThemeData(
          valueIndicatorColor: Color(0xAA000000),
          thumbColor: Colors.white,
          activeTickMarkColor: Colors.transparent,
          activeTrackColor: Colors.white,
          inactiveTickMarkColor: Colors.transparent,
          inactiveTrackColor: Colors.grey[700],
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        final args = (settings.arguments ?? {}) as Map;
        switch (settings.name) {
          case '/':
            builder = (_) => Home();
            break;
          case '/fileViewer':
            builder = (_) => FileViewer(
                  rootDirectory: args["rootDirectory"],
                  showFsType: args["showFsType"],
                  selectableFsType: args["selectableFsType"],
                );
            break;
          default:
            throw new Exception('路由名稱有誤: ${settings.name}');
        }
        return new MaterialPageRoute(builder: builder, settings: settings);
      },
    ),
  ));
}
