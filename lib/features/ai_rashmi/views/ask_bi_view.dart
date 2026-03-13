import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import 'package:brahmakosh/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../ai_rashmi_service.dart';
import '../deity_selection_service.dart';
import '../model/agents_response_model.dart';
import 'ai_guide_view.dart';

class AskBiView extends StatefulWidget {
  const AskBiView({super.key});

  @override
  State<AskBiView> createState() => _AskBiViewState();
}

class _AskBiViewState extends State<AskBiView> {
  final AiRashmiService _service = AiRashmiService();

  List<AgentResponseData> agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAgents();
  }

  Future<void> loadAgents() async {
    try {
      final response = await _service.fetchAgents();

      if (mounted) {
        setState(() {
          agents = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: () {
                          Provider.of<DashboardViewModel>(
                            context,
                            listen: false,
                          ).changeTab(0);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// TITLE
                Text(
                  "ASK YOUR BI",
                  style: GoogleFonts.lora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "BRAHMAKOSH ",
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      TextSpan(
                        text: "INTELLIGENCE",
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// SUBTITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.primaryGold,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "CHOOSE YOURS SPIRITUAL GUIDE TO PROCEED",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// AGENTS FROM API
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: agents.map((agent) {
                      final name = agent.name ?? "";
                      final isKrishna = name.toLowerCase().contains("krishna");

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGuideCard(
                          context,
                          title: name,
                          subtitle: agent.description ?? "",
                          description: agent.firstMessage ?? "",
                          buttonText: isKrishna ? "Unlock To Talk" : "Explore",
                          buttonGradient: isKrishna
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFE6C17A),
                                    Color(0xFFC79E59),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF4A90E2),
                                    Color(0xFF357ABD),
                                  ],
                                ),
                          characterImagePath: isKrishna
                              ? 'assets/images/Krishana_new.png'
                              : 'assets/images/Rashmi_new.png',
                          backgroundColor: isKrishna
                              ? const Color(0xFF5F66B6)
                              : const Color(0xFFF0E5D8),
                          textColor: isKrishna
                              ? Colors.white
                              : AppTheme.textPrimary,
                          dividerColor: isKrishna
                              ? Colors.white.withOpacity(0.5)
                              : AppTheme.textSecondary.withOpacity(0.3),
                          isLockIcon: isKrishna,
                          buttonTextColor: isKrishna
                              ? AppTheme.textPrimary
                              : Colors.white,
                          onTap: () async {
                            if (!Get.isRegistered<AgentController>()) {
                              Get.put(AgentController());
                            }
print("Selected Agent ID: ${agent.id}");
print("Saved Agent ID: ${StorageService.getString('ai_selected_agent_id')}");
                            final agentController = Get.find<AgentController>();

                            if (agentController.avatars.isEmpty) {
                              await agentController.fetchAvatars(null);
                            }

                            try {
                              final selectedAgent = agentController.avatars
                                  .firstWhere(
                                    (a) => (a.name ?? "")
                                        .toLowerCase()
                                        .contains(name.toLowerCase()),
                                  );

                              DeitySelectionService().setSelectedDeity(
                                selectedAgent,
                              );
                            } catch (e) {}
                            StorageService.setString(
                              'ai_selected_agent_id',
                              agent.id ?? '',
                            );
                            StorageService.setString(
                              'ai_selected_agent_name',
                              agent.name ?? '',
                            );
                            
                            // Print to terminal
                            print("=== SAVED AGENT INFO ===");
                            print("Saved Agent ID: ${StorageService.getString('ai_selected_agent_id')}");
                            print("Saved Agent Name: ${StorageService.getString('ai_selected_agent_name')}");
                            print("========================");

                            Get.to(
                              () => AiGuideView(
                                deityName: name,
                                subtitle: agent.description ?? "",
                                firstMessage: agent.firstMessage,
                                // subtitle: agent. "",
                                backgroundImage:
                                    'assets/images/rashmi_background.jpeg',
                                characterImagePath: isKrishna
                                    ? 'assets/images/Krishana_new.png'
                                    : 'assets/images/Rashmi_new.png',
                                chatBackgroundImage: isKrishna
                                    ? 'assets/images/Krishna_chat.png'
                                    : 'assets/images/Rashmi_chat.png',
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                /// MANTRA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "|| ॐ भूर्भुव: स्व: तत्सवितुर्वरेण्यं भर्गो देवस्य\nधीमहि धियो यो न: प्रचोदयात् ||",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rozhaOne(
                      fontSize: 20,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required Gradient buttonGradient,
    required String characterImagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
    required Color textColor,
    required Color dividerColor,
    required bool isLockIcon,
    Color buttonTextColor = Colors.white,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.32;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(
                  width: imageWidth,
                  child: Image.asset(
                    characterImagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          height: 1,
                          width: double.infinity,
                          color: dividerColor,
                        ),

                        Text(
                          subtitle,
                          style: GoogleFonts.lora(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          description,
                          style: GoogleFonts.lora(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLockIcon) ...[
                                Icon(
                                  Icons.lock,
                                  size: 10,
                                  color: buttonTextColor,
                                ),
                                const SizedBox(width: 4),
                              ],

                              Text(
                                buttonText,
                                style: GoogleFonts.lora(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: buttonTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
// import 'package:brahmakosh/features/dashboard/viewmodels/dashboard_viewmodel.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_theme.dart';
// import '../deity_selection_service.dart';
// import 'ai_guide_view.dart'; // Added Import

// class AskBiView extends StatelessWidget {
//   const AskBiView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBE6D0), // home background match
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 100),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Top Bar
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 8.0,
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(
//                           Icons.arrow_back,
//                           color: AppTheme.textPrimary,
//                         ),
//                         onPressed: () {
//                           // Go back to home
//                           Provider.of<DashboardViewModel>(
//                             context,
//                             listen: false,
//                           ).changeTab(0);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // Title
//                 Text(
//                   "ASK YOUR BI",
//                   style: GoogleFonts.lora(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.textPrimary,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: "BRAHMAKOSH ",
//                         style: GoogleFonts.lora(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFFD97706), // Orange
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       TextSpan(
//                         text: "INTELLIGENCE",
//                         style: GoogleFonts.lora(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Subtitle
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: AppTheme.primaryGold,
//                           width: 1.5,
//                         ),
//                       ),
//                     ),
//                     child: Text(
//                       "CHOOSE YOURS SPIRITUAL GUIDE TO PROCEED",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.lora(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: AppTheme.textPrimary,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Rashmi Card
//                 _buildGuideCard(
//                   context,
//                   title: "Rashmi",
//                   subtitle: "Personal Spiritual Guide",
//                   description: "Ask About Life, Career & Astrology",
//                   buttonText: "Explore",
//                   buttonGradient: const LinearGradient(
//                     colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
//                   ),
//                   characterImagePath:
//                       'assets/images/Rashmi_new.png',
//                   backgroundColor: const Color(
//                     0xFFF0E5D8,
//                   ), // Light taupe/cream color from image
//                   onTap: () async {
//                     if (!Get.isRegistered<AgentController>()) {
//                       Get.put(AgentController());
//                     }
//                     final agentController = Get.find<AgentController>();
//                     if (agentController.avatars.isEmpty) {
//                       await agentController.fetchAvatars(null);
//                     }
//                     // Find Rashmi avatar
//                     try {
//                       final rashmiData = agentController.avatars.firstWhere(
//                         (a) => (a.name ?? '').toLowerCase().contains('rashmi'),
//                       );
//                       DeitySelectionService().setSelectedDeity(rashmiData);
//                     } catch (e) {
//                       // Fallback
//                     }

//                     Get.to(
//                       () => const AiGuideView(
//                         deityName: "Rashmi",
//                         subtitle: "Your Spiritual Guide",
//                         backgroundImage: 'assets/images/rashmi_background.jpeg',
//                         characterImagePath:
//                             'assets/images/Rashmi_new.png',
//                         chatBackgroundImage: 'assets/images/Rashmi_chat.png',
//                       ),
//                     );
//                   },
//                   textColor: AppTheme.textPrimary,
//                   dividerColor: AppTheme.textSecondary.withOpacity(0.3),
//                   isLockIcon: false,
//                 ),

//                 const SizedBox(height: 16),

//                 // Krishna Card
//                 _buildGuideCard(
//                   context,
//                   title: "Krishna",
//                   subtitle: "Divine Cosmic Intelligence",
//                   description: "Karma, Destiny, Deep Truths",
//                   buttonText: "Unlock To Talk",
//                   buttonGradient: const LinearGradient(
//                     colors: [Color(0xFFE6C17A), Color(0xFFC79E59)],
//                   ),
//                   characterImagePath:
//                       'assets/images/Krishana_new.png',
//                   backgroundColor: const Color(
//                     0xFF5F66B6,
//                   ), // Purple-blue color from image
//                   onTap: () async {
//                     if (!Get.isRegistered<AgentController>()) {
//                       Get.put(AgentController());
//                     }
//                     final agentController = Get.find<AgentController>();
//                     if (agentController.avatars.isEmpty) {
//                       await agentController.fetchAvatars(null);
//                     }
//                     // Find Krishna avatar
//                     try {
//                       final krishnaData = agentController.avatars.firstWhere(
//                         (a) => (a.name ?? '').toLowerCase().contains('krishna'),
//                       );
//                       DeitySelectionService().setSelectedDeity(krishnaData);
//                     } catch (e) {
//                       // Fallback
//                     }

//                     Get.to(
//                       () => const AiGuideView(
//                         deityName: "Krishna",
//                         subtitle: "Divine Cosmic Intelligence",
//                         backgroundImage: 'assets/images/rashmi_background.jpeg',
//                         characterImagePath:
//                             'assets/images/Krishana_new.png',
//                         chatBackgroundImage: 'assets/images/Krishna_chat.png',
//                       ),
//                     );
//                   },
//                   textColor: Colors.white,
//                   dividerColor: Colors.white.withOpacity(0.5),
//                   isLockIcon: true,
//                   buttonTextColor: AppTheme.textPrimary,
//                 ),

//                 const SizedBox(height: 24),

//                 // Bottom Mantra
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Text(
//                     "|| ॐ भूर्भुव: स्व: तत्सवितुर्वरेण्यं भर्गो देवस्य\nधीमहि धियो यो न: प्रचोदयात् ||",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.rozhaOne(
//                       fontSize: 20, // Reduced from 15
//                       color: AppTheme.textPrimary,
//                       height: 1.4, // Reduced line height slightly
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGuideCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required String description,
//     required String buttonText,
//     required Gradient buttonGradient,
//     required String characterImagePath,
//     required Color backgroundColor,
//     required VoidCallback onTap,
//     required Color textColor,
//     required Color dividerColor,
//     required bool isLockIcon,
//     Color buttonTextColor = Colors.white,
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final imageWidth = screenWidth * 0.32;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           clipBehavior: Clip.hardEdge,
//           child: IntrinsicHeight(
//             child: Row(
//               children: [
//                 // Character Image
//                 SizedBox(
//                   width: imageWidth,
//                   child: Image.asset(
//                     characterImagePath,
//                     fit: BoxFit.cover,
//                     alignment: Alignment.bottomCenter,
//                     errorBuilder: (context, error, stackTrace) =>
//                         const SizedBox.shrink(),
//                   ),
//                 ),

//                 // Text Content
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 16,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Title
//                         Text(
//                           title,
//                           style: GoogleFonts.lora(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: textColor,
//                           ),
//                         ),

//                         // Divider
//                         Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           height: 1,
//                           width: double.infinity,
//                           color: dividerColor,
//                         ),

//                         // Subtitle
//                         Text(
//                           subtitle,
//                           style: GoogleFonts.lora(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w500,
//                             color: textColor.withOpacity(0.9),
//                           ),
//                         ),

//                         const SizedBox(height: 2),

//                         // Description
//                         Text(
//                           description,
//                           style: GoogleFonts.lora(
//                             fontSize: 10,
//                             fontStyle: FontStyle.italic,
//                             color: textColor.withOpacity(0.8),
//                           ),
//                         ),

//                         const SizedBox(height: 8),
//                         // Action Button
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: buttonGradient,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (isLockIcon) ...[
//                                 Icon(
//                                   Icons.lock,
//                                   size: 10,
//                                   color: buttonTextColor,
//                                 ),
//                                 const SizedBox(width: 4),
//                               ],
//                               Text(
//                                 buttonText,
//                                 style: GoogleFonts.lora(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   color: buttonTextColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }