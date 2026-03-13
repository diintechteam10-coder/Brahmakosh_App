import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/call_history_controller.dart';
import '../models/call_history_model.dart';

class CallHistoryView extends StatelessWidget {
  const CallHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE6D0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Call Logs',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryGold,
        onRefresh: controller.fetchCallHistory,
        child: Obx(() {
          if (controller.isLoading.value && controller.callLogs.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, __) => _buildShimmerCard(),
            );
          }

          if (controller.hasError.value && controller.callLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load call logs',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: controller.fetchCallHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.callLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_in_talk_outlined,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No voice calls yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a voice call with an expert to see it here',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.callLogs.length,
            itemBuilder: (context, index) {
              final log = controller.callLogs[index];
              return _buildCallCard(context, log, controller);
            },
          );
        }),
      ),
    );
  }

  Widget _buildCallCard(
    BuildContext context,
    CallHistoryItem log,
    CallHistoryController controller,
  ) {
    debugPrint(
      '📱 Building Call Card for ID: ${log.id}, Status: ${log.status}',
    );
    final name = controller.getPartnerName(log);
    final status = log.status ?? 'ended';
    final date = controller.getFormattedDate(log.createdAt);
    final duration = controller.formatDuration(log.durationSeconds);
    final billableMin = log.billableMinutes ?? 0;

    final bool isEnded = status.toLowerCase() == 'ended';
    final bool isRejected = status.toLowerCase() == 'rejected';

    Color statusColor = isEnded
        ? Colors.green
        : isRejected
        ? const Color(0xFFE57373)
        : Colors.orange;
    String statusLabel = isEnded
        ? 'Completed'
        : (status.isNotEmpty
              ? status[0].toUpperCase() + status.substring(1)
              : 'Ended');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0), // Light theme as requested
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box / Profile Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: log.to?.image != null && log.to!.image!.isNotEmpty
                      ? Image.network(
                          log.to!.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF2E5AAC),
                                size: 28,
                              ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF2E5AAC),
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),

                // Name, Date, Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Play Button and Billable Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$billableMin Min',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (log.voiceRecordings?.user?.key != null ||
                        log.voiceRecordings?.partner?.key != null)
                      Obx(() {
                        final bool isPlaying =
                            controller.playingId.value == log.id;
                        final bool isLoading =
                            isPlaying && controller.isAudioLoading.value;
                        final String? key =
                            log.voiceRecordings?.user?.key ??
                            log.voiceRecordings?.partner?.key;

                        return GestureDetector(
                          onTap: () {
                            if (key != null && log.id != null) {
                              controller.playRecording(key, log.id!);
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppTheme.primaryGold,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    isPlaying
                                        ? Icons.stop_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppTheme.primaryGold,
                                    size: 30,
                                  ),
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),

            // Progress Slider
            if (log.voiceRecordings?.user?.key != null ||
                log.voiceRecordings?.partner?.key != null)
              Obx(() {
                final bool isPlaying = controller.playingId.value == log.id;
                if (!isPlaying) return const SizedBox.shrink();

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    StreamBuilder<Duration?>(
                      stream: controller.durationStream,
                      builder: (context, snapshot) {
                        final totalDuration = snapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: controller.positionStream,
                          builder: (context, snapshot) {
                            var position = snapshot.data ?? Duration.zero;
                            if (position > totalDuration)
                              position = totalDuration;

                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppTheme.primaryGold,
                                    inactiveTrackColor: AppTheme.primaryGold
                                        .withOpacity(0.1),
                                    thumbColor: AppTheme.primaryGold,
                                    overlayColor: AppTheme.primaryGold
                                        .withOpacity(0.2),
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                  ),
                                  child: Slider(
                                    value: position.inMilliseconds.toDouble(),
                                    max:
                                        totalDuration.inMilliseconds
                                                .toDouble() >
                                            0
                                        ? totalDuration.inMilliseconds
                                              .toDouble()
                                        : 1.0,
                                    onChanged: (value) {
                                      controller.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTime(position),
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(totalDuration),
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
