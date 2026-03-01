import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../types/file_type.dart';

final onlineStorageServiceProvider = Provider<OnlineStorageService>((ref) {
  return OnlineStorageService(FirebaseStorage.instance);
});

class OnlineStorageService {
  final FirebaseStorage _storage;

  OnlineStorageService(this._storage);

  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required FileType fileType,
    Function(double)? onProgress,
  }) async {
    final file = File(filePath);
    final fileExt = fileName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_$fileName';

    // Organize files by date
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;
    final currentDay = DateTime.now().day;

    final storagePath =
        '${fileType.folder}/$currentYear/$currentMonth/$currentDay/$uniqueFileName';

    final ref = _storage.ref().child(storagePath);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: _getContentType(fileExt)),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            snapshot.bytesTransferred / snapshot.totalBytes.toDouble();
        onProgress(progress);
      });
    }

    await uploadTask;

    return storagePath;
  }

  Future<String> getFileUrl(String storagePath, FileType fileType) async {
    final ref = _storage.ref().child(storagePath);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String storagePath, FileType fileType) async {
    final ref = _storage.ref().child(storagePath);
    await ref.delete();
  }

  Future<List<String>> listFiles(FileType fileType) async {
    final ref = _storage.ref().child(fileType.folder);

    final result = await ref.listAll();
    return result.items.map((item) => item.name).toList();
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}