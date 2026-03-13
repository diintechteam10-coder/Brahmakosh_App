import 'dart:developer' as developer;
import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:brahmakosh/common/models/astrologist_model.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'voice_call_view.dart'; // Added VoiceCallView import
import 'package:brahmakosh/core/services/storage_service.dart';

class AstrologyExpertsView extends StatelessWidget {
  final String? screenTitle;
  final ScrollController? scrollController;

  const AstrologyExpertsView({
    super.key,
    this.screenTitle,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller =
        Get.isRegistered<AstrologyController>()
        ? Get.find<AstrologyController>()
        : Get.put(AstrologyController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0), // Gold background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE6D0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Connect",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 20,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.textPrimary),
            onPressed: () => controller.openHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildSearchBar(context, controller),
          ),
          const SizedBox(height: 10),

          // Categories / Filters
          Padding(
            padding: const EdgeInsets.only(bottom: 4),

            child: SizedBox(
              height: 35,
              child: Obx(() {
                // Ensure "All" is always first
                final allCategories = [
                  {'name': 'All', '_id': 'all'},
                  ...controller.categories,
                ];

                // Access selectedCategoryId here to register dependency with Obx
                final selectedId = controller.selectedCategoryId;

                return ListView.builder(
                  controller: controller.categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final id = cat['_id'];
                    final name = cat['name'];
                    final isSelected = selectedId == id;

                    return _buildFilterChip(
                      context,
                      name,
                      id,
                      isSelected,
                      controller,
                      index,
                    );
                  },
                );
              }),
            ),
          ),

          // Expert List
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryGold,
              onRefresh: controller.refreshExperts,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildExpertCardShimmer(),
                  );
                }

                final list = controller.filteredExperts;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No experts found',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    top: 8,
                    right: 16, // Fixed indentation
                    bottom: 20 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildExpertCard(context, list[index], controller);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AstrologyController controller) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        style: GoogleFonts.inter(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textPrimary),
          filled: false, // Prevent double background
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String id,
    bool isSelected,
    AstrologyController controller,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          controller.selectCategory(id);
          // Scroll to position (simple implementation: scroll to index * approx width)
          // For exact "first position", we'd need keys or a specific package.
          // Here we try to center it or move it to start.
          double offset = index * 100.0; // Approx width + margin
          if (index > 0) offset -= 10; // Adjust for padding

          controller.categoryScrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryGold
                : Colors.transparent, // Dark gold for selected
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : const Color(0xFFA67C00).withOpacity(0.5),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF5D4037),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertCard(
    BuildContext context,
    AstrologistItem expert,
    AstrologyController controller,
  ) {
    // ── Partner detail logs ──
    developer.log(
      '🔍 [Partner Details] '
      'id: ${expert.id}, '
      'name: ${expert.name}, '
      'status: ${expert.status}, '
      'experience: ${expert.experience}, '
      'expertise: ${expert.expertise}, '
      'profilePhoto: ${expert.profilePhoto}, '
      'profileSummary: ${expert.profileSummary}, '
      'chatCharge: ${expert.chatCharge}, '
      'voiceCharge: ${expert.voiceCharge}, '
      'videoCharge: ${expert.videoCharge}, '
      'rating: ${expert.rating}, '
      'reviews: ${expert.reviews}, '
      'languages: ${expert.languages}, '
      'categoryId: ${expert.categoryId}, '
      'isActive: ${expert.isActive}',
      name: 'AstrologyExpertsView',
    );

    final hasProfilePhoto =
        expert.profilePhoto != null && expert.profilePhoto!.isNotEmpty;
    // Use lowercase for comparison to be safe
    final status = expert.status?.toLowerCase() ?? 'offline';
    final isOnline = status == 'online';
    final isBusy = status == 'busy';

    // Status Color & Text
    Color statusColor = Colors.grey;
    String statusText = "Offline";

    if (isOnline) {
      statusColor = Colors.green;
      statusText = "Available";
    } else if (isBusy) {
      statusColor = Colors.orange;
      statusText = "Busy";
    }

    // Skills processing
    final skills = expert.expertise != null && expert.expertise!.isNotEmpty
        ? expert.expertise!
              .split(',')
              .map((e) => "• ${e.trim()}")
              .take(2)
              .join("   ")
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0), // Light cream card background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.lightGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => controller.navigateToProfile(expert),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Avatar + Status
                Column(
                  children: [
                    Stack(
                      children: [
                        hasProfilePhoto
                            ? Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(expert.profilePhoto!),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              )
                            : Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFA67C00),
                                    ], // Gold Gradient
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFA67C00,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Right Column: Details + Buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name ?? 'Astrologer',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${expert.experience ?? '0'} Years Exp.",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skills,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.chat_bubble_outline,
                              price: expert.chatCharge?.toString() ?? "20",
                              onTap: () {
                                final status =
                                    expert.status?.toLowerCase() ?? 'offline';
                                if (status != 'online') {
                                  _showExpertOfflineDialog(context);
                                  return;
                                }
                                _showChatConfirmationBottomSheet(
                                  context,
                                  expert,
                                  controller,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.phone_outlined,
                              price: expert.voiceCharge?.toString() ?? "20",
                              onTap: () {
                                final status =
                                    expert.status?.toLowerCase() ?? 'offline';
                                if (status != 'online') {
                                  _showExpertOfflineDialog(context);
                                  return;
                                }

                                final hasInit =
                                    StorageService.getBool(
                                      'chat_initiated_${expert.id}',
                                    ) ??
                                    false;
                                if (!hasInit) {
                                  _showInitiateChatFirstDialog(context);
                                } else {
                                  _showVoiceCallConfirmationBottomSheet(
                                    context,
                                    expert,
                                    controller,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.videocam_outlined,
                              price: expert.videoCharge?.toString() ?? "20",
                              onTap: () => _showComingSoonSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFA67C00),
            width: 1,
          ), // Gold/Brown border
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(
            0,
            255,
            255,
            255,
          ), // Transparant or very light fill
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFA67C00)),
            const SizedBox(width: 4),
            Text(
              "₹$price/min",
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA67C00),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatConfirmationBottomSheet(
    BuildContext context,
    AstrologistItem expert,
    AstrologyController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFE0B2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble,
                color: Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "START CHAT CONSULTATION",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You're about to start a live chat session with ${expert.name ?? 'your chosen Expert'}.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black12, thickness: 1),
            const SizedBox(height: 16),
            Text(
              "Connect with an astrologer or guru through live chat and end the session at any time - credits are deducted only for the minutes used, so please ensure a stable internet connection for a smooth experience.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "This session will deduct ₹${expert.chatCharge ?? 15} per minute",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Would you like to continue?",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF8B6914)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B6914),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      if (profileVM.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFA67C00),
                            ),
                          ),
                        );
                      }
                      return ElevatedButton(
                        onPressed: () {
                          // Read credits BEFORE dismissing the sheet
                          final credits = profileVM.profile?.credits ?? 0;
                          final minRequired =
                              (expert.chatCharge ?? 15) *
                              5; // Enforce 5 mins minimum

                          Navigator.pop(context);

                          if (credits >= minRequired) {
                            StorageService.setBool(
                              'chat_initiated_${expert.id}',
                              true,
                            );
                            controller.startChat(expert);
                          } else {
                            // Optional: Show snackbar explaining why
                            Get.snackbar(
                              "Insufficient Credits",
                              "You need at least ₹$minRequired for a 5-minute session with this expert.",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            controller.showRechargeBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFA67C00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "CONTINUE",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showVoiceCallConfirmationBottomSheet(
    BuildContext context,
    AstrologistItem expert,
    AstrologyController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFE0B2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone_in_talk,
                color: Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "VOICE CONSULTATION",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You're about to start a voice call session with ${expert.name ?? 'your chosen Expert'}.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black12, thickness: 1),
            const SizedBox(height: 16),
            Text(
              "Connect with an astrologer or guru through a live audio call and end the session at any time - credits are deducted only for the minutes used, so please ensure a stable internet connection for a smooth experience.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "This session will deduct ₹${expert.voiceCharge ?? 20} per minute",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Would you like to continue?",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF8B6914)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B6914),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      if (profileVM.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFA67C00),
                            ),
                          ),
                        );
                      }
                      return ElevatedButton(
                        onPressed: () {
                          // Read credits BEFORE dismissing the sheet
                          final credits = profileVM.profile?.credits ?? 0;
                          final minRequired =
                              (expert.voiceCharge ?? 20) *
                              5; // Enforce 5 mins minimum

                          Navigator.pop(context);

                          if (credits >= minRequired) {
                            Get.to(
                              () =>
                                  VoiceCallView(expert: expert.toAstrologist()),
                            );
                          } else {
                            Get.snackbar(
                              "Insufficient Credits",
                              "You need at least ₹$minRequired for a 5-minute session with this expert.",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            controller.showRechargeBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFA67C00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "CONTINUE",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showExpertOfflineDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Expert Offline",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "This expert is currently offline. Please try again later.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "OK",
              style: GoogleFonts.inter(
                color: const Color(0xFFA67C00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInitiateChatFirstDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Chat Required",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Please initiate a chat with the expert first before making a call.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "OK",
              style: GoogleFonts.inter(
                color: const Color(0xFFA67C00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFE0B2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Color(0xFFA67C00),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Coming Soon!",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This feature will be available soon. Stay tuned!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFFA67C00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "OK",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
