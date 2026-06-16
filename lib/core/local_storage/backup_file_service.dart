import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupFileService {
  Future<String> saveBackupFile(String fileName, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'quico', 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final filePath = p.join(backupDir.path, fileName);
    await File(filePath).writeAsString(content);
    return filePath;
  }

  Future<String> readBackupFile(String filePath) async {
    return await File(filePath).readAsString();
  }

  Future<String> copyDatabaseFile(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'quico', 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final fileName = 'quico_backup_${DateTime.now().millisecondsSinceEpoch}.db';
    final destPath = p.join(backupDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }
}
