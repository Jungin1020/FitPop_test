import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:test_get_skeleton_1/presentation/pose_detector/pose_detector_state.dart';

import '../utils/pose_painter.dart';

class PoseDetectorViewModel with ChangeNotifier {
  PoseDetectorState _state = PoseDetectorState();
  PoseDetectorState get state => _state;

  Future<CustomPaint?> processImage(PoseDetector poseDetector,
      CustomPaint? customPaint, InputImage inputImage, bool canProcess) async {
    if (!canProcess) return null;
    if (state.isBusy) return null;
    _state = state.copyWith(isBusy: true);
    notifyListeners();

    // poseDetector에서 추출된 코즈 가져오기
    List<Pose> poses = await poseDetector.processImage(inputImage);

    // 이미지가 정상적이고 추출된 포즈가 있다면 스켈레톤 그려주기
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        poses.isNotEmpty) {
      final painter = PosePainter(
          poses, inputImage.metadata!.size, inputImage.metadata!.rotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      // 추출된 포즈 없음
      customPaint = null;
      print('no poses');
    }
    // print(poses);
    _state = state.copyWith(isBusy: false, poses: poses);
    notifyListeners();

    return customPaint;
  }
}
