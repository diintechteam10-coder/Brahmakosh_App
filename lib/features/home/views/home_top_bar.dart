import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';
import '../../../../core/common_imports.dart';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:brahmakosh/features/notifications/views/notification_screen.dart';

class HomeTopBar extends StatefulWidget {
  final Widget? bottomCard;
  final double bottomCardHeight;

  const HomeTopBar({super.key, this.bottomCard, this.bottomCardHeight = 0});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

enum DayPhase { morning, afternoon, night }

class _HomeTopBarState extends State<HomeTopBar> with TickerProviderStateMixin {
  // ... (Keep existing State logic same till build) ...
  DayPhase _currentPhase = DayPhase.morning;
  Timer? _dayPhaseTimer;

  int _currentPage = 0;
  Timer? _timer;
  List<Map<String, String>> _signs = [
    {"label": "Your Moon Sign", "value": "Loading..."},
    {"label": "Your Ascendant", "value": "Loading..."},
  ];
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _startDayPhaseWatcher();
    // _startDayPhaseRotation();

    // Initial update if data exists
    final controller = Get.find<HomeController>();
    if (controller.userCompleteDetails != null) {
      _updateSigns(controller.userCompleteDetails);
    }

    // Listen for changes
    _worker = ever(controller.userCompleteDetailsRx, (data) {
      _updateSigns(data);
    });
  }

  String get _backgroundImage {
    switch (_currentPhase) {
      case DayPhase.morning:
        return 'assets/images/MORNING_IMAGE4.png';
      case DayPhase.afternoon:
        return 'assets/images/AFTERNOON_IMAGE4.png';
      case DayPhase.night:
        return 'assets/images/night_image_4.png';
    }
  }

  String get _greetingText {
    switch (_currentPhase) {
      case DayPhase.morning:
        return 'Good Morning';
      case DayPhase.afternoon:
        return 'Good Afternoon';
      case DayPhase.night:
        return 'Good Evening';
    }
  }

  // void _startDayPhaseRotation() {
  //   _dayPhaseTimer = Timer.periodic(const Duration(seconds: 5), (_) {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       if (_currentPhase == DayPhase.morning) {
  //         _currentPhase = DayPhase.afternoon;
  //       } else if (_currentPhase == DayPhase.afternoon) {
  //         _currentPhase = DayPhase.night;
  //       } else {
  //         _currentPhase = DayPhase.morning;
  //       }
  //     });
  //   });
  // }
  void _startDayPhaseWatcher() {
    _updateDayPhase(); // initial check

    // Check every minute to update phase if needed
    _dayPhaseTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateDayPhase();
    });
  }

  void _updateDayPhase() {
    final now = DateTime.now();
    final hour = now.hour;

    DayPhase newPhase;

    if (hour >= 5 && hour < 12) {
      newPhase = DayPhase.morning;
    } else if (hour >= 12 && hour < 17) {
      newPhase = DayPhase.afternoon;
    } else {
      newPhase = DayPhase.night;
    }

    if (mounted && newPhase != _currentPhase) {
      setState(() {
        _currentPhase = newPhase;
      });
    }
  }

  void _updateSigns(UserCompleteDetailsModel? data) {
    if (mounted && data?.data?.astrology?.astroDetails != null) {
      final astro = data!.data!.astrology!.astroDetails!;
      setState(() {
        _signs = [
          {"label": "Your Sign", "value": astro.sign ?? "-"},
          {"label": "Your Sign Lord", "value": astro.signLord ?? "-"},
          {"label": "Your Ascendant", "value": astro.ascendant ?? "-"},
          {"label": "Your Ascendant Lord", "value": astro.ascendantLord ?? "-"},
        ];
      });
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % _signs.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPhaseTimer?.cancel();
    _worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine overlap height
    final double overlapHeight = widget.bottomCardHeight / 2;

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Background Image Container + Content + Half Overlay padding
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImage),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _currentPhase == DayPhase.night
                              ? [
                                  Colors.transparent,
                                  const Color(0xFF1a1a3e).withOpacity(0.0),
                                  const Color(0xFF1a1a3e).withOpacity(0.5),
                                  const Color(0xFF1a1a3e).withOpacity(0.85),
                                  AppTheme.homeBackground.withOpacity(0.95),
                                  AppTheme.homeBackground,
                                ]
                              : [
                                  Colors.transparent,
                                  Colors.transparent,
                                  AppTheme.homeBackground.withOpacity(0.0),
                                  AppTheme.homeBackground.withOpacity(0.8),
                                  AppTheme.homeBackground,
                                ],
                          stops: _currentPhase == DayPhase.night
                              ? const [0.0, 0.35, 0.55, 0.75, 0.9, 1.0]
                              : const [0.0, 0.6, 0.8, 0.9, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Scaffold.of(context).openDrawer(),
                                child: Consumer<ProfileViewModel>(
                                  builder: (context, profileVM, child) {
                                    // Use profileImageUrl as it likely contains the full URL
                                    final profileImageUrl =
                                        profileVM.profile?.profileImageUrl;

                                    return CustomProfileAvatar(
                                      imageUrl: profileImageUrl,
                                      radius: 20.0,
                                      borderWidth: 1.5,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "BRAHMAKOSH",
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _currentPhase == DayPhase.night
                                            ? Color(0xffFFFFFF)
                                            : const Color(
                                                0xFF6D3A0C,
                                              ), // Dark Brown
                                      ),
                                    ),
                                    Text(
                                      "Your Spritual operating System",
                                      style: GoogleFonts.lora(
                                        fontSize: 10,
                                        color: _currentPhase == DayPhase.night
                                            ? Color(0xffFFFFFF)
                                            : const Color(0xFF874101),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationScreen(),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 40,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.notifications_sharp,
                                      color: _currentPhase == DayPhase.night
                                          ? Color(0xffFFFFFF)
                                          : Color(0xFF6D3A0C),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  child: RichText(
                                    key: ValueKey<int>(_currentPage),
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.lora(
                                        fontSize: 12,
                                        color: _currentPhase == DayPhase.night
                                            ? Color(0xffFFFFFF)
                                            : const Color(0xFF6D3A0C),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${_signs[_currentPage]['label']}: ",
                                        ),
                                        TextSpan(
                                          text: _signs[_currentPage]['value'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _currentPhase == DayPhase.night
                                                ? Color(0xffFFFFFF)
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _greetingText,
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _currentPhase == DayPhase.night
                                  ? Color(0xffFFFFFF)
                                  : const Color(0xFF6D3A0C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Here' your daily Insights!",
                            style: GoogleFonts.lora(
                              fontSize: 13,
                              color: _currentPhase == DayPhase.night
                                  ? Color(0xffFFFFFF)
                                  : const Color(0xFF6D3A0C),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ADD Padding for Overlap (Image extends here)
                          SizedBox(
                            height: overlapHeight > 0 ? overlapHeight : 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spacer for the non-overlapping part of bottomCard
            if (widget.bottomCard != null) SizedBox(height: overlapHeight),
          ],
        ),

        // Positioned Card
        if (widget.bottomCard != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: widget.bottomCardHeight,
              child: widget.bottomCard,
            ),
          ),
      ],
    );
  }
}
