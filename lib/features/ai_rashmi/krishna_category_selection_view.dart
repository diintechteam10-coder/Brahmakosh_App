import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

import 'ai_rashmi_view_model.dart';
import 'deity_selection_service.dart';
import 'widgets/deity_selection_widget.dart';

class KrishnaCategorySelectionView extends StatefulWidget {
  final AiRashmiController vm;
  final Widget Function(BuildContext, AiRashmiController) inputAreaBuilder;
  final Function(String) onSwitchDeity;

  const KrishnaCategorySelectionView({
    super.key,
    required this.vm,
    required this.inputAreaBuilder,
    required this.onSwitchDeity,
  });

  @override
  State<KrishnaCategorySelectionView> createState() =>
      _KrishnaCategorySelectionViewState();
}

class _KrishnaCategorySelectionViewState
    extends State<KrishnaCategorySelectionView> {
  bool _isDeitySelectionOpen = false;
  final DeitySelectionService _deityService = DeitySelectionService();

  void _handleDeitySelection(String deityName) async {
    if (!Get.isRegistered<AgentController>()) {
      Get.put(AgentController());
    }
    final agentController = Get.find<AgentController>();
    if (agentController.avatars.isEmpty) {
      await agentController.fetchAvatars(null);
    }

    final targetDeity = agentController.avatars.firstWhereOrNull(
      (a) => (a.name ?? '').toLowerCase().contains(deityName.toLowerCase()),
    );

    if (targetDeity != null) {
      _deityService.setSelectedDeity(targetDeity);
      setState(() {
        _isDeitySelectionOpen = false;
      });
      // Delegate navigation to the parent via callback
      widget.onSwitchDeity(deityName);
    } else {
      setState(() {
        _isDeitySelectionOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current deity name and image logic
    String deityName = 'Krishna';
    String imageAsset = 'assets/images/Small_krishna.png';

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

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0), // Specific background color
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(6), // Reduced from 8
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 16, // Reduced from 18
                          ),
                        ),
                      ),

                      // Center "Krishna" Pill with Toggle
                      Container(
                        height: 36, // Reduced from 40
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ), // Reduced from 12
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDeitySelectionOpen = !_isDeitySelectionOpen;
                              });
                            },
                            child: Row(
                              children: [
                                // Small Avatar Image
                                Container(
                                  width: 24, // Reduced from 28
                                  height: 24, // Reduced from 28
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
                                    fontSize: 12, // Reduced from 14
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  _isDeitySelectionOpen
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.orange.shade800,
                                  size: 18, // Reduced from 20
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Hamburger Menu
                      GestureDetector(
                        onTap: () {
                          // Hamburger menu action (open drawer if accessible, or maybe just placeholder here)
                          // In the main chat it opens drawer. Here we might not have drawer access easily unless scaffoldKey passed.
                          // Keeping visual consistency.
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6), // Reduced from 8
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.black,
                            size: 16, // Reduced from 18 to match ai_rashmi_chat
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Title
                Text(
                  "Choose a Category",
                  style: GoogleFonts.lora(
                    fontSize: 20, // Reduced from 24
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6D3A0C),
                  ),
                ),

                const SizedBox(height: 20),

                // Categories List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryItem(
                        context,
                        "Life & Direction",
                        Icons.explore_outlined,
                        [
                          "What is my Dharma in phase if my life?",
                          "Am I moving in the right direction, or do I need to realign?",
                          "What lesson am I meant to learn from my current struggles?",
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryItem(
                        context,
                        "Peace & Inner Strength",
                        Icons.spa_outlined,
                        [
                          "How can I find peace in this chaos?",
                          "Help me overcome my anxiety.",
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryItem(
                        context,
                        "Mind & Emotion",
                        Icons.psychology_outlined,
                        [
                          "How do I control my anger?",
                          "My mind is restless, what should I do?",
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryItem(
                        context,
                        "Action & Courage",
                        Icons.shield_outlined,
                        [
                          "Give me strength to face this challenge.",
                          "Is it right to fight for what I believe in?",
                        ],
                      ),
                    ],
                  ),
                ),

                // Input Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    0,
                    14,
                    12,
                  ), // Reduced padding
                  child: widget.inputAreaBuilder(context, widget.vm),
                ),
              ],
            ),
          ),

          // Deity Selection Overlay
          if (_isDeitySelectionOpen)
            Positioned(
              top: 80, // Approximate header height + padding
              left: 16,
              right: 16,
              child: DeitySelectionWidget(
                onSelectKrishna: () => _handleDeitySelection('Krishna'),
                onSelectRashmi: () => _handleDeitySelection('Rashmi'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    List<String> questions,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.black87,
          iconColor: Colors.black87,
          leading: Icon(
            icon,
            size: 22,
            color: Colors.black87,
          ), // Reduced from 28
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14, // Reduced from 16
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: questions
                    .map((q) => _buildQuestionItem(widget.vm, q))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(AiRashmiController vm, String question) {
    return GestureDetector(
      onTap: () {
        vm.sendMessage(question);
        Get.back();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6), // Reduced from 8
        padding: const EdgeInsets.all(10), // Reduced from 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          question,
          style: const TextStyle(
            fontSize: 12, // Reduced from 14
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}