import 'package:smart_parking_ble/app/widgets/image_provider_widget.dart';
import 'package:smart_parking_ble/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileCard extends ConsumerStatefulWidget {
  const ProfileCard({super.key});

  @override
  ConsumerState createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    final profileCtr = ref.watch(profileControllerProvider);

    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: 'profile-avatar',
                child: CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: PersistentCachedImage(
                      url: profileCtr.value?.imageProfile ?? '',
                      userName: profileCtr.value?.name ?? '',
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -16,
                bottom: 0,
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      context.push('/account');
                    },
                    child: const Icon(Icons.edit),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          profileCtr.value?.name ?? '...',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 0),
        Text(
          "@${profileCtr.value?.username}",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
