import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/check_in/views/prayer_configuration_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brahmakosh/features/check_in/blocs/check_in/check_in_bloc.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/common/utils.dart';

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'chanting_configuration_view.dart';
import 'package:brahmakosh/features/check_in/views/spiritual_stats_screen.dart';

class CheckInView extends StatefulWidget {
  final ScrollController? scrollController;

  const CheckInView({super.key, this.scrollController});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView>
    with TickerProviderStateMixin {
  // final CheckInController controller = Get.put(CheckInController()); // Removed
  int _currentStatIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentStatIndex = (_currentStatIndex + 1) % 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDateTimeFull(String? iso) {
    if (iso == null) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('h:mm a d.MM.yyyy').format(dt);
    } catch (e) {
      return "";
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (e) {
      return "";
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CheckInBloc(repository: SpiritualRepository())..add(LoadCheckIn()),
      child: BlocConsumer<CheckInBloc, CheckInState>(
        listener: (context, state) {
          if (state is CheckInNavigationAction) {
            // Dismiss loader
            if (Get.isDialogOpen == true) Get.back();

            if (state.arguments != null) {
              Get.toNamed(state.route, arguments: state.arguments);
            } else {
              Get.toNamed(state.route);
            }
          } else if (state is CheckInNavigationLoading) {
            // Show Custom White Loader
            Get.dialog(
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
              barrierDismissible: false,
            );
          } else if (state is CheckInError) {
            if (Get.isDialogOpen == true) Get.back();
            Utils.showToast(state.message);
          } else if (state is CheckInLoaded) {
            // Close any lingering dialogs if needed (e.g. from refresh)
            if (Get.isDialogOpen == true) Get.back();
          }
        },
        builder: (context, state) {
          if (state is CheckInLoading) {
            return const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CheckInError) {
            return SafeArea(child: Center(child: Text(state.message)));
          }

          Data? data;
          if (state is CheckInLoaded) {
            data = state.data;
          } else if (state is CheckInNavigationLoading) {
            data = state.previousState.data;
          } else if (state is CheckInNavigationAction) {
            data = state.previousState.data;
          }

          if (data == null) {
            // Fallback or Initial
            return const SafeArea(child: Center(child: Text("Loading...")));
          }

          return SafeArea(
            bottom: false,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffFFFDF8),
                    Color(0xffFFF2D9),
                    Color(0xffFFE4B5),
                  ],
                ),
              ),
              child: RefreshIndicator(
                color: const Color(0xff7B4A12),
                onRefresh: () async {
                  final completer = Completer<void>();
                  context.read<CheckInBloc>().add(RefreshCheckIn(completer));
                  return completer.future;
                },
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      // Header row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.history,
                                color: Color(0xff7B4A12),
                              ),
                              onPressed: () {
                                Get.to(() => const SpiritualStatsScreen());
                              },
                            ),
                            Text(
                              'BRAHMAKOSH',
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: const Color(0xff7B4A12),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Color(0xff7B4A12),
                              ),
                              onPressed: () {
                                if (data != null) {
                                  _shareCheckInDetails(context, data);
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // Main title & Subtitle
                      Text(
                        '#AreYouSpiritual',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff7B4A12),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Take a moment for yourself',
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),

                      // Check-In Options
                      if (data.activities != null &&
                          data.activities!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'CHECK-IN OPTIONS',
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff7B4A12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: data.activities!.map((activity) {
                              return SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width -
                                        80 -
                                        20) /
                                    2,
                                child: _card(
                                  image: activity.image,
                                  title: activity.title?.toUpperCase() ?? '',
                                  onTap: () {
                                    if (activity.route != null) {
                                      if (activity.title == 'Chanting') {
                                        Get.to(
                                          () => ChantingConfigurationView(
                                            chantingCategoryId: activity.id!,
                                          ),
                                        );
                                      } else if (activity.title == 'Prayer' &&
                                          activity.id != null) {
                                        Get.to(
                                          () => PrayerConfigurationView(
                                            prayerCategoryId: activity.id!,
                                          ),
                                        );
                                      } else if (activity.id != null) {
                                        context.read<CheckInBloc>().add(
                                          SelectActivity(
                                            activityId: activity.id!,
                                            route: AppConstants
                                                .routeSpiritualConfiguration,
                                            title: activity.title,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      SizedBox(height: 32),

                      // Overview Stats
                      if (data.stats != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                (data.recentActivities != null &&
                                        data.recentActivities!.isNotEmpty)
                                    ? 'Last Check-In ${_formatDateTimeFull(data.recentActivities!.first.createdAt)}'
                                    : 'No Recent Check-Ins',
                                style: GoogleFonts.lora(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff7B4A12),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'With Each Check-In Earn Karma Points',
                                style: GoogleFonts.lora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff7B4A12),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RepaintBoundary(
                          child: _buildOverviewStats(data.stats!),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Category Progress
                      if (data.categoryStats != null) ...[
                        RepaintBoundary(
                          child: _buildCategoryStats(data.categoryStats!),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Recent Activities
                      if (data.recentActivities != null &&
                          data.recentActivities!.isNotEmpty)
                        RepaintBoundary(
                          child: _buildRecentActivities(data.recentActivities!),
                        ),
                      SizedBox(height: 24),

                      // Karma & Motivation
                      Column(
                        children: [
                          if (data.motivation?.emoji != null)
                            Text(
                              data.motivation!.emoji!,
                              style: const TextStyle(fontSize: 40),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            'Earn Karma points',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff7B4A12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (data.motivation?.text != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                data.motivation!.text!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lora(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 125),
                    ],
                  ),
                ),
              ),
            ),
          );
        }, // Builder
      ), // Consumer
    ); // Provider
  }

  Widget _buildOverviewStats(Stats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff7B4A12).withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentStatIndex),
                  child: _currentStatIndex == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //_statItem('Days', '${stats.days}'),
                            _statItem('Your Check-In', '${stats.sessions}'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //_statItem('Minutes', '${stats.minutes}'),
                            _statItem('Your Karma Points', '${stats.points}'),
                          ],
                        ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppConstants.routeRedeem);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 233, 130, 11),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Redeem',
                style: GoogleFonts.lora(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/brahmkosh_logo.jpeg',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            const SizedBox(width: 2),
            Text(
              value,
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff7B4A12),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.lora(fontSize: 14, color: const Color(0xff7B4A12)),
        ),
      ],
    );
  }

  void _shareCheckInDetails(BuildContext context, Data data) {
    if (data.stats == null) {
      Utils.showToast("No stats to share yet.");
      return;
    }
    const String playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.brahmakosh.app&pcampaignid=web_share";

    // const String appStoreUrl = "";

    final stats = data.stats!;
    final recent =
        (data.recentActivities != null && data.recentActivities!.isNotEmpty)
        ? data.recentActivities!.first
        : null;

    String shareMessage =
        "I just completed my spiritual check-in on Brahmakosh! 🧘✨\n\n";

    shareMessage += "📊 My Progress:\n";
    shareMessage += "• Total Sessions: ${stats.sessions ?? 0}\n";
    shareMessage += "• Karma Points: ${stats.points ?? 0}\n";

    if (recent != null) {
      shareMessage +=
          "• Last Activity: ${recent.title ?? 'Spiritual Practice'}\n";
    }

    shareMessage +=
        "\nJoin me on my spiritual journey! Download Brahmakosh now.\n";
    shareMessage += "Android:\n$playStoreUrl\n\n";

    // shareMessage += "iOS:\n$appStoreUrl\n\n";

    shareMessage += "#Brahmakosh #Spirituality";
    final box = context.findRenderObject() as RenderBox?;

    Share.share(
      shareMessage,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildCategoryStats(CategoryStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PROGRESS',
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: const Color(0xff7B4A12),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xff7B4A12).withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                if (stats.meditation != null)
                  _categoryRow('Meditation', stats.meditation!),
                if (stats.chanting != null)
                  _categoryRow('Chanting', stats.chanting!),
                if (stats.prayer != null) _categoryRow('Prayer', stats.prayer!),
                if (stats.silence != null)
                  _categoryRow('Silence', stats.silence!),
                if (stats.bonus != null)
                  _bonusRedemptionRow(
                    'Bonus',
                    '${stats.bonus!.count} bonuses • ${stats.bonus!.totalBonusPoints} points',
                  ),
                if (stats.redemption != null)
                  _bonusRedemptionRow(
                    'Redemption',
                    '${stats.redemption!.count} redemptions • ${stats.redemption!.totalRedeemPoints} points',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bonusRedemptionRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.lora(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(String title, CategoryDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '${detail.sessions} sessions • ${detail.minutes} mins',
            style: GoogleFonts.lora(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<RecentActivities> activities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT ACTIVITIES',
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: const Color(0xff7B4A12),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            // 1. Ensures the list only occupies the height of its children
            shrinkWrap: true,
            // 2. Removes default internal padding (Crucial for fixing your image issue)
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff7B4A12).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff7B4A12).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        size: 16,
                        color: const Color(0xff7B4A12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title ?? '',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "${_formatDate(activity.createdAt)}   ${_formatTime(activity.createdAt)}",
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (activity.karmaPoints != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffC9A24D).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${activity.karmaPoints} Karma',
                              style: GoogleFonts.lora(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff7B4A12),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          activity.status == 'completed'
                              ? 'Completed'
                              : 'Incomplete',
                          style: GoogleFonts.lora(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: activity.status == 'completed'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'meditation':
        return Icons.self_improvement;
      case 'chanting':
        return Icons.music_note;
      case 'prayer':
        return Icons.volunteer_activism;
      case 'silence':
        return Icons.do_not_disturb_on;
      default:
        return Icons.spa;
    }
  }

  Widget _card({
    String? image,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                image != null
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.transparent,
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      )
                    : Container(
                        color: const Color(0xff7B4A12).withOpacity(0.1),
                        child: const Icon(
                          Icons.spa,
                          color: Color(0xff7B4A12),
                          size: 40,
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Title Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: const Color(0xff7B4A12),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
