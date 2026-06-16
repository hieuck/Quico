abstract class SpeechToTextService {
  Future<SpeechTranscriptionResult> listenAndTranscribe();
}

class SpeechTranscriptionResult {
  final String text;
  final double? confidence;
  final bool isFinal;

  const SpeechTranscriptionResult({
    required this.text,
    this.confidence,
    required this.isFinal,
  });
}
