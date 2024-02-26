import 'package:flutter/material.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';

enum Groep {
  pr,
  r1,
  r2,
  r3,
  zamo,
  sg,
  zomer;
}

class AppConstants {
  final Color lightYellow = const Color(0xffF4E9CA);
  final Color lightGeen = const Color(0xffE3ECE3);
  final Color lightRed = const Color(0xffF6AB94);
  final Color lightblue = const Color(0xffBFD9EE);
  final Color lightOrange = const Color(0xffF3EFE3);
  final Color lightBrown = const Color(0xffEDEAE9);
  final Color ssRowHeader = Colors.lightBlue[100]!;
  final Color lonuExtraDag = const Color(0xfff7cd9c);
  final Color ssRowTuesday = Colors.green[100]!;
  final Color ssRowWednesday = const Color(0xffE8F5E9);
  final Color ssRowThursday = Colors.lime[100]!;
  final Color ssRowFriday = Colors.yellow[50]!;
  final Color ssRowSaturday = const Color(0xffEBE8E6);
  final Color ssRowMonday = Colors.blue[100]!;
  final Color dayRow = const Color(0xff00EDFF);

  final double h1 = 0.1 * AppData.instance.screenHeight;
  final double w1 = 0.1 * AppData.instance.screenWidth;
  final double w2 = 0.2 * AppData.instance.screenWidth;
  final double w12 = 0.12 * AppData.instance.screenWidth;
  final double w15 = 0.15 * AppData.instance.screenWidth;
  final double w25 = 0.25 * AppData.instance.screenWidth;
  final double w30 = 0.3 * AppData.instance.screenWidth;
  final double w40 = 0.4 * AppData.instance.screenWidth;

  final String removeExtraSpreadsheetRow = 'REMOVE EXTRA ROW';

  final String localNL = 'nl_NL';
  final String localUK = 'en_US';
}
