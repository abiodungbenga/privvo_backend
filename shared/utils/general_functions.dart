import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';

import 'package:image/image.dart' as img;

import '../../core/exceptions/app_exceptions.dart';

class GeneralFunctions {
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  static bool verifyPassword(String password, String hashed) {
    return BCrypt.checkpw(password, hashed);
  }

  static Future<void> ensureDirExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static Future<File?> storeFile({
    UploadedFile? uploadedFile,
    String? fileDirectory,
  }) async {
    try {
      if (uploadedFile == null) return null;

      final dirPath = 'public/uploads/$fileDirectory';
      await ensureDirExists(dirPath);

      final bytes = await uploadedFile.readAsBytes();
      final mimeType = uploadedFile.contentType?.mimeType;

      final filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}_${uploadedFile.name}';

      final file = File(filePath);
      if (mimeType != null && mimeType.startsWith('image/')) {
        final image = img.decodeImage(Uint8List.fromList(bytes));

        if (image == null) throw BadRequestException("Invalid image");

        final compressedBytes = img.encodeJpg(
          image,
          quality: 70,
        );

        await file.writeAsBytes(compressedBytes);
        return file;
      }
      await file.writeAsBytes(bytes);
      return file;
    } on img.ImageException catch (e) {
      throw BadRequestException(e.toString());
    }
  }
}
