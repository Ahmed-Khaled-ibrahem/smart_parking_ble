import 'dart:io';
import 'package:smart_parking_ble/app/helpers/dialogs/confirmation_dialog.dart';
import 'package:smart_parking_ble/app/helpers/inteactive/click_throttle.dart';
import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:smart_parking_ble/app/widgets/image_provider_widget.dart';
import 'package:smart_parking_ble/features/auth/controller/auth_controller.dart';
import 'package:smart_parking_ble/features/online_storage/controller/storage_manager.dart';
import 'package:smart_parking_ble/features/profile/controller/profile_controller.dart';
import 'package:smart_parking_ble/features/profile/model/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/helpers/toast/app_toast.dart';
import 'widgets/source_selector.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final saveChangedThrottler = ClickThrottler(
    duration: const Duration(seconds: 15),
  );
  final deleteButtonThrottler = ClickThrottler(
    duration: const Duration(seconds: 10),
  );
  bool isLoading = false;

  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final UserProfile? profile = ref
        .read(profileControllerProvider.notifier)
        .profile;

    _nameController = TextEditingController(text: profile?.name);
    _currentImageUrl = profile?.imageProfile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      await showModalBottomSheet(
        context: context,
        builder: (context) => SourceSelector(
          onFileSelected: (File? image) {
            setState(() {
              _selectedImage = image;
            });
          },
          onAvatarSelected: (String url) {
            setState(() {
              _currentImageUrl = url;
            });
          },
        ),
      );
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? (after clicking yes all your data will be removed permanently)',
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(profileControllerProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Account")),

        body: userProfileAsync.when(
          data: (profile) {
            return allProfileView(profile);
          },
          error: (error, stackTrace) {
            return Center(child: Text(error.toString()));
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget allProfileView(UserProfile? profile) {
    if (profile == null || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  displayImage(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.image, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.alternate_email,
                  label: 'Username',
                  value: profile.username ?? '----',
                  color: Colors.blueAccent,
                ),
                const Divider(height: 32, thickness: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: profile.email,
                  color: Colors.orangeAccent,
                ),
                const Divider(height: 32, thickness: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Date of Creation',
                  value: profile.createdAt.toLocal().toString().split(' ')[0],
                  color: Colors.greenAccent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Save Button
            ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Save Changes'),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            // Delete Account
            ElevatedButton.icon(
              onPressed: () {
                deleteButtonThrottler.call(() {
                  _deleteAccount();
                });
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text("Delete Account"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayImage() {
    final showBackground = _selectedImage != null;
    return Hero(
      tag: 'profile-avatar',
      child: CircleAvatar(
        radius: 60,
        backgroundImage: showBackground ? FileImage(_selectedImage!) : null,
        child: showBackground
            ? null
            : ClipOval(
                child: PersistentCachedImage(
                  url: _currentImageUrl ?? '',
                  userName: _nameController.text,
                ),
              ),
      ),
    );
  }

  void saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final profile = ref.read(profileControllerProvider.notifier).profile;
    if (profile == null) {
      return;
    }
    if (isSameData(
      profile,
      _nameController.text,
      _selectedImage,
      _currentImageUrl,
    )) {
      context.pop();
      return;
    }
    saveChangedThrottler(() async {
      setState(() {
        isLoading = true;
      });
      final profileCtrl = ref.read(profileControllerProvider.notifier);
      final storageCtrl = ref.read(storageManagerProvider);

      if (_selectedImage != null) {
        _currentImageUrl = await storageCtrl.uploadImage(
          _selectedImage!,
          'profile.png',
          (progress) {},
          compress: true,
          isProfile: true,
        );
      }

      await profileCtrl.updateProfile(
        profile.copyWith(
          name: _nameController.text.trim(),
          imageProfile: _currentImageUrl?.trim(),
        ),
      );

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        context.pop();
        return;
      }
    });
  }

  bool isSameData(
    UserProfile profile,
    String name,
    File? selectedImage,
    String? currentImageUrl,
  ) {
    if (selectedImage != null) {
      return false;
    }
    if (name.trim() != profile.name?.trim() ||
        currentImageUrl != profile.imageProfile?.trim()) {
      return false;
    }
    return true;
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
