import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../ai_rashmi_chat.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

class AiGuideView extends StatefulWidget {
  final String deityName;
  final String subtitle;
  final String backgroundImage;
  final String characterImagePath;
  final String chatBackgroundImage;
  final String? firstMessage;

  const AiGuideView({
    super.key,
    required this.deityName,
    required this.subtitle,
    required this.backgroundImage,
    required this.characterImagePath,
    required this.chatBackgroundImage,
    this.firstMessage,
  });

  @override
  State<AiGuideView> createState() => _AiGuideViewState();
}

class _AiGuideViewState extends State<AiGuideView> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AgentController>()) {
      Get.put(AgentController());
    }
  }

  void _onTapToTalk() {
    Get.to(
      () => RashmiChat(
        backgroundImage: widget.chatBackgroundImage,
        autoStartVoice: true,
        firstMessage: widget.firstMessage,
      ),
      transition: Transition.noTransition,
    );
  }

  void _onTextToChat() {
    Get.to(
      () => RashmiChat(
        backgroundImage: widget.chatBackgroundImage,
        firstMessage: widget.firstMessage,
      ),
      transition: Transition.noTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(widget.backgroundImage, fit: BoxFit.cover),

          // Safe area content
          SafeArea(
            child: Column(
              children: [
                // Top bar with Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  "BRAHMAKOSH INTELLIGENCE",
                  style: GoogleFonts.lora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "(${widget.deityName} - ${widget.subtitle})",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),

                // Character Image (Takes up most of the middle/bottom space)
                Expanded(
                  flex: 14,
                  child: Transform.scale(
                    scale:
                        1.15, // Scale up the character by 15% to make it appear larger
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Image.asset(
                        widget.characterImagePath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tap To Talk Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _onTapToTalk,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF5E6), // Beige color
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.mic,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Tap To Talk",
                                  style: GoogleFonts.lora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text To Chat Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _onTextToChat,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF5E6), // Beige color
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chat,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Text To Chat",
                                  style: GoogleFonts.lora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom feature buttons
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 30.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: [
                //       // Daily Guidance
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 16,
                //           vertical: 8,
                //         ),
                //         decoration: BoxDecoration(
                //           color: Colors.black.withOpacity(0.3),
                //           borderRadius: BorderRadius.circular(12),
                //           border: Border.all(
                //             color: AppTheme.primaryGold,
                //             width: 1,
                //           ),
                //         ),
                //         child: Column(
                //           children: [
                //             const Icon(
                //               Icons.spa,
                //               color: Colors.white,
                //               size: 24,
                //             ),
                //             const SizedBox(height: 4),
                //             Text(
                //               "Daily\nGuidance",
                //               textAlign: TextAlign.center,
                //               style: GoogleFonts.lora(
                //                 fontSize: 12,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       // Today's Stars
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 16,
                //           vertical: 8,
                //         ),
                //         decoration: BoxDecoration(
                //           color: Colors.black.withOpacity(0.3),
                //           borderRadius: BorderRadius.circular(12),
                //           border: Border.all(
                //             color: AppTheme.primaryGold,
                //             width: 1,
                //           ),
                //         ),
                //         child: Column(
                //           children: [
                //             const Icon(
                //               Icons.star,
                //               color: Colors.white,
                //               size: 24,
                //             ),
                //             const SizedBox(height: 4),
                //             Text(
                //               "Today's\nStars",
                //               textAlign: TextAlign.center,
                //               style: GoogleFonts.lora(
                //                 fontSize: 12,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../../core/theme/app_theme.dart';
// import '../ai_rashmi_chat.dart';
// import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

// class AiGuideView extends StatefulWidget {
//   final String deityName;
//   final String subtitle;
//   final String backgroundImage;
//   final String characterImagePath;
//   final String chatBackgroundImage;

//   const AiGuideView({
//     super.key,
//     required this.deityName,
//     required this.subtitle,
//     required this.backgroundImage,
//     required this.characterImagePath,
//     required this.chatBackgroundImage,
//   });

//   @override
//   State<AiGuideView> createState() => _AiGuideViewState();
// }

// class _AiGuideViewState extends State<AiGuideView> {
//   @override
//   void initState() {
//     super.initState();
//     if (!Get.isRegistered<AgentController>()) {
//       Get.put(AgentController());
//     }
//   }

//   void _onTapToTalk() {
//     Get.to(
//       () => RashmiChat(
//         backgroundImage: widget.chatBackgroundImage,
//         autoStartVoice: true,
//       ),
//       transition: Transition.noTransition,
//     );
//   }

//   void _onTextToChat() {
//     Get.to(
//       () => RashmiChat(backgroundImage: widget.chatBackgroundImage),
//       transition: Transition.noTransition,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background Image
//           Image.asset(widget.backgroundImage, fit: BoxFit.cover),

//           // Safe area content
//           SafeArea(
//             child: Column(
//               children: [
//                 // Top bar with Back Button
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 8.0,
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                         onPressed: () => Get.back(),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // Title
//                 Text(
//                   "BRAHMAKOSH INTELLIGENCE",
//                   style: GoogleFonts.lora(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.primaryGold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // Subtitle
//                 Text(
//                   "(${widget.deityName} - ${widget.subtitle})",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.lora(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: AppTheme.textPrimary,
//                     letterSpacing: 0.5,
//                   ),
//                 ),

//                 // Character Image (Takes up most of the middle/bottom space)
//                 Expanded(
//                   flex: 14,
//                   child: Transform.scale(
//                     scale:
//                         1.15, // Scale up the character by 15% to make it appear larger
//                     alignment: Alignment.bottomCenter,
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Image.asset(
//                         widget.characterImagePath,
//                         fit: BoxFit.contain,
//                         alignment: Alignment.bottomCenter,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Action Buttons
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // Tap To Talk Button
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: _onTapToTalk,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFDF5E6), // Beige color
//                               borderRadius: BorderRadius.circular(30),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.mic,
//                                   color: Colors.black,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "Tap To Talk",
//                                   style: GoogleFonts.lora(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Text To Chat Button
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: _onTextToChat,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFDF5E6), // Beige color
//                               borderRadius: BorderRadius.circular(30),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.chat,
//                                   color: Colors.black,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "Text To Chat",
//                                   style: GoogleFonts.lora(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Bottom feature buttons
//                 // Padding(
//                 //   padding: const EdgeInsets.only(bottom: 30.0),
//                 //   child: Row(
//                 //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 //     children: [
//                 //       // Daily Guidance
//                 //       Container(
//                 //         padding: const EdgeInsets.symmetric(
//                 //           horizontal: 16,
//                 //           vertical: 8,
//                 //         ),
//                 //         decoration: BoxDecoration(
//                 //           color: Colors.black.withOpacity(0.3),
//                 //           borderRadius: BorderRadius.circular(12),
//                 //           border: Border.all(
//                 //             color: AppTheme.primaryGold,
//                 //             width: 1,
//                 //           ),
//                 //         ),
//                 //         child: Column(
//                 //           children: [
//                 //             const Icon(
//                 //               Icons.spa,
//                 //               color: Colors.white,
//                 //               size: 24,
//                 //             ),
//                 //             const SizedBox(height: 4),
//                 //             Text(
//                 //               "Daily\nGuidance",
//                 //               textAlign: TextAlign.center,
//                 //               style: GoogleFonts.lora(
//                 //                 fontSize: 12,
//                 //                 color: Colors.white,
//                 //               ),
//                 //             ),
//                 //           ],
//                 //         ),
//                 //       ),
//                 //       // Today's Stars
//                 //       Container(
//                 //         padding: const EdgeInsets.symmetric(
//                 //           horizontal: 16,
//                 //           vertical: 8,
//                 //         ),
//                 //         decoration: BoxDecoration(
//                 //           color: Colors.black.withOpacity(0.3),
//                 //           borderRadius: BorderRadius.circular(12),
//                 //           border: Border.all(
//                 //             color: AppTheme.primaryGold,
//                 //             width: 1,
//                 //           ),
//                 //         ),
//                 //         child: Column(
//                 //           children: [
//                 //             const Icon(
//                 //               Icons.star,
//                 //               color: Colors.white,
//                 //               size: 24,
//                 //             ),
//                 //             const SizedBox(height: 4),
//                 //             Text(
//                 //               "Today's\nStars",
//                 //               textAlign: TextAlign.center,
//                 //               style: GoogleFonts.lora(
//                 //                 fontSize: 12,
//                 //                 color: Colors.white,
//                 //               ),
//                 //             ),
//                 //           ],
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }