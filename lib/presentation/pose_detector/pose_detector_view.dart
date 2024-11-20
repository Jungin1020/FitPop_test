import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:test_get_skeleton_1/presentation/pose_detector/pose_detector_view_model.dart';
import 'camera_view.dart';

// 카메라에서 스켈레톤 추출하는 화면
class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  // 스켈레톤 추출 변수 선언
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;

  // bool _isBusy = false;

  //스켈레톤 모양을 그려주는 변수
  CustomPaint? _customPaint;
  Map<String, double> inputMap = {};

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = PoseDetectorViewModel();
    // final state = viewModel.state;
    // 카메라뷰 보이기
    return CameraView(
      // 스켈레톤 그려주는 객체 전달
      customPaint: _customPaint,
      // 카메라에서 전해 주는 이미지를 받을 때마다 아래 함수 실행
      onImage: (inputImage) async {
        final customPaint = await viewModel.processImage(
            _poseDetector, _customPaint, inputImage);
        if (customPaint != null) {
          setState(
            () {
              _customPaint = customPaint;
            },
          );
        }
      },
    );
  }
}
