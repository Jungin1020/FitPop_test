import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:test_get_skeleton_1/presentation/pose_detector/pose_detector_state.dart';
import 'package:test_get_skeleton_1/presentation/utils/caculate_angle.dart';

import '../utils/pose_painter.dart';
import '../utils/squat_phase.dart';

class PoseDetectorViewModel with ChangeNotifier {
  PoseDetectorState _state = PoseDetectorState();

  PoseDetectorState get state => _state;

  Future<CustomPaint?> processImage(PoseDetector poseDetector,
      CustomPaint? customPaint, InputImage inputImage, bool canProcess) async {
    if (!canProcess) return null;
    if (_state.isBusy) return null;
    _state = state.copyWith(isBusy: true);
    notifyListeners();

    // poseDetector에서 추출된 포즈 가져오기
    List<Pose> poses = await poseDetector.processImage(inputImage);

    // 무릎 각도 계산하기
    Map<String, double> kneeAngles = calculateKneeAngles(poses);

    // 자세 구분하기
    Map<String, SquatPhase> updatedPhase =
        evaluateSquat(kneeAngles, _state.squatPhase);

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
    }

    if (_state.squatPhase['left'] == SquatPhase.descentPhase &&
        updatedPhase['left'] == SquatPhase.standing) {
      _state = state.copyWith(
        squatCount: state.squatCount + 1,
      );
      notifyListeners();
    }

    _state = state.copyWith(
      isBusy: false,
      kneeAngles: kneeAngles,
      squatPhase: Map.from(updatedPhase),
    );
    notifyListeners();

    return customPaint;
  }
}
