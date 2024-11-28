import 'dart:math';

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
  print(dotProduct);

  // 벡터 크기 계산 (magnitude)
  double magnitudeAB = sqrt(pow(vectorABx, 2) + pow(vectorABy, 2));
  double magnitudeBC = sqrt(pow(vectorBCx, 2) + pow(vectorBCy, 2));

  print(magnitudeAB);
  print(magnitudeBC);

  // 예외 처리: 벡터 크기가 0인 경우
  if (magnitudeAB == 0 || magnitudeBC == 0) {
    print("Error: One or more vectors have zero magnitude.");
    return 0.0;
  }

  // 각도 계산 (arccos 적용 후, 라디안을 도 단위로 변환)
  double cosTheta = dotProduct / (magnitudeAB * magnitudeBC);

  print(cosTheta);

  // acos 함수의 범위를 초과하는 값을 방지
  cosTheta = cosTheta.clamp(-1.0, 1.0);

  double angle = acos(cosTheta) * (180 / pi); // 도 단위로 변환
  return angle;
}

// void main() {
//   // 예제 좌표
//   Map<String, double> hip = {'x': 200, 'y': 300};
//   Map<String, double> knee = {'x': 210, 'y': 400};
//   Map<String, double> ankle = {'x': 230, 'y': 450};
//
//   // 무릎 각도 계산
//   double kneeAngle = computeAngle(hip, knee, ankle);
//   print('Knee angle: $kneeAngle°');
// }

void evaluateSquat(dynamic keypoints) {
  // 좌표 추출
  Map<String, double> leftHip = keypoints['left_hip'];
  Map<String, double> leftKnee = keypoints['left_knee'];
  Map<String, double> leftAnkle = keypoints['left_ankle'];

  Map<String, double> rightHip = keypoints['right_hip'];
  Map<String, double> rightKnee = keypoints['right_knee'];
  Map<String, double> rightAnkle = keypoints['right_ankle'];

  // 양쪽 무릎 각도 계산
  double leftKneeAngle = computeAngle(leftHip, leftKnee, leftAnkle);
  double rightKneeAngle = computeAngle(rightHip, rightKnee, rightAnkle);

  // 평가 기준 정의
  const standingThreshold = 150.0;
  const descentThreshold = 90.0;

  // 자세 평가
  String evaluateAngle(double kneeAngle) {
    if (kneeAngle > standingThreshold) {
      return "Standing";
    } else if (kneeAngle > descentThreshold && kneeAngle <= standingThreshold) {
      return "Descent Phase";
    } else if (kneeAngle <= descentThreshold) {
      return "Bottom Position";
    } else {
      return "Invalid";
    }
  }

  String leftSquatPhase = evaluateAngle(leftKneeAngle);
  String rightSquatPhase = evaluateAngle(rightKneeAngle);

  // 양쪽 무릎 상태 출력
  print(
      "Left Knee: $leftSquatPhase (Angle: ${leftKneeAngle.toStringAsFixed(2)}°)");
  print(
      "Right Knee: $rightSquatPhase (Angle: ${rightKneeAngle.toStringAsFixed(2)}°)");

  // 피드백 제공
  if (leftSquatPhase == "Standing" && rightSquatPhase == "Standing") {
    print("Good Standing Position");
  } else if (leftSquatPhase == "Bottom Position" &&
      rightSquatPhase == "Bottom Position") {
    print("Great! You've reached the bottom position.");
  } else if (leftSquatPhase == "Invalid" || rightSquatPhase == "Invalid") {
    print("Invalid squat form detected. Adjust your posture.");
  } else {
    print("Keep up the steady motion during your descent or ascent!");
  }
}

// void main() {
//   // 예제 키포인트 데이터
//   Map<String, Map<String, double>> keypoints = {
//     'left_hip': {'x': 200, 'y': 300},
//     'left_knee': {'x': 210, 'y': 400},
//     'left_ankle': {'x': 230, 'y': 450},
//     'right_hip': {'x': 200, 'y': 300},
//     'right_knee': {'x': 210, 'y': 400},
//     'right_ankle': {'x': 230, 'y': 450},
//   };
//
//   // 스쿼트 평가
//   evaluateSquat(keypoints);
// }
