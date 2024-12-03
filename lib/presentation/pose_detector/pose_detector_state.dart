import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../utils/squat_phase.dart';

part 'pose_detector_state.freezed.dart';

@freezed
class PoseDetectorState with _$PoseDetectorState {
  const factory PoseDetectorState({
    @Default([]) List<Pose> poses,
    @Default(true) bool canProcess,
    @Default(false) bool isBusy,
    @Default({'left': SquatPhase.invalid, 'right': SquatPhase.invalid})
    Map<String, SquatPhase> squatPhase,
    @Default({'left': 0.0, 'right': 0.0}) Map<String, double> kneeAngles,
  }) = _PoseDetectorState;
}
