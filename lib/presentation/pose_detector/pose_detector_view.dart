import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../utils/pose_painter.dart';
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
  bool _isBusy = false;

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
    // 카메라뷰 보이기
    return CameraView(
      // 스켈레톤 그려주는 객체 전달
      customPaint: _customPaint,
      // 카메라에서 전해 주는 이미지를 받을 때마다 아래 함수 실행
      onImage: (inputImage) {
        // print('image');
        processImage(inputImage);
      },
    );
  }

  // 카메라에서 실시간으로 받아온 이미지 처리
  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    // poseDetector에서 추출된 코즈 가져오기
    List<Pose> poses = await _poseDetector.processImage(inputImage);
    // 이미지가 정상적이면 포즈에 스켈레톤 그려주기
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
          poses, inputImage.metadata!.size, inputImage.metadata!.rotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      // 추출된 포즈 없음
      _customPaint = null;
      print('no poses');
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
