import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset(Assets.launcherIcon)));
  }
}
