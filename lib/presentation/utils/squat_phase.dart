/// 현재 스쿼트 상태를 나타내는 Enum
enum SquatPhase { standing, descentPhase, bottomPosition, invalid }

/// SquatPhase를 출력 가능한 문자열로 변환
extension SquatPhaseDescription on SquatPhase {
  String get description {
    switch (this) {
      case SquatPhase.standing:
        return "Standing";
      case SquatPhase.descentPhase:
        return "Descent Phase";
      case SquatPhase.bottomPosition:
        return "Bottom Position";
      case SquatPhase.invalid:
        return "Invalid";
    }
  }
}
