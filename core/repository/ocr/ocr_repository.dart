import 'dart:io';
import '../../exceptions/app_exceptions.dart';

class OcrRepository {
  static Future<String> extractFromFIle(File file) async {
    if (file.path.endsWith(".pdf")) {
      return Future.value("Not pdf extractor not currently availabel");
    }
    return generate(file.path, "eng");
  }

  static Future<String> generate(String filePath, String language) async {
    try {
      const outputBase = 'result';

      String getTesseractPath() {
        if (Platform.isWindows) {
          return r'C:\Program Files\Tesseract-OCR\tesseract.exe';
        }
        return 'tesseract';
      }

      final process = await Process.run(
        getTesseractPath(),
        [filePath, outputBase, "--psm", "6", "-l", language],
      );

      if (process.exitCode != 0) {
        throw Exception(process.stderr);
      }
      final file = File('$outputBase.txt');

      return file.readAsString().whenComplete(file.delete);
    } catch (e) {
      throw FailedException("Failed to generate text $e");
    }
  }
}
