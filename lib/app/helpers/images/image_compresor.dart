import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum AppImageType { thumbnail, normal }

class ImageCompressionService {
  ImageCompressionService();

  Future<File?> compress({
    required File file,
    required AppImageType type,
  }) async {
    try {
      // Read the image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      final config = _configFor(type);

      // Calculate new dimensions maintaining aspect ratio
      final aspectRatio = image.width / image.height;
      int newWidth, newHeight;

      if (image.width > image.height) {
        // Landscape
        newWidth = config.maxDimension;
        newHeight = (newWidth / aspectRatio).round();
      } else {
        // Portrait or square
        newHeight = config.maxDimension;
        newWidth = (newHeight * aspectRatio).round();
      }

      // Resize image maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Compress and encode
      final compressed = img.encodeJpg(resized, quality: config.quality);

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(tempDir.path, _buildFileName(file, type));
      final newFile = File(targetPath);

      await newFile.writeAsBytes(compressed);

      return newFile;
    } catch (e) {
      return null;
    }
  }

  _ImageConfig _configFor(AppImageType type) {
    switch (type) {
      case AppImageType.thumbnail:
        return const _ImageConfig(
          maxDimension: 512,
          quality: 80,
        );
      case AppImageType.normal:
        return const _ImageConfig(
          maxDimension: 1080,
          quality: 75,
        );
    }
  }

  String _buildFileName(File file, AppImageType type) {
    final name = p.basenameWithoutExtension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${name}_${type.name}_$timestamp.jpg';
  }
}

class _ImageConfig {
  final int maxDimension;
  final int quality;

  const _ImageConfig({
    required this.maxDimension,
    required this.quality,
  });
}
