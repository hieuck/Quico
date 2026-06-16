import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_to_text_service.dart';

class DeviceSpeechToTextService implements SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  Future<SpeechTranscriptionResult> listenAndTranscribe() async {
    final available = await _speech.initialize();
    if (!available) {
      return const SpeechTranscriptionResult(
        text: '',
        isFinal: true,
      );
    }
    String recognizedText = '';
    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      localeId: 'vi_VN',
    );
    await Future.delayed(const Duration(seconds: 5));
    await _speech.stop();
    if (recognizedText.isEmpty) {
      return const SpeechTranscriptionResult(
        text: '',
        isFinal: true,
      );
    }
    return SpeechTranscriptionResult(
      text: recognizedText,
      isFinal: true,
    );
  }
}
