import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PersistentCachedImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? userName;
  final String? placeHolder;

  const PersistentCachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.userName,
    this.placeHolder,
  });

  static ImageProvider provider(String url) {
    return CachedNetworkImageProvider(
      url,
      cacheManager: AppImageCacheManager.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty || url == '') {
      if (placeHolder == null) {
        return Image.asset('assets/icons/place_holder.png');
      }
      return Image.asset(placeHolder!);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      cacheManager: AppImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 1)),

      errorWidget: (_, __, ___) => LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          if (userName?.trim().isEmpty ?? true) {
            return Image.asset('assets/icons/place_holder.png');
          }
          return Center(
            child: Text(
              getInitials(userName),
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  String getInitials(String? fullName, {int maxLetters = 2}) {
    if (fullName == null || fullName.trim().isEmpty) {
      return '?';
    }

    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    final first = parts.first.characters.first;
    final second = (parts.length > 1 && maxLetters > 1)
        ? parts.last.characters.first
        : null;

    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(fullName);

    if (second == null) {
      return first.toUpperCase();
    }

    return isArabic
        ? '${first.toUpperCase()} ${second.toUpperCase()}' // Arabic → space
        : '${first.toUpperCase()}${second.toUpperCase()}'; // English → no space
  }
}

class AppImageCacheManager extends CacheManager {
  static const key = 'appImageCache';

  static final AppImageCacheManager instance = AppImageCacheManager._internal();

  AppImageCacheManager._internal()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 500,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: HttpFileService(),
        ),
      );
}
