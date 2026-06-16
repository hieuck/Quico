import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service.dart';

class MlkitOcrService implements OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  @override
  Future<OcrResult> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognisedText = await _recognizer.processImage(inputImage);
      return OcrResult(
        text: recognisedText.text,
        confidence: null,
      );
    } catch (e) {
      return OcrResult(text: '', confidence: null);
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
