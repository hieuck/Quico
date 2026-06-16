import 'dart:io';
import 'package:path/path.dart' as p;
import 'local_file_storage.dart';

class ImageStorageService {
  final LocalFileStorage _fileStorage;

  ImageStorageService(this._fileStorage);

  Future<String?> saveProductImage(String sourcePath, String productId) async {
    try {
      final ext = p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
      final fileName = '$productId$ext';
      return await _fileStorage.copyImageToLocal(sourcePath, fileName);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteProductImage(String imagePath) async {
    await _fileStorage.deleteImage(imagePath);
  }

  Future<bool> imageExists(String imagePath) async {
    return await _fileStorage.imageExists(imagePath);
  }
}
