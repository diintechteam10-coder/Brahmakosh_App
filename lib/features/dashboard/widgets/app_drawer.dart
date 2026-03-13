import '../../../../core/common_imports.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/utils.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../profile/views/profile_details_view.dart';
import '../../profile/views/update_profile_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../agent/lemon_agent_page.dart';
import '../../astrology/views/credit_history_view.dart';
import '../../../common/widgets/profile_image_view.dart';
import '../../wallet/views/recharge_plans_view.dart';
import '../../sankalp/views/sankalp_screen.dart';
import '../../pooja/views/pooja_list_screen.dart';
import '../../swapna_decoder/views/swapna_decoder_screen.dart';
import '../../support/views/help_support_view.dart';
import '../../support/views/about_us_view.dart';
import '../../../common/widgets/custom_profile_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.landingBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Consumer<ProfileViewModel>(
                  builder: (context, viewModel, child) {
                    final profile = viewModel.profile;
                    final user = profile?.profile;

                    return SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER: Back Arrow & Title
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xff5D4037),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Profile",
                                  style: GoogleFonts.lora(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff5D4037),
                                  ),
                                ),
                                const Spacer(),
                                // Edit Icon Moved Here
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.to(() => const UpdateProfileView());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 255, 245, 245),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 22, // Matched to text size
                                      color: Color(0xff5D4037),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// PROFILE SECTION
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                // Profile Image
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (profile?.profileImageUrl != null) {
                                          _showProfileOptions(
                                            context,
                                            profile!.profileImageUrl!,
                                            viewModel,
                                          );
                                        } else {
                                          // Directly open edit sheet if no image
                                          _showImageSourceSheet(
                                            context,
                                            viewModel,
                                          );
                                        }
                                      },
                                      child: Hero(
                                        tag: 'profile_pic_drawer',
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: CustomProfileAvatar(
                                            imageUrl: profile?.profileImageUrl,
                                            radius: 35.0,
                                            borderWidth: 0.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _showImageSourceSheet(
                                          context,
                                          viewModel,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 14,
                                            color: Color(0xff5D4037),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'User',
                                        style: GoogleFonts.lora(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xff5D4037),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profile?.email ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile?.mobile ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Divider(height: 1, color: Colors.black12),
                          const SizedBox(height: 10),

                          /// ITEMS LIST
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // PREFERENCES
                                  _sectionHeader("Preferences"),
                                  _menuItem(
                                    icon: Icons.person_outline,
                                    label: "My Profile",
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.to(() => const ProfileDetailsView());
                                    },
                                  ),
                                  _languageRow(context),

                                  const SizedBox(height: 16),

                                  // KARMA POINTS
                                  _karmaPointsCard(
                                    context,
                                    profile?.karmaPoints ?? 0,
                                  ),

                                  const SizedBox(height: 16),

                                  // CREDIT WALLET
                                  _creditWalletCard(
                                    context,
                                    profile?.credits ?? 0,
                                  ),

                                  const SizedBox(height: 16),

                                  // SANKALP SECTION
                                  _sectionHeader("Sankalp"),
                                  _menuItem(
                                    icon: Icons.spa_outlined,
                                    label: "My Sankalp",
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.to(() => const SankalpScreen());
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // POOJA PADHATTI SECTION
                                  _sectionHeader("Pooja Padhatti"),
                                  _menuItem(
                                    icon: Icons.temple_hindu_outlined,
                                    label: "Pooja Vidhi",
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.to(() => const PoojaListScreen());
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // SWAPNA DECODER SECTION
                                  _sectionHeader("Swapna Decoder"),
                                  _menuItem(
                                    icon: Icons.nightlight_round_outlined,
                                    label: "Swapna Decoder",
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.to(() => const SwapnaDecoderScreen());
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // OTHERS
                                  _sectionHeader("Others"),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _menuItem(
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        label: "My Kosh",
                                        onTap: () {
                                          Navigator.pop(context);
                                          Provider.of<DashboardViewModel>(
                                            context,
                                            listen: false,
                                          ).changeTab(5);
                                        },
                                      ),
                                      _menuItem(
                                        icon: Icons.shopping_cart_outlined,
                                        label: "Orders",
                                        onTap: () {
                                          _showComingSoonPopup(
                                            context,
                                            "Orders",
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        icon: Icons.receipt_long_outlined,
                                        label: "Credit History",
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.to(
                                            () => const CreditHistoryView(),
                                          );
                                        },
                                      ),
                                      // _menuItem(
                                      //   icon: Icons.bookmark_outline,
                                      //   label: "My Reports",
                                      //   onTap: () {},
                                      // ),
                                      _menuItem(
                                        icon: Icons.face_unlock_outlined,
                                        label: "Avatar Agent",
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.to(() => const AvatarAgentPage());
                                        },
                                      ),
                                      // _menuItem(
                                      //   icon: Icons.settings_outlined,
                                      //   label: "Settings",
                                      //   onTap: () {
                                      //     _showComingSoonPopup(
                                      //       context,
                                      //       "Settings",
                                      //     );
                                      //   },
                                      // ),
                                      
                                      
                                      _menuItem(
                                        icon: Icons.help_outline,
                                        label: "Help & Support",
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.to(() => const HelpSupportView());
                                        },
                                      ),
                                      _menuItem(
                                        icon: Icons.info_outline,
                                        label: "About Us",
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.to(() => const AboutUsView());
                                        },
                                      ),
                                      _menuItem(
                                        icon: Icons.delete_outline,
                                        label: "Delete Account",
                                        onTap: () {
                                          Navigator.pop(context);
                                          _launchDeleteAccountEmail(
                                            context,
                                            profile?.email ?? '',
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // ACCOUNT OPTION
                                  //_sectionHeader("Account Option"),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      await StorageService.setBool(
                                        AppConstants.keyIsLoggedIn,
                                        false,
                                      );
                                      await StorageService.remove(
                                        AppConstants.keyAuthToken,
                                      );
                                      await StorageService.remove(
                                        AppConstants.keyUserId,
                                      );
                                      Get.offAllNamed(AppConstants.routeLogin);
                                    },
                                    child: Container(
                                      height: 36,
                                      width: 110, // Reduced width
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .landingButton, // Updated color
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.landingButton
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.logout,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Logout",
                                            style: GoogleFonts.lora(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title,
        style: GoogleFonts.lora(
          fontSize: 15, // Reduced font size
          fontWeight: FontWeight.bold,
          color: const Color(0xff5D4037),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xff5D4037),
              size: 22,
            ), // Reduced size
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lora(
                  fontSize: 15, // Reduced font size
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff4E342E),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xff8D6E63), size: 18),
          ],
        ),
      ),
    );
  }

  void _showComingSoonPopup(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryGold),
            const SizedBox(width: 10),
            Text(
              "Coming Soon",
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5D4037),
              ),
            ),
          ],
        ),
        content: Text(
          "The $featureName feature is currently under development and will be available in a future update. Stay tuned!",
          style: GoogleFonts.lora(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Okay",
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchDeleteAccountEmail(
      BuildContext context, String userEmail) async {
    const recipient = 'contact@brahmakosh.com';
    const subject = 'Account Deletion Request - Brahmakosh App';
    final body =
        'Dear Brahmakosh Team,\n\n'
        'I would like to request the deletion of my account associated with the following email address:\n\n'
        'Registered Email: $userEmail\n\n'
        'Please delete my account and all associated data from your platform.\n\n'
        'Thank you.\n';

    final Uri emailLaunchUri = Uri.parse(
      'mailto:$recipient?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open Mail app. Please email contact@brahmakosh.com directly.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Could not launch email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open Mail app. Please email contact@brahmakosh.com directly.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _languageRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
      child: InkWell(
        onTap: () => _showComingSoonPopup(context, "Change Language"),
        child: Row(
          children: [
            const Icon(Icons.translate, color: Color(0xff5D4037), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Change Language",
                style: GoogleFonts.lora(
                  fontSize: 15, // Reduced font size
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff4E342E),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [_langOption("En", true), _langOption("Hi", false)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffFFCC80) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.lora(
          fontSize: 11, // Reduced font size
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }

  Widget _karmaPointsCard(BuildContext context, int points) {
    return InkWell(
      onTap: () {
        // Future functionality
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 245, 245),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff5D4037).withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Part
                Text(
                  "Karma Wallet",
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5D4037),
                  ),
                ),
                const SizedBox(height: 8),
                // Number Part
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff5D4037).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$points", // Display real points
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your Karma Points",
                  style: GoogleFonts.lora(
                    fontSize: 10,
                    color: const Color(0xff5D4037).withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Redeem Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close drawer
                Get.toNamed(AppConstants.routeRedeem);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 233, 130, 11),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Redeem",
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creditWalletCard(BuildContext context, int credits) {
    return InkWell(
      onTap: () {
        // Future functionality
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            245,
            255,
            245,
          ), // Slightly different background for distinction
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff5D4037).withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Part
                Text(
                  "Credit Wallet",
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5D4037),
                  ),
                ),
                const SizedBox(height: 8),
                // Number Part
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff5D4037).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$credits", // Display real credits
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your Credit Points",
                  style: GoogleFonts.lora(
                    fontSize: 10,
                    color: const Color(0xff5D4037).withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Redeem Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const RechargePlansView());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff4CAF50), // Green for credits
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Add Credit",
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(
    BuildContext context,
    String imageUrl,
    ProfileViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xff5D4037),
                radius: 20,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(
                'View Profile Picture',
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.to(
                  () => ProfileImageView(
                    imageUrl: imageUrl,
                    heroTag: 'profile_pic_drawer',
                  ),
                  transition: Transition.fadeIn,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xff5D4037),
                radius: 20,
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
              title: Text(
                'Edit Profile Picture',
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showImageSourceSheet(context, viewModel);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 150,
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                if (image != null) {
                  viewModel.uploadProfileImage(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (image != null) {
                  viewModel.uploadProfileImage(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
