import 'package:flutter/material.dart';


final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void alternarTema() {
  themeNotifier.value =
  themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}


