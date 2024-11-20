import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../main.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {super.key,
      this.customPaint,
      required this.onImage,
      this.initialDirection = CameraLensDirection.back});

  // 스켈레톤 그려주는 객체
  final CustomPaint? customPaint;

  // 이미지 받을 때마다 실행하는 함수
  final Function(InputImage inputImage) onImage;

  // 카메라 렌즈 방향 함수
  final CameraLensDirection initialDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // 카메라를 다루기 위한 변수
  CameraController? _controller;

  // 카메라 인덱스
  int _cameraIndex = -1;

  // 확대 축소 레벨
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;

  // 카메라 렌즈 변경 변수
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();

    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      print(cameras.length);
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container(
        child: Text('nothing'),
      );
    }
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: _changingCameraLens
                  ? const Center(
                      child: Text('Changing Camera Lens'),
                    )
                  : CameraPreview(_controller!),
            ),
          ),

          // 추출된 스켈레톤 그리기
          if (widget.customPaint != null) widget.customPaint!,
          // 화면 확대 축소 위젯
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Slider(
              value: zoomLevel,
              min: minZoomLevel,
              max: maxZoomLevel,
              onChanged: (newSliderValue) {
                setState(() {
                  zoomLevel = newSliderValue;
                  _controller!.setZoomLevel(zoomLevel);
                });
              },
              divisions: (maxZoomLevel - 1).toInt() < 1
                  ? null
                  : (maxZoomLevel - 1).toInt(),
            ),
          ),
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.first;

    final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: planeData.bytesPerRow);

    final inputImage =
        InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

    widget.onImage(inputImage);
  }
}
