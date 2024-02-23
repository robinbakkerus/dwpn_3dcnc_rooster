import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/data/app_version.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  SplashPage({super.key});
  final String version = appVersion;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: AppData.instance.screenWidth,
      height: AppData.instance.screenHeight,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _animatedLonuText(),
            wh.verSpace(20),
            _animatedVersionText()
          ]),
    ));
  }

  Widget _animatedLonuText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultTextStyle(
          style: const TextStyle(
              fontSize: 120.0,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.orange),
          child: AnimatedTextKit(
            animatedTexts: [
              ScaleAnimatedText('3D',
                  duration: const Duration(milliseconds: 3500)),
            ],
          ),
        ),
        DefaultTextStyle(
          style: const TextStyle(
              fontSize: 120.0,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue),
          child: AnimatedTextKit(
            animatedTexts: [
              ScaleAnimatedText('CNC',
                  duration: const Duration(milliseconds: 3500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _animatedVersionText() {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 12.0, color: Colors.black),
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText('Trainingschema ${widget.version}',
              speed: const Duration(milliseconds: 80)),
        ],
      ),
    );
  }
}
