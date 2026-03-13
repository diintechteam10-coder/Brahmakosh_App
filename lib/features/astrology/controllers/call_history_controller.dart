import 'dart:convert';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../common/utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/call_history_model.dart';

class CallHistoryController extends GetxController {
  final callLogs = <CallHistoryItem>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  // Audio Playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  final playingId = ''.obs; // The _id of the currently playing CallHistoryItem
  final isAudioLoading = false.obs;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  @override
  void onInit() {
    super.onInit();
    fetchCallHistory();
  }

  Future<void> fetchCallHistory() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) {
        isLoading.value = false;
        hasError.value = true;
        return;
      }

      await callWebApiGet(
        null, // No context/tickerProvider needed
        ApiUrls.callHistory,
        token: token,
        showLoader: false, // Background loading via shimmer
        onResponse: (response) {
          final data = jsonDecode(response.body);
          Utils.print('📞 Call History Response Body: ${response.body}');
          if (data['success'] == true) {
            final parsedResponse = CallHistoryResponse.fromJson(data);
            if (parsedResponse.data != null) {
              Utils.print(
                '📊 Number of call logs parsed: ${parsedResponse.data!.length}',
              );
              callLogs.assignAll(parsedResponse.data!);
            }
          } else {
            hasError.value = true;
          }
        },
        onError: (error) {
          Utils.print('❌ Error fetching call history: $error');
          hasError.value = true;
        },
      );
    } catch (e) {
      Utils.print('❌ Exception fetching call history: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
      Utils.print(
        '🏁 fetchCallHistory completed. Logs count: ${callLogs.length}',
      );
    }
  }

  /// Get partner name
  String getPartnerName(CallHistoryItem item) {
    if (item.to != null && item.to!.name != null && item.to!.name!.isNotEmpty) {
      return item.to!.name!;
    }
    return 'Expert';
  }

  /// Get formatted date display
  String getFormattedDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';

    // Check if yesterday or today
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Standardise duration presentation e.g 01:23
  String formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '00:00';
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Play a recording given its S3 key
  Future<void> playRecording(String key, String logId) async {
    try {
      if (playingId.value == logId) {
        await stopPlaying();
        return;
      }

      await stopPlaying(); // Stop any previous playback
      isAudioLoading.value = true;
      playingId.value = logId;

      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      // 1. Get Presigned URL
      String url = '';
      final encodedKey = Uri.encodeComponent(key);
      await callWebApiGet(
        null,
        '${ApiUrls.presignedUrl}/$encodedKey',
        token: token,
        showLoader: false,
        onResponse: (response) {
          final data = jsonDecode(response.body);
          Utils.print('🔗 Presigned URL Response: ${response.body}');
          if (data['data'] != null && data['data']['presignedUrl'] != null) {
            url = data['data']['presignedUrl'].toString();
          } else if (data['url'] != null) {
            url = data['url'].toString();
          }
        },
        onError: (e) => Utils.print('❌ Error getting presigned URL: $e'),
      );

      if (url.isEmpty) {
        playingId.value = '';
        isAudioLoading.value = false;
        return;
      }

      // 2. Play Audio
      await _audioPlayer.setUrl(url);
      isAudioLoading.value = false;

      // Listen for completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          playingId.value = '';
        }
      });

      await _audioPlayer.play();
    } catch (e) {
      Utils.print('❌ Audio Playback Error: $e');
      playingId.value = '';
      isAudioLoading.value = false;
    }
  }

  Future<void> stopPlaying() async {
    await _audioPlayer.stop();
    playingId.value = '';
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
