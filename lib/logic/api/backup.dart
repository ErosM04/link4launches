import 'dart:io';

import 'package:path_provider/path_provider.dart';

class BackupJsonManager {
  final String backupFile;
  final Function? onFileLoadSuccess;
  final Function? onFileLoadError;

  const BackupJsonManager({
    required this.backupFile,
    this.onFileLoadSuccess,
    this.onFileLoadError,
  });

  Future<String> loadFromFile({bool showSuccessSnackBar = true}) async {
    try {
      if (await existsJsonFile()) {
        if (showSuccessSnackBar && onFileLoadSuccess != null) {
          onFileLoadSuccess!();
        }
        return await readJsonFile();
      } else {
        throw Exception();
      }
    } on Exception catch (_) {}
    if (onFileLoadError != null) onFileLoadError!();
    return '';
  }

  Future<File> getJsonFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$backupFile');
  }

  Future<bool> existsJsonFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return (await File('${dir.path}/$backupFile').exists()) ? true : false;
  }

  Future<String> readJsonFile() async {
    final File file = await getJsonFile();
    return file.readAsString();
  }

  void writeJsonFile(String content) async {
    final File file = await getJsonFile();
    file.writeAsString(content);
  }
}
