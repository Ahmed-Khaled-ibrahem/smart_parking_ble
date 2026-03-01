import 'dart:io';
import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:smart_parking_ble/features/online_storage/controller/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../app/helpers/errors/error_mapper.dart';
import '../../../../app/helpers/inteactive/click_throttle.dart';
import '../../../../app/helpers/toast/app_toast.dart';
import '../../../../app/helpers/validators/birthday_validator.dart';
import '../../../../app/helpers/validators/username_validator.dart';
import '../../../../app/widgets/image_provider_widget.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../controller/profile_controller.dart';
import '../../model/user_profile.dart';
import '../account/widgets/source_selector.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _selectedBirthDate;
  Gender _selectedGender = Gender.male;
  String? imageUrl;
  File? selectedImage;
  final _formKey = GlobalKey<FormState>();
  ClickThrottler clickThrottler = ClickThrottler(
    duration: const Duration(seconds: 4),
  );
  double uploadProgress = 0;
  bool loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      await showModalBottomSheet(
        context: context,
        builder: (context) => SourceSelector(
          onFileSelected: (File? image) {
            setState(() {
              selectedImage = image;
            });
          },
          onAvatarSelected: (String url) {
            setState(() {
              imageUrl = url;
            });
          },
        ),
      );
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Future<String?> uploadAndGetLink() async {
    if (selectedImage == null) {
      return imageUrl;
    }

    if (selectedImage == null) {
      return null;
    }

    final storageManager = ref.read(storageManagerProvider);
    String? link = await storageManager.uploadImage(
      selectedImage!,
      'profile.png',
      (double val) {
        setState(() {
          uploadProgress = val;
        });
      },
      compress: true,
      isProfile: true,
    );

    return link;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    final profile = ref.watch(profileControllerProvider);
    final profileCtrl = ref.watch(profileControllerProvider.notifier);
    final authCtrl = ref.watch(authControllerProvider.notifier);

    ref.listen(profileControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (profile) {
          if (profile == null) return;
          if (profile.name == null || profile.name!.isEmpty) {
            return;
          }
          switch (profile.role) {
            case UserRole.client:
              context.go('/client-home');
              break;
            case UserRole.engineer:
              context.go('/engineer-home');
              break;
            case UserRole.admin:
              context.go('/admin-home');
              break;
          }
        },
      );
    });

    return profile.when(
      data: (UserProfile? data) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (c, p) {
                  if (loading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/creating_profile.json'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox.square(
                                dimension: 20,
                                child: const CircularProgressIndicator(
                                  color: AppColors.blue,
                                  strokeWidth: 1,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Creating profile ...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LinearProgressIndicator(
                              value: uploadProgress,
                              color: AppColors.blue,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Setup Profile',
                            style: TextStyle(
                              fontSize: height * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete your details to get started',
                            style: TextStyle(
                              fontSize: height * 0.02,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Profile Image
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: selectedImage != null
                                        ? FileImage(selectedImage!)
                                        : null,
                                    child: selectedImage != null
                                        ? null
                                        : ClipOval(
                                            child: PersistentCachedImage(
                                              url: imageUrl,
                                              userName: _nameController.text,
                                              placeHolder:
                                                  'assets/images/profile.png',
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Form Fields
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF252525)
                                  : Colors.grey[100],
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            validator: verifyUserName,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF252525)
                                  : Colors.grey[100],
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormField<DateTime>(
                            validator: verifyBirthDay,
                            builder: (FormFieldState<DateTime> field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().subtract(
                                          const Duration(days: 365 * 18),
                                        ),
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary: AppColors.blue,
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _selectedBirthDate = date;
                                        });
                                        field.didChange(date);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF252525)
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: field.hasError
                                              ? Colors.red.shade200
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_rounded,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _selectedBirthDate == null
                                                ? 'Date of Birth'
                                                : DateFormat(
                                                    'MMM d, yyyy',
                                                  ).format(_selectedBirthDate!),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _selectedBirthDate == null
                                                  ? Colors.grey[600]
                                                  : (isDark
                                                        ? Colors.white
                                                        : Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// Error text
                                  if (field.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        left: 12,
                                      ),
                                      child: Text(
                                        field.errorText!,
                                        style: TextStyle(
                                          color: Colors.red.shade200,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Gender Selection
                          const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderCard(
                                  Gender.male,
                                  Icons.male_rounded,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGenderCard(
                                  Gender.female,
                                  Icons.female_rounded,
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Submit Button
                          ElevatedButton(
                            onPressed: () {
                              clickThrottler.call(() {
                                submit(profileCtrl, authCtrl);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.blue.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            child: const Text(
                              'Complete Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      error: (e, s) {
        return const Center(child: Text('Error'));
      },
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildGenderCard(Gender gender, IconData icon, bool isDark) {
    final isSelected = _selectedGender == gender;
    final color = gender == Gender.male ? AppColors.blue : AppColors.pink;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? const Color(0xFF252525) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              gender.name.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future submit(ProfileController profileCtrl, AuthController authCtrl) async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      final username = _usernameController.text.trim().toLowerCase();
      if (await profileCtrl.isUserNameExists(username)) {
        AppToast.error('Username already exists');
        return;
      }
      setState(() {
        loading = true;
      });
      final imageUrl = await uploadAndGetLink();

      await profileCtrl.createNewUserProfile(
        UserProfile(
          id: authCtrl.authRepo.currentUser!.uid,
          name: _nameController.text.trim(),
          email: authCtrl.authRepo.currentUser!.email ?? '',
          createdAt: DateTime.now(),
          dateOfBirth: _selectedBirthDate,
          imageProfile: imageUrl,
          username: username,
          role: UserRole.client,
          gender: _selectedGender,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e, s) {
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
      setState(() {
        loading = false;
      });
    }
  }
}
