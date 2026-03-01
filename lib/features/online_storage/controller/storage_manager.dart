import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/helpers/images/image_compresor.dart';
import '../service/storage_service.dart';
import '../types/file_type.dart';

final storageManagerProvider = Provider<StorageManager>((ref) {
  final storageService = ref.read(onlineStorageServiceProvider);
  // final storageService = ref.read(legacyStorageServiceProvider);
  return StorageManager(storageService);
});

class StorageManager {
  StorageManager(this._storageService);

  final OnlineStorageService _storageService;

  // ---------- IMAGE ----------
  Future<String?> uploadImage(
    File file,
    String fileName,
    Function(double) onProgress, {
    bool compress = false,
    bool isProfile = false,
  }) async {
    String compressedPath = '';
    if (compress) {
      final ImageCompressionService imageCompressionService =
          ImageCompressionService();

      final compressedImage = await imageCompressionService.compress(
        file: file,
        type: isProfile? AppImageType.thumbnail : AppImageType.normal,
      );
      compressedPath = compressedImage!.path;
    }
    return await _upload(
      filePath: compress ? compressedPath : file.path,
      fileName: fileName,
      fileType: isProfile ? FileType.profile: FileType.image,
      onProgress: onProgress,
    );
  }

  // ---------- VIDEO ----------
  Future<String?> uploadVideo(String path, String fileName, onProgress) async {
    return await _upload(
      filePath: path,
      fileName: fileName,
      fileType: FileType.video,
      onProgress: onProgress,
    );
  }

  // ---------- AUDIO ----------
  Future<String?> uploadAudio(String path, String fileName, onProgress) async {
    return await _upload(
      filePath: path,
      fileName: fileName,
      fileType: FileType.audio,
      onProgress: onProgress,
    );
  }

  // ---------- DOCUMENT ----------
  Future<String?> uploadDocument(
    String path,
    String fileName,
    onProgress,
  ) async {
    return await _upload(
      filePath: path,
      fileName: fileName,
      fileType: FileType.document,
      onProgress: onProgress,
    );
  }

  // ---------- ARCHIVE ----------
  Future<String?> uploadArchive(
    String path,
    String fileName,
    onProgress,
  ) async {
    return await _upload(
      filePath: path,
      fileName: fileName,
      fileType: FileType.archive,
      onProgress: onProgress,
    );
  }

  Future<String?> _upload({
    required String filePath,
    required String fileName,
    required FileType fileType,
    onProgress,
  }) async {
    try {
      final path = await _storageService.uploadFile(
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
        onProgress: (double progress) {
          print('Upload progress: $progress');
          onProgress?.call(progress);
        },
      );

      final url = await _storageService.getFileUrl(path, fileType);

      return url;
    } catch (e) {
      return null;
    }
  }
}
