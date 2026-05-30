import 'package:http/http.dart' as http;
import '../../core/api_client.dart';
import '../../core/download_service.dart';
import 'file_model.dart';

class FileService {
  final ApiClient api;
  final String sessionId;

  FileService(this.api, {required this.sessionId});

  bool get _hasSession => sessionId.isNotEmpty;

  Future<List<FileItem>> fetchFiles() async {
    final ep = _hasSession ? '/session/$sessionId/files' : '/files';
    final data = await api.get(ep);
    final List list = data['files'];
    return list.map((e) => FileItem.fromJson(e)).toList();
  }
}

extension FileDownload on FileService {
  Future<String> downloadFile(String filename) async {
    final ep = _hasSession
        ? '/session/$sessionId/download/$filename'
        : '/download/$filename';
    final url = Uri.parse('${api.baseUrl}$ep');

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Download failed ${res.statusCode}');
    }

    final file = await DownloadService.saveFile(filename, res.bodyBytes);
    return file.path;
  }
}

extension FileUpload on FileService {
  Future<void> uploadFile(String filePath) async {
    final ep = _hasSession
        ? '/session/$sessionId/upload'
        : '/upload';
    final uri = Uri.parse('${api.baseUrl}$ep');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    final streamed = await request.send();

    if (streamed.statusCode != 200) {
      throw Exception('Upload failed ${streamed.statusCode}');
    }
  }
}

