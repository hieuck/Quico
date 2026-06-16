abstract class OcrService {
  Future<OcrResult> extractTextFromImage(String imagePath);
}

class OcrResult {
  final String text;
  final double? confidence;

  const OcrResult({
    required this.text,
    this.confidence,
  });
}
