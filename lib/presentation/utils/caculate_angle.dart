import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'squat_phase.dart';

/// 주어진 세 점으로 두 벡터 간의 각도를 계산
double computeAngle(Map<String, double> pointA, Map<String, double> pointB,
    Map<String, double> pointC) {
  // 좌표값을 double로 변환
  double ax = pointA['x']!.toDouble();
  double ay = pointA['y']!.toDouble();
  double bx = pointB['x']!.toDouble();
  double by = pointB['y']!.toDouble();
  double cx = pointC['x']!.toDouble();
  double cy = pointC['y']!.toDouble();

  // 벡터 계산
  double vectorABx = bx - ax;
  double vectorABy = by - ay;
  double vectorBCx = cx - bx;
  double vectorBCy = cy - by;

  // 내적(dot product)
  double dotProduct = (vectorABx * vectorBCx) + (vectorABy * vectorBCy);

  // 벡터 크기 계산 (magnitude)
  double magnitudeAB = sqrt(pow(vectorABx, 2) + pow(vectorABy, 2));
  double magnitudeBC = sqrt(pow(vectorBCx, 2) + pow(vectorBCy, 2));

  // 예외 처리: 벡터 크기가 0인 경우
  if (magnitudeAB == 0 || magnitudeBC == 0) {
    print("Error: One or more vectors have zero magnitude.");
    return 0.0;
  }

  // 각도 계산 (arccos 적용 후, 라디안을 도 단위로 변환)
  double cosTheta = dotProduct / (magnitudeAB * magnitudeBC);

  // acos 함수의 범위를 초과하는 값을 방지
  cosTheta = cosTheta.clamp(-1.0, 1.0);

  double angle = acos(cosTheta) * (180 / pi); // 도 단위로 변환
  return angle;
}

/// 무릎 각도를 계산하여 반환하는 함수
Map<String, double> calculateKneeAngles(List<Pose> poses) {
  if (poses.isEmpty) {
    // print("No poses detected.");
    return {'left': 0.0, 'right': 0.0};
  }

  // 첫 번째 포즈 선택
  Pose pose = poses.first;

  // 필요한 키포인트 추출
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

  // 키포인트 유효성 검사
  if (leftHip == null ||
      leftKnee == null ||
      leftAnkle == null ||
      rightHip == null ||
      rightKnee == null ||
      rightAnkle == null) {
    print("Missing keypoints for knee angle calculation.");
    return {'left': 0.0, 'right': 0.0};
  }

  // 무릎 각도 계산
  double leftKneeAngle = computeAngle(
    {'x': leftHip.x, 'y': leftHip.y},
    {'x': leftKnee.x, 'y': leftKnee.y},
    {'x': leftAnkle.x, 'y': leftAnkle.y},
  );

  double rightKneeAngle = computeAngle(
    {'x': rightHip.x, 'y': rightHip.y},
    {'x': rightKnee.x, 'y': rightKnee.y},
    {'x': rightAnkle.x, 'y': rightAnkle.y},
  );

  return {'left': leftKneeAngle, 'right': rightKneeAngle};
}

/// 상태 변화를 추적하는 evaluateSquat 함수
Map<String, SquatPhase> evaluateSquat(
    Map<String, double> kneeAngles, Map<String, SquatPhase> previousPhases) {
  // 각도에서 스쿼트 상태를 평가하는 로직
  SquatPhase evaluatePhase(double kneeAngle) {
    if (kneeAngle > 70) {
      return SquatPhase.bottomPosition;
    } else if (kneeAngle > 30 && kneeAngle <= 70) {
      return SquatPhase.descentPhase;
    } else if (kneeAngle <= 30) {
      return SquatPhase.standing;
    } else {
      return SquatPhase.invalid;
    }
  }

  // 현재 상태 평가
  SquatPhase leftSquatPhase = evaluatePhase(kneeAngles['left']!);
  SquatPhase rightSquatPhase = evaluatePhase(kneeAngles['right']!);

  // 상태 변경 시 출력하고 새로운 맵으로 상태 갱신
  Map<String, SquatPhase> updatedPhases = Map.from(previousPhases);

  // 이전 상태와 비교
  if (updatedPhases['left'] != leftSquatPhase) {
    print(
        "Left Knee: ${leftSquatPhase.description} (Angle: ${kneeAngles['left']!.toStringAsFixed(2)}°)");
    updatedPhases['left'] = leftSquatPhase; // 상태 갱신
  }

  if (updatedPhases['right'] != rightSquatPhase) {
    print(
        "Right Knee: ${rightSquatPhase.description} (Angle: ${kneeAngles['right']!.toStringAsFixed(2)}°)");
    updatedPhases['right'] = rightSquatPhase; // 상태 갱신
  }

  return updatedPhases;
}

// /// 상태 변화를 추적하는 evaluateSquat 함수
// Map<String, SquatPhase> evaluateSquat(
//     List<Pose> poses, Map<String, SquatPhase> previousPhases) {
//   if (poses.isEmpty) {
//     // print("No poses detected.");
//     return previousPhases;
//   }
//
//   // 첫 번째 포즈 선택
//   Pose pose = poses.first;
//
//   // 필요한 키포인트 추출
//   PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
//   PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
//   PoseLandmark? leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
//
//   PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
//   PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
//   PoseLandmark? rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
//
//   // 키포인트 유효성 검사
//   if (leftHip == null ||
//       leftKnee == null ||
//       leftAnkle == null ||
//       rightHip == null ||
//       rightKnee == null ||
//       rightAnkle == null) {
//     print("Missing keypoints for squat evaluation.");
//     return previousPhases;
//   }
//
//   // 무릎 각도 계산
//   double leftKneeAngle = computeAngle(
//     {'x': leftHip.x, 'y': leftHip.y},
//     {'x': leftKnee.x, 'y': leftKnee.y},
//     {'x': leftAnkle.x, 'y': leftAnkle.y},
//   );
//
//   double rightKneeAngle = computeAngle(
//     {'x': rightHip.x, 'y': rightHip.y},
//     {'x': rightKnee.x, 'y': rightKnee.y},
//     {'x': rightAnkle.x, 'y': rightAnkle.y},
//   );
//
//   // 평가 기준 정의
//   SquatPhase evaluatePhase(double kneeAngle) {
//     if (kneeAngle > 70) {
//       return SquatPhase.bottomPosition;
//     } else if (kneeAngle > 30 && kneeAngle <= 70) {
//       return SquatPhase.descentPhase;
//     } else if (kneeAngle <= 30) {
//       return SquatPhase.standing;
//     } else {
//       return SquatPhase.invalid;
//     }
//   }
//
//   // 현재 상태 평가
//   SquatPhase leftSquatPhase = evaluatePhase(leftKneeAngle);
//   SquatPhase rightSquatPhase = evaluatePhase(rightKneeAngle);
//
//   // 상태 변경 시 출력하고 새로운 맵으로 상태 갱신
//   Map<String, SquatPhase> updatedPhases = Map.from(previousPhases);
//
//   // 이전 상태와 비교
//   if (updatedPhases['left'] != leftSquatPhase) {
//     print(
//         "Left Knee: ${leftSquatPhase.description} (Angle: ${leftKneeAngle.toStringAsFixed(2)}°)");
//     updatedPhases['left'] = leftSquatPhase; // 상태 갱신
//   }
//
//   if (updatedPhases['right'] != rightSquatPhase) {
//     print(
//         "Right Knee: ${rightSquatPhase.description} (Angle: ${rightKneeAngle.toStringAsFixed(2)}°)");
//     updatedPhases['right'] = rightSquatPhase; // 상태 갱신
//   }
//
//   updatedPhases['left'] = leftSquatPhase;
//   updatedPhases['right'] = rightSquatPhase;
//
//   return updatedPhases;
// }
