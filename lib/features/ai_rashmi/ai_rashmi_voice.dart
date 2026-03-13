import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'ai_rashmi_view_model.dart';
import 'deity_selection_service.dart';

class RashmiVoicePage extends StatefulWidget {
  const RashmiVoicePage({super.key});

  @override
  State<RashmiVoicePage> createState() => _RashmiVoicePageState();
}

class _RashmiVoicePageState extends State<RashmiVoicePage> {
  late VideoPlayerController _vicontroller;
  final DeitySelectionService _deityService = DeitySelectionService();

  @override
  void initState() {
    super.initState();
    // Get video path based on selected deity
    final videoPath = _deityService.getVideoPath();
    if (videoPath != null) {
      if (videoPath.startsWith('http')) {
        _vicontroller = VideoPlayerController.network(videoPath);
      } else {
        _vicontroller = VideoPlayerController.asset(videoPath);
      }

      _vicontroller.initialize().then((_) {
        if (mounted) {
          _vicontroller.setLooping(false);
          _vicontroller.setVolume(1.0);
          _vicontroller.seekTo(Duration.zero);
          _vicontroller.play();
          setState(() {});
        }
      }).catchError((error) {
        print('Video initialization error: $error');
      });
    } else {
      // Initialize with something even if null path to avoid LateInitializationError later
      _vicontroller = VideoPlayerController.asset('assets/images/bi_bg.mp4');
      _vicontroller.initialize().then((_) {
         if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _vicontroller.pause();
    _vicontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiRashmiController>(
      builder: (vm) {
        return Scaffold(
          body: Stack(
            children: [
              // Video Background
              Positioned.fill(
                child: _vicontroller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _vicontroller.value.size.width,
                          height: _vicontroller.value.size.height,
                          child: VideoPlayer(_vicontroller),
                        ),
                      )
                    : Container(color: Colors.black),
              ),

              // Dark overlay
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with Back Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Get.back(),
                          ),
                          const Spacer(),
                          Text(
                            _deityService.selectedDeityName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status Indicators
                    if (vm.isInitializing)
                      const LinearProgressIndicator(minHeight: 2),

                    if (vm.isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.green.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Listening... Tap to stop',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (vm.isProcessingVoice)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.blue.withOpacity(0.1),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (vm.isPlayingAudio)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.purple.withOpacity(0.1),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: Colors.purple,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Playing response...',
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (vm.error != null)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vm.error!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade700,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                vm.clearError();
                              },
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Voice Recording Button
                    GestureDetector(
                      onTap: (vm.isProcessingVoice && !vm.isRecording) ||
                              vm.isSending
                          ? null
                          : () async {
                              if (vm.isRecording) {
                                await vm.stopVoiceRecording();
                              } else {
                                await vm.startVoiceRecording();
                              }
                            },
                      onLongPress: (vm.isProcessingVoice && !vm.isRecording) ||
                              vm.isSending
                          ? null
                          : () async {
                              await vm.startVoiceRecording();
                            },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: vm.isRecording
                              ? Colors.green
                              : (vm.isProcessingVoice || vm.isSending
                                  ? Colors.white24
                                  : Colors.blueAccent),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (vm.isRecording)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                          ],
                        ),
                        child: vm.isProcessingVoice
                            ? const Padding(
                                padding: EdgeInsets.all(30),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                vm.isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 50,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Instruction Text
                    Text(
                      vm.isRecording
                          ? 'Streaming to AI... Tap to stop'
                          : 'Tap to start listening',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}