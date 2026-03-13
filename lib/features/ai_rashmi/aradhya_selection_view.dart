import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common_imports.dart';
import '../../../../common/models/avtar_list.dart';
import 'deity_selection_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AradhyaSelectionView extends StatelessWidget {
  final Future<void> Function()? onDeitySelected;

  const AradhyaSelectionView({super.key, this.onDeitySelected});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AgentController>()) {
      Get.put(AgentController());
    }
    final AgentController agentController = Get.find<AgentController>();
    // Capture the callback to use in closures
    final onDeitySelected = this.onDeitySelected;

    // Refresh avatars when opening selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      agentController.fetchAvatars(null);
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select Aradhya',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Choose your divine guide to seek blessings and guidance',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Deity Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Obx(() {
                  if (agentController.isLoading &&
                      agentController.avatars.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }

                  if (agentController.avatars.isEmpty) {
                    return Center(
                      child: Text(
                        'No Aradhyas available',
                        style: GoogleFonts.lora(color: Colors.black54),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: agentController.avatars.length,
                    itemBuilder: (context, index) {
                      final Data deity = agentController.avatars[index];
                      // Cycle through chakra colors for a colorful UI
                      final List<Color> chakraColors = [
                        AppTheme.chakraRed,
                        AppTheme.chakraOrange,
                        AppTheme.chakraYellow,
                        AppTheme.chakraGreen,
                        AppTheme.chakraBlue,
                        AppTheme.chakraIndigo,
                        AppTheme.chakraIndigo,
                      ];
                      final Color assignedColor =
                          chakraColors[index % chakraColors.length];

                      return _DeityCircle(
                        name: deity.name ?? 'Aradhya',
                        imagePath: deity.imageUrl ?? '',
                        color: assignedColor,
                        onTap: () async {
                          // Store the selected deity in the service
                          DeitySelectionService().setSelectedDeity(deity);

                          // Close selection screen
                          Get.back();

                          // Call the callback if provided with proper waiting
                          if (onDeitySelected != null) {
                            // Wait a bit for Get.back() to complete
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            await onDeitySelected!();
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DeityCircle extends StatefulWidget {
  final String name;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  const _DeityCircle({
    required this.name,
    required this.imagePath,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DeityCircle> createState() => _DeityCircleState();
}

class _DeityCircleState extends State<_DeityCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withOpacity(0.2),
                widget.color.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: widget.color.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Image Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.6),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: widget.imagePath.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget.imagePath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: widget.color.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: widget.color.withOpacity(0.2),
                            child: Icon(
                              Icons.image_not_supported,
                              color: widget.color,
                              size: 40,
                            ),
                          ),
                        )
                      : Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image doesn't exist
                            return Container(
                              color: widget.color.withOpacity(0.2),
                              child: Icon(
                                Icons.image_not_supported,
                                color: widget.color,
                                size: 40,
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Deity Name
              Text(
                widget.name,
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}