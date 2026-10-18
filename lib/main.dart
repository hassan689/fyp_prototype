import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = FarmStore();
  await store.load();
  runApp(YieldApp(store: store));
}
