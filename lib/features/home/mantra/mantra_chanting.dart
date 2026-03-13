import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/home/controllers/mantra_chanting_controller.dart';
import 'package:brahmakosh/features/home/blocs/mantra/mantra_bloc.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';

class MantraChantingView extends StatelessWidget {
  const MantraChantingView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MantraChantingController>()) {
      Get.put(MantraChantingController());
    }

    final controller = Get.find<MantraChantingController>();

    return BlocProvider(
      create: (context) => MantraBloc(repository: SpiritualRepository()),
      child: BlocConsumer<MantraBloc, MantraState>(
        listener: (context, state) {
          if (state is MantraSaving) {
            Get.dialog(
              const Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );
          } else if (state is MantraSaved) {
            if (Get.isDialogOpen ?? false) Get.back(); // Close Loader
            _showResultDialog(context, state.responseData);
          } else if (state is MantraError) {
            if (Get.isDialogOpen ?? false) Get.back(); // Close Loader
            Get.snackbar(
              "Error",
              state.message,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              await _showExitConfirmation(context);
              // Handle exit logic in dialog
            },
            child: Scaffold(
              backgroundColor: Color(0xffFDF6E3),
              body: Column(
                children: [
                  _CompletionListener(
                    controller: controller,
                    child: const SizedBox.shrink(),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(context, controller),
                        const SizedBox(height: 60),
                        Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 250,
                                width: 250,
                                child: Image.asset(
                                  "assets/images/chantingbg.png",
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Center(
                                child: _buildMantraDial(controller),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildStatusSection(controller),
                        const SizedBox(height: 8),
                        _buildChantButton(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Header with Exit Logic
  Widget _buildHeader(
    BuildContext context,
    MantraChantingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitConfirmation(context),
                icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
              ),
            ],
          ),
          Text(
            "Today' Chanting",
            style: GoogleFonts.merriweather(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5D4037),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final mantraName = controller.chantingMantra?.name ?? "ॐ नमः शिवाय";
            return Text(
              mantraName,
              style: GoogleFonts.tiroDevanagariHindi(
                fontSize: 18,
                color: const Color(0xff5D4037),
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ],
      ),
    );
  }

  // Dial
  Widget _buildMantraDial(MantraChantingController controller) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Obx(() {
            final total = controller.chantingMantra?.malaCount ?? 108;
            final current = controller.chantCount.value;
            final mantraText = controller.chantingMantra?.name ?? "ॐ नमः शिवाय";

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      mantraText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tiroDevanagariHindi(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 1,
                  color: const Color(0xffFFD700).withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$current",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: " / $total",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            final mantraText = controller.chantingMantra?.name ?? "ॐ नमः शिवाय";
            return Stack(
              children: controller.animationTriggers.map((id) {
                return _FloatingMantra(
                  key: ValueKey(id),
                  mantraText: mantraText,
                  onComplete: () => controller.animationTriggers.remove(id),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // Status
  Widget _buildStatusSection(MantraChantingController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.elapsedSeconds.value > 0
                      ? const Color(0xffFF8C00)
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              "Chanting in Progress",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5D4037),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            "Time : ${controller.formattedTime}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xff8D6E63),
            ),
          ),
        ),
      ],
    );
  }

  // Button
  Widget _buildChantButton(MantraChantingController controller) {
    return GestureDetector(
      onTap: controller.incrementCount,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Obx(() {
              final total = controller.chantingMantra?.malaCount ?? 108;
              final progress = total > 0
                  ? (controller.chantCount.value / total)
                  : 0.0;
              return CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation(Color(0xffD4AF37)),
                backgroundColor: const Color(0xffD4AF37).withOpacity(0.2),
              );
            }),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xff5D4037), Color(0xff3E2723)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xffD4AF37), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff3E2723).withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              "Tap to\nChant",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic & Dialogs ---

  Future<void> _showExitConfirmation(BuildContext context) async {
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xffFFF8E7),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Color(0xff5D4037),
              ),
              const SizedBox(height: 16),
              Text(
                "End Chanting?",
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to end chanting? If you end now, you will not receive any Karma points.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xff8D6E63),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          color: const Color(0xff8D6E63),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _saveSession(context, incomplete: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5D4037),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "End",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(
    BuildContext context,
    Map<String, dynamic> responseData,
  ) {
    // String message = responseData['message'] ?? "Session Saved"; // Unused
    Map<String, dynamic> data = responseData['data'] ?? {};
    int karma = data['karmaPoints'] ?? 0;
    String statusMessage =
        data['statusMessage'] ??
        (karma > 0 ? "You earned Karma!" : "Session Incomplete");

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xffFFF8E7),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                karma > 0 ? Icons.stars : Icons.info_outline,
                size: 60,
                color: karma > 0 ? Color(0xffFF8C00) : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                karma > 0 ? "Saved!" : "Incomplete",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff5D4037),
                  fontFamily: 'Merriweather',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                statusMessage, // Using status message from API (with emoji)
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xff8D6E63)),
              ),
              const SizedBox(height: 8),
              Text(
                "+$karma Karma Points",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFF8C00),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.close(1);
                    Get.until(
                      (route) =>
                          route.settings.name == AppConstants.routeDashboard,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5D4037),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Done", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _saveSession(BuildContext context, {required bool incomplete}) {
    final controller = Get.find<MantraChantingController>();
    final mantra = controller.chantingMantra;
    if (mantra == null) return;

    // Logic for percentage
    final total = mantra.malaCount ?? 108;
    final current = controller.chantCount.value;
    int percentage = (total > 0) ? ((current / total) * 100).ceil() : 0;

    // Clamp
    if (percentage > 100) percentage = 100;
    if (incomplete && percentage == 100)
      percentage = 99; // Ensure incomplete status if user said End

    // Explicit Args
    final args = Get.arguments as Map? ?? {};
    final audioUrl =
        args['audioUrl'] ?? ""; // Assuming empty string if null, or null
    final videoUrl = args['videoUrl'] ?? "";
    final emotion = args['emotion'] ?? "neutral";
    final mantraTitle = args['mantra_title'] ?? mantra.name ?? "";
    // karmaPoints: will be 0 if incomplete, send 0 in request?
    // Request body: "karmaPoints": 0
    // Wait, API decides points?
    // User request body example: "karmaPoints": 0.
    // So we assume we send 0 for incomplete.
    // For complete, we send what? The config's points?
    // Request body has "karmaPoints".
    final configPoints = args['karma_points'] ?? 0;

    final request = SpiritualSessionRequest(
      type: "chanting",
      title: mantraTitle,
      chantingName: mantraTitle, // Should check model property
      targetDuration: null, // null or ""
      actualDuration: null,
      chantCount: current,
      karmaPoints: incomplete ? 0 : configPoints,
      emotion: emotion,
      status: incomplete ? "incomplete" : "completed",
      completionPercentage: percentage,
      videoUrl: videoUrl,
      audioUrl: audioUrl,
    );

    context.read<MantraBloc>().add(SaveMantraSession(request));
  }
}

// Helper to listen to observable once
class _CompletionListener extends StatefulWidget {
  final MantraChantingController controller;
  final Widget child;
  const _CompletionListener({required this.controller, required this.child});
  @override
  State<_CompletionListener> createState() => _CompletionListenerState();
}

class _CompletionListenerState extends State<_CompletionListener> {
  Worker? _worker;
  @override
  void initState() {
    super.initState();
    _worker = ever(widget.controller.isCompleted, (completed) {
      if (completed) {
        // Stop audio again just in case, though controller does it.
        // widget.controller.stopAudio(); // No public method, but controller internal logic handles it.

        _triggerCompletionDialog(context);
      }
    });
  }

  void _triggerCompletionDialog(BuildContext context) {
    // Re-implement or call shared method?
    // Since MantraChantingView is Stateless, we can't call instance method.
    // Let's refactor `MantraChantingView` to be Stateful or just define the method outside.
    // Or cast.
    // Easier: just copy logic here or have logic in `MantraChantingView` be static? No.
    // Let's make `MantraChantingView` Stateful or access via context?
    // Actually `MantraChantingView` is just building the UI.
    // I can instantiate the dialog from here.

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xffFFF8E7),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Color(0xff4CAF50),
              ),
              const SizedBox(height: 16),
              const Text(
                "Completed!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff5D4037),
                  fontFamily: 'Merriweather',
                ),
              ),
              // ... Rest of UI ...
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close local dialog
                    // Call save via context
                    // We need to access the helper _saveSession.
                    // We can move _saveSession to be a static helper or specific class?
                    // Let's just create the request here and call bloc.

                    _triggerSave(context, false);
                  },
                  child: const Text("OK", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5D4037),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _triggerSave(BuildContext context, bool incomplete) {
    final controller = widget.controller;
    final mantra = controller.chantingMantra;
    if (mantra == null) return;

    final current = controller.chantCount.value;
    final total = mantra.malaCount ?? 108;
    int percentage = (total > 0) ? ((current / total) * 100).ceil() : 0;
    if (percentage > 100) percentage = 100;

    final args = Get.arguments as Map? ?? {};
    final audioUrl = args['audioUrl'] ?? "";
    final videoUrl = args['videoUrl'] ?? "";
    final emotion = args['emotion'] ?? "neutral";
    final mantraTitle = args['mantra_title'] ?? mantra.name ?? "";
    final configPoints = args['karma_points'] ?? 0;

    final request = SpiritualSessionRequest(
      type: "chanting",
      title: mantraTitle,
      chantingName: mantraTitle,
      targetDuration: null,
      actualDuration: null,
      chantCount: current,
      karmaPoints: incomplete ? 0 : configPoints,
      emotion: emotion,
      status: incomplete ? "incomplete" : "completed",
      completionPercentage: percentage,
      videoUrl: videoUrl,
      audioUrl: audioUrl,
    );

    context.read<MantraBloc>().add(SaveMantraSession(request));
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FloatingMantra extends StatefulWidget {
  final String mantraText;
  final VoidCallback onComplete;

  const _FloatingMantra({
    super.key,
    required this.mantraText,
    required this.onComplete,
  });

  @override
  State<_FloatingMantra> createState() => _FloatingMantraState();
}

class _FloatingMantraState extends State<_FloatingMantra>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _moveAnimation = Tween<Alignment>(
      begin: Alignment.center,
      end: const Alignment(0, -50),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: _moveAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.mantraText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tiroDevanagariHindi(
                    fontSize: 32,
                    color: const Color(0xffFFD700),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
