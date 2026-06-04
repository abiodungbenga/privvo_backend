import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary/cloudinary.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:image/image.dart' as img;
import '../../exceptions/app_exceptions.dart';

class StorageService {
  factory StorageService() => instance;
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  final cloudinary = Cloudinary.signedConfig(
    apiKey: '348455518921935',
    apiSecret: 'ZefzaU_GDLvcpAOZqfTUwnhq3AU',
    cloudName: 'drbwpijii',
  );

  Future<Uint8List> encryptFile(List<int> bytes, String keyString) async {
    final key = encrypt.Key.fromUtf8(keyString.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    return Uint8List.fromList(encrypted.bytes);
  }

  Future<File?> compressFile({
    UploadedFile? uploadedFile,
    String? userId,
  }) async {
    final mimeType = uploadedFile?.contentType.mimeType;

    final filePath =
        '${DateTime.now().millisecondsSinceEpoch}_${userId ?? ""}_${uploadedFile?.name}';
    final bytes = await uploadedFile?.readAsBytes();
    final file = File(filePath);
    if (mimeType != null && mimeType.startsWith('image/')) {
      final image = img.decodeImage(Uint8List.fromList(bytes!));

      if (image == null) throw BadRequestException('Invalid image');

      final compressedBytes = img.encodeJpg(
        image,
        quality: 70,
      );

      await file.writeAsBytes(compressedBytes);
      return file;
    }
    await file.writeAsBytes(bytes!);
    return file;
  }

  Future<CloudinaryResponse?> uploadFile({
    File? uploadedFile,
    String? folder,
    List<int>? fileBytes,
    String? userId,
    CloudinaryResourceType? resourceType,
  }) async {
    try {
      final result = await cloudinary.upload(
        file: uploadedFile?.path,
        fileBytes: fileBytes ?? uploadedFile?.readAsBytesSync(),
        fileName: '${DateTime.now().millisecondsSinceEpoch}_$userId',
        folder: folder ?? 'images',
        resourceType: resourceType ?? CloudinaryResourceType.auto,
      );
      if (result.isSuccessful) {
        return result;
      }
    } catch (e) {
      throw BadRequestException(e.toString());
    }
    return null;
  }
}
