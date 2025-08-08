import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Stemm Chat App/presentation/routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? MaterialApp.router(
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouterPage().goRouter,
          )
        : CupertinoApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouterPage().goRouter,
          );
  }
}
