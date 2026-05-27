import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary/cloudinary.dart';
import 'package:dart_frog/dart_frog.dart';

import 'package:image/image.dart' as img;

import '../../exceptions/app_exceptions.dart';

class StorageService {
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();
  factory StorageService() => instance;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: "348455518921935",
    apiSecret: "ZefzaU_GDLvcpAOZqfTUwnhq3AU",
    cloudName: "drbwpijii",
  );

  Future<File?> compressFile({UploadedFile? uploadedFile}) async {
    final mimeType = uploadedFile?.contentType?.mimeType;

    final filePath =
        '${DateTime.now().millisecondsSinceEpoch}_${uploadedFile?.name}';
    final bytes = await uploadedFile?.readAsBytes();
    final file = File(filePath);
    if (mimeType != null && mimeType.startsWith('image/')) {
      final image = img.decodeImage(Uint8List.fromList(bytes!));

      if (image == null) throw BadRequestException("Invalid image");

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

  Future<CloudinaryResponse?> uploadFile(
      {File? uploadedFile,
      String? folder,
      CloudinaryResourceType? resourceType}) async {
    try {
      final result = await cloudinary.upload(
        file: uploadedFile?.path,
        fileBytes: uploadedFile?.readAsBytesSync(),
        fileName:
            "${DateTime.now().millisecondsSinceEpoch}_${uploadedFile?.path.split('.').first}",
        folder: folder ?? "images",
        resourceType: resourceType ?? CloudinaryResourceType.image,
      );
      if (result.isSuccessful) {
        return result;
      }
    } catch (e) {
      throw BadRequestException(e.toString());
    }
  }
}
