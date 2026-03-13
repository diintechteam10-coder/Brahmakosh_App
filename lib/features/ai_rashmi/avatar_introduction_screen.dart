import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/agent/lemon_agent_page.dart';
import 'package:brahmakosh/features/ai_rashmi/deity_selection_service.dart';

class AvatarIntroductionScreen extends StatefulWidget {
  final String? backgroundImage;
  const AvatarIntroductionScreen({super.key, this.backgroundImage});

  @override
  State<AvatarIntroductionScreen> createState() =>
      _AvatarIntroductionScreenState();
}

class _AvatarIntroductionScreenState extends State<AvatarIntroductionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeitySelectionService _deityService = DeitySelectionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:
          const SizedBox(), // No drawer needed for this screen or maybe re-implement if needed
      body: Stack(
        children: [
          // Background
          Builder(
            builder: (context) {
              if (widget.backgroundImage != null) {
                return Positioned.fill(
                  child: Image.asset(
                    widget.backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 1.0,
                ),
                child: _buildHeader(context),
              ),
            ),
          ),

          // Talk Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const AvatarAgentPage());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Talk",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Determine the current deity name and image logic
    String deityName = 'Krishna';
    String imageAsset = 'assets/images/Small_krishna.png';

    // Check widget config for default
    if (widget.backgroundImage?.contains('Rashmi') == true) {
      deityName = 'Rashmi';
      imageAsset = 'assets/images/Small_rashmi.png';
    }

    // Check selected deity or fallback
    if (_deityService.selectedDeity != null) {
      final name = _deityService.selectedDeity!.name ?? '';
      if (name.toLowerCase().contains('rashmi')) {
        deityName = 'Rashmi';
        imageAsset = 'assets/images/Small_rashmi.png';
      } else if (name.toLowerCase().contains('krishna')) {
        deityName = 'Krishna';
        imageAsset = 'assets/images/Small_krishna.png';
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back to drawer/previous screen
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E7), // Off-white
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          ),
        ),

        // Center "Krishna" Button/Dropdown (Static here, no toggle)
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(imageAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  deityName,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Empty placeholder to balance the row
        const SizedBox(width: 32),
      ],
    );
  }
}