import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/firebase_options.dart';
import 'package:dwpn_3dcnc_rooster/page/start_page.dart';
import 'package:dwpn_3dcnc_rooster/service/navigation_service.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/widget/widget_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppController.instance.initializeAppData(context);
    TargetPlatform platform = AppHelper.instance.getPlatform();
    bool isWindows = platform == TargetPlatform.windows;

    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      scrollBehavior: isWindows
          ? const MaterialScrollBehavior()
              .copyWith(dragDevices: {PointerDeviceKind.mouse})
          : const MaterialScrollBehavior()
              .copyWith(dragDevices: {PointerDeviceKind.touch}),
      scaffoldMessengerKey: WidgetHelper.instance.scaffoldKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          tabBarTheme: const TabBarTheme(labelColor: Colors.black)),
      home: const StartPage(),
    );
  }
}
