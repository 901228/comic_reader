import 'dart:async';

import 'package:comic_reader/backButton.dart';
import 'package:comic_reader/fileViewer_page/fileViewer.dart';
import 'package:comic_reader/home_page.dart';
import 'package:comic_reader/viewer_page/animatedAppBar.dart';
import 'package:comic_reader/viewer_page/bottomToolBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        final args = (settings.arguments ?? {}) as Map;
        switch (settings.name) {
          case '/':
            // builder = (_) => Home();
            builder = (_) => _Home();
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

// class Hardware {
//   static const MethodChannel _channel =
//       const MethodChannel('mochi.flutter/brightness');
//
//   static Future<double> get brightness async =>
//       (await _channel.invokeMethod('brightness')) as double;
//   static Future setBrightness(double brightness) =>
//       _channel.invokeMethod('setBrightness', {"brightness": brightness});
// }

class _Home extends StatefulWidget {
  @override
  __HomeState createState() => __HomeState();
}

class __HomeState extends State<_Home> with SingleTickerProviderStateMixin {
  bool _visible = true;

  final volumeKeyMethodChannel =
      MethodChannel("mochi.flutter/interceptVolumeKey");
  bool _interceptVolumeKeyEnable = false;

  final volumeKeyEventChannel = EventChannel("mochi.flutter/volumeKeyEvent");
  late final StreamSubscription subscription;

  double brightness = 0;

  late final AnimationController animationController;

  int a = 0;

  Future<void> initScreenBrightness() async {
    double _brightness;

    try {
      final currentBrightness = await ScreenBrightness.current;
      final initialBrightness = await ScreenBrightness.initial;
      _brightness = initialBrightness == currentBrightness
          ? initialBrightness
          : currentBrightness;
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to get initial brightness';
    }

    if (!mounted) return;

    setState(() {
      brightness = _brightness;
    });
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness.setScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set brightness';
    }
  }

  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness.resetScreenBrightness();
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to reset brightness';
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    subscription =
        volumeKeyEventChannel.receiveBroadcastStream().listen((event) {
      final code = event as String;
      if (code == "volumeUp")
        setState(() {
          a++;
        });
      else if (code == "volumeDown")
        setState(() {
          a--;
        });
    });
    // initScreenBrightness();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    subscription.cancel();
    // resetBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Stack(
      children: [
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: SizedBox(
            height: 150,
            width: 200,
            child: Container(
              color: Colors.amber,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    TextButton(
                      child: Text(
                        "click to switch visibility.",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => setState(() {
                        _visible = !_visible;
                      }),
                    ),
                    Text(a.toString()),
                    Text("Brightness: $brightness"),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          child: AnimatedAppBar(
            direction: BarAlignment.top,
            visible: _visible,
            controller: animationController,
            child: AppBar(
              title: Text("appBar"),
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
        ),
        Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height - kToolbarHeight),
          height: MediaQuery.of(context).size.height,
          child: AnimatedAppBar(
            direction: BarAlignment.bottom,
            visible: _visible,
            controller: animationController,
            child: AppBar(
              title: Text("bottomBar"),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width - kToolbarHeight,
            top: MediaQuery.of(context).size.height * 0.4,
          ),
          height: MediaQuery.of(context).size.height * 0.6,
          child: AnimatedAppBar(
            direction: BarAlignment.left,
            visible: _visible,
            controller: animationController,
            child: RotatedBox(
              quarterTurns: 1,
              child: ToolBar(
                children: [
                  Icon(Icons.ac_unit),
                  InkWell(
                    child: IconTheme(
                      data: Theme.of(context).iconTheme,
                      child: Icon(Icons.add_comment),
                    ),
                    onTap: () async {
                      if (_interceptVolumeKeyEnable)
                        await volumeKeyMethodChannel
                            .invokeMethod("uninterceptKeyDown");
                      else
                        await volumeKeyMethodChannel
                            .invokeMethod("interceptKeyDown");

                      _interceptVolumeKeyEnable = !_interceptVolumeKeyEnable;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width - kToolbarHeight,
            top: MediaQuery.of(context).size.height * 0.2,
          ),
          height: MediaQuery.of(context).size.height * 0.8,
          child: AnimatedAppBar(
            direction: BarAlignment.right,
            visible: _visible,
            controller: animationController,
            child: RotatedBox(
              quarterTurns: 1,
              child: ToolBar(
                children: [
                  Slider.adaptive(
                    label: brightness.toString(),
                    value: brightness,
                    onChanged: (value) {
                      setBrightness(value);
                      setState(() {
                        brightness = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ToolBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> children;

  ToolBar({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: NavigationToolbar(
        centerMiddle: true,
        middle: IconTheme(
          data: Theme.of(context).iconTheme,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
