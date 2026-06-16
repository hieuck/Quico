import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalFileStorage {
  Future<String> get basePath async {
    final dir = await getApplicationDocumentsDirectory();
    final quicoDir = Directory(p.join(dir.path, 'quico'));
    if (!await quicoDir.exists()) {
      await quicoDir.create(recursive: true);
    }
    return quicoDir.path;
  }

  Future<String> copyImageToLocal(String sourcePath, String fileName) async {
    final base = await basePath;
    final imagesDir = Directory(p.join(base, 'images', 'products'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final destPath = p.join(imagesDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> imageExists(String path) async {
    final file = File(path);
    return await file.exists();
  }
}
