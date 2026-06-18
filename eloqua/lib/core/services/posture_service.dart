// posture_service.dart
// STUB — real MediaPipe/PyTorch integration coming in Phase 4
// Why: keeps the app running now without any ML packages

enum PostureStatus { good, warning, alert }

class PostureMeasurement {
  final PostureStatus status;
  final String debugMessage;
  const PostureMeasurement({required this.status, required this.debugMessage});
}

class PostureService {
  PostureMeasurement? get lastMeasurement => null;
  Future<PostureMeasurement?> analyzePose(dynamic inputImage) async => null;
  Future<void> dispose() async {}
}

class PostureInputImageFactory {
  PostureInputImageFactory._();
  static dynamic fromCameraImage(dynamic image, int sensorOrientation) => null;
}