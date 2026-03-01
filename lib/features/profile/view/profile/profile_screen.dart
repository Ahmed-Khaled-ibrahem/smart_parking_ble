
import 'package:smart_parking_ble/features/profile/model/user_profile.dart';
import 'package:smart_parking_ble/features/profile/view/profile/widgets/action_dialog.dart';
import 'package:smart_parking_ble/features/profile/view/profile/widgets/profile_card.dart';
import 'package:smart_parking_ble/features/profile/view/profile/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/helpers/dialogs/confirmation_dialog.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../controller/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final user = ref.watch(authControllerProvider);
    final profileCtrl = ref.watch(profileControllerProvider);

    return Builder(
      builder: (context) {
        if (user.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.push('/settings');
                },
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ProfileCard(),
                  const SizedBox(height: 20),
                  ProfileMenu(
                    text: "Portfolio",
                    icon: "assets/icons/portfolio.png",
                    visible: profileCtrl.value?.role == UserRole.engineer,
                    press: () {
                      if (profileCtrl.value == null) {
                        return;
                      }
                      context.push('/portfolio', extra: profileCtrl.value!.id);
                    },
                  ),
                  ProfileMenu(
                    text: "I.electrony Store",
                    icon: "assets/icons/portfolio.png",
                    visible: profileCtrl.value?.role != UserRole.admin,
                    press: () {
                      // openUrl();
                    },
                  ),
                  ProfileMenu(
                    text: "Join us",
                    icon: "assets/icons/join_us.png",
                    visible: profileCtrl.value?.role == UserRole.client,
                    press: () {
                      context.push('/join-us');
                    },
                  ),
                  ProfileMenu(
                    text: "Engineers Requests",
                    icon: "assets/icons/join_us.png",
                    visible: profileCtrl.value?.role == UserRole.admin,
                    press: () {
                      context.push('/engineer-request-list');
                    },
                  ),
                  ProfileMenu(
                    text: "Help Center",
                    icon: "assets/icons/help-center.png",
                    press: () {
                      context.push('/help-center');
                    },
                  ),
                  ProfileMenu(
                    text: "Invite friends",
                    icon: "assets/icons/invite.png",
                    press: () {
                      // shareText(
                      //   playStoreUrl: '',
                      //   appStoreUrl: '',
                      // );
                    },
                  ),
                  // ProfileMenu(
                  //   text: "Feedback",
                  //   icon: "assets/icons/feedback.png",
                  //   press: () async {
                  //     // context.push('/client-feedback');
                  //     final InAppReview inAppReview = InAppReview.instance;
                  //
                  //     if (await inAppReview.isAvailable()) {
                  //       inAppReview.requestReview(
                  //
                  //       );
                  //     }
                  //   },
                  // ),
                  // ProfileMenu(
                  //   text: "Clients Feedback",
                  //   icon: "assets/icons/feedback.png",
                  //   press: () {
                  //     context.push('/feedbacks');
                  //   },
                  // ),
                  ProfileMenu(
                    text: "Legal",
                    icon: "assets/icons/legal.png",
                    press: () {
                      showActionDialog(context);
                    },
                  ),
                  ProfileMenu(
                    text: "Log Out",
                    icon: "assets/icons/logout.png",
                    press: () async {
                      bool? yes = await ConfirmationDialog.show(
                        context: context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                      );
                      if (yes == true) {
                        await authController.signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

//   void shareText({String? playStoreUrl, String? appStoreUrl}) {
//     String message =
//         """
// Hey! I’m using ielectronyhub and I think you’ll love it too!
// Download it now:
// Android: ${playStoreUrl ?? 'soon'}
// iOS: ${appStoreUrl ?? 'soon'}
// """;
//     SharePlus.instance.share(ShareParams(text: message));
//   }
}
