import 'package:flutter/material.dart';

import 'pose_detector_view.dart';

class PoseDetectScreen extends StatelessWidget {
  const PoseDetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: PoseDetectorView()));
  }
}
