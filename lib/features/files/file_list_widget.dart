import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'file_service.dart';
import 'file_model.dart';

class FileListWidget extends StatefulWidget {
  final FileService service;

  const FileListWidget({super.key, required this.service});

  @override
  State<FileListWidget> createState() => _FileListWidgetState();
}

class _FileListWidgetState extends State<FileListWidget> {
  List<FileItem> files = [];
  bool loading = false;
  bool uploading = false;
  String? error;
  Set<String> downloading = {};

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      files = await widget.service.fetchFiles();
    } catch (e) {
      error = "Gagal memuat daftar file";
      files = [];
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> download(String name) async {
    setState(() => downloading.add(name));

    try {
      await widget.service.downloadFile(name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name berhasil diunduh"),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengunduh $name"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;
    setState(() => downloading.remove(name));
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.single.path == null) return;

    setState(() => uploading = true);

    try {
      await widget.service.uploadFile(result.files.single.path!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${result.files.single.name} berhasil diupload"),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengupload file"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;
    setState(() => uploading = false);
  }

  String formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }

  IconData iconForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
        return Icons.image;
      case 'mp4':
      case 'mkv':
      case 'avi':
      case 'mov':
        return Icons.movie;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
        return Icons.audiotrack;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
      case 'tar':
      case 'gz':
        return Icons.folder_zip;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "File di Server",
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            if (uploading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.upload),
                tooltip: "Upload file",
                onPressed: uploadFile,
              ),
            IconButton(
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: "Refresh",
              onPressed: loading ? null : load,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildBody(theme),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (loading && files.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && files.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: load,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              "Tidak ada file",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Upload file dari perangkat lain untuk memulai",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.separated(
        itemCount: files.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final f = files[index];
          final isDownloading = downloading.contains(f.name);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                iconForFile(f.name),
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            title: Text(
              f.name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Text(formatSize(f.size)),
                if (f.createdAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    "${f.createdAt!.day}/${f.createdAt!.month}/${f.createdAt!.year}",
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                ],
              ],
            ),
            trailing: isDownloading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: "Unduh",
                    color: theme.colorScheme.primary,
                    onPressed: () => download(f.name),
                  ),
          );
        },
      ),
    );
  }
}
