import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> requestMicrophone();
  Future<bool> requestSpeechRecognition();
  Future<bool> requestCamera();
  Future<bool> requestPhotos();
}

class DevicePermissionService implements PermissionService {
  @override
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestSpeechRecognition() async {
    final status = await Permission.speech.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
}
