import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class SourceSelector extends ConsumerStatefulWidget {
  final Function(File? image) onFileSelected;
  final Function(String url) onAvatarSelected;

  const SourceSelector({
    super.key,
    required this.onFileSelected,
    required this.onAvatarSelected,
  });

  @override
  ConsumerState createState() => _SourceSelectorState();
}

class _SourceSelectorState extends ConsumerState<SourceSelector> {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Upload from Gallery'),
            onTap: () async {
              context.pop();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                widget.onFileSelected(File(image.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () async {
              context.pop();

              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 90,
              );

              if (image != null) {
                widget.onFileSelected(File(image.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.face),
            title: const Text('Select Avatar'),
            onTap: () {
              context.pop();
              // _showAvatarSelectionDialog();
            },
          ),
        ],
      ),
    );
  }
}
