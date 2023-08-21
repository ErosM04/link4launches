import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// This class can be used to manage (load, overwrite, read...) the backup json
/// file stored in the app directory, using ``[getApplicationDocumentsDirectory]``.
class BackupJsonManager {
  /// The name of the file with the extension, like ``name.json``.
  final String backupFile;

  /// The function to execute if the file is successfully loaded.
  final Function? onFileLoadSuccess;

  /// The function to execute if the file loading goes wrong.
  final Function? onFileLoadError;

  const BackupJsonManager({
    required this.backupFile,
    this.onFileLoadSuccess,
    this.onFileLoadError,
  });

  /// If the file exist loads it from the app directory and returns it as a String.
  ///
  /// #### Parameters
  /// - ``bool [showSuccessSnackBar]`` : if it's false ``[onFileLoadSuccess]`` won't be executed.
  ///
  /// #### Returns
  /// ``Future<String>`` : the file content as a String.
  Future<String> loadStringFromFile({bool showSuccessSnackBar = true}) async {
    try {
      if (await fileExists()) {
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

  /// Loads the json file from the app directory and returns a [File] object.
  ///
  /// #### Returns
  /// ``Future<File>`` : the [File] object of the loaded file.
  Future<File> _getJsonFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$backupFile');
  }

  /// Loads the json file from the app directory and returns a [File] object.
  ///
  /// #### Returns
  /// ``Future<File>`` : the [File] object of the loaded file.
  Future<bool> fileExists() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return (await File('${dir.path}/$backupFile').exists()) ? true : false;
  }

  /// Reads the file content using ``[_getJsonFile]`` and returns it as a String.
  ///
  /// #### Returns
  /// ``Future<String>`` : the content of the file.
  Future<String> readJsonFile() async {
    final File file = await _getJsonFile();
    return file.readAsString();
  }

  /// Loads the file using ``[_getJsonFile]`` and overwrites the original content with ``[content]``.
  /// Loads the If the file exist loads it from the app directory and returns it as a String.
  ///
  /// #### Parameters
  /// - ``String [content]`` : the text to write in the file.
  void writeJsonFile(String content) async {
    final File file = await _getJsonFile();
    file.writeAsString(content);
  }
}
