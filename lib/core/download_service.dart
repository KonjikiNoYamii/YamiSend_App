import 'dart:io';

class DownloadService {
  static final Map<String, String> _typeDirs = {
    'jpg': 'Pictures',
    'jpeg': 'Pictures',
    'png': 'Pictures',
    'gif': 'Pictures',
    'webp': 'Pictures',
    'svg': 'Pictures',
    'bmp': 'Pictures',
    'mp4': 'Movies',
    'mkv': 'Movies',
    'avi': 'Movies',
    'mov': 'Movies',
    'wmv': 'Movies',
    'mp3': 'Music',
    'wav': 'Music',
    'aac': 'Music',
    'ogg': 'Music',
    'flac': 'Music',
    'pdf': 'Documents',
    'doc': 'Documents',
    'docx': 'Documents',
    'xls': 'Documents',
    'xlsx': 'Documents',
    'ppt': 'Documents',
    'pptx': 'Documents',
    'txt': 'Documents',
    'zip': 'Documents',
    'rar': 'Documents',
  };

  static String _baseDir = '/storage/emulated/0';

  static String _dirFor(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return _typeDirs[ext] ?? 'Download';
  }

  static Future<Directory> getTargetDir(String filename) async {
    final sub = _dirFor(filename);
    final dir = Directory('$_baseDir/$sub/YamiSend');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  static Future<bool> isDownloaded(String filename) async {
    final dir = await getTargetDir(filename);
    return File('${dir.path}/$filename').exists();
  }

  static Future<File> saveFile(String filename, List<int> bytes) async {
    final dir = await getTargetDir(filename);
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}
