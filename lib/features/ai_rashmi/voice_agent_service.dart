// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:record/record.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// import '../../core/constants/app_constants.dart';
// import '../../core/services/storage_service.dart';

// enum VoiceAgentState {
//   IDLE,
//   CONNECTING,
//   LISTENING,
//   PROCESSING,
//   SPEAKING,
//   ERROR,
// }

// class VoiceAgentService extends ChangeNotifier {
//   WebSocketChannel? _channel;
//   final AudioRecorder _recorder = AudioRecorder();
//   final AudioPlayer _player = AudioPlayer();

//   VoiceAgentState _state = VoiceAgentState.IDLE;
//   VoiceAgentState get state => _state;

//   String _errorMessage = "";
//   String get errorMessage => _errorMessage;

//   String _interimText = "";
//   String get interimText => _interimText;

//   String _aiText = "";
//   String get aiText => _aiText;

//   // Audio Playback
//   final List<int> _audioBytesAccumulator = [];
//   final List<File> _tempAudioFiles = [];
//   StreamSubscription? _audioCompletionSubscription;
//   StreamSubscription? _recordSub;

//   // History Sync Callbacks
//   Function(String chatId)? onChatCreated;
//   Function(String text)? onUserMessage;
//   Function(String text)? onAiResponse;

//   String? _currentUserId;
//   String? _currentChatId;

//   // Enhance VAD: Add 'hasVoiceActivity' flag
//   bool _hasVoiceActivity = false;
//   DateTime? _lastVoiceActivity;

//   // Tuning silence threshold and timeout as requested
//   final double silenceThreshold = 0.02;
//   final Duration silenceTimeout = const Duration(milliseconds: 2000);

//   // Timeouts for stuck states
//   Timer? _processingTimeoutTimer;
//   Timer? _emptyTurnTimer;

//   bool _isIntentionalClose = false;

//   void _setState(VoiceAgentState newState) {
//     if (_state != newState) {
//       _state = newState;
//       debugPrint('[VoiceAgent] State changed: ${newState.name}');
//       notifyListeners();
//     }
//   }

//   Future<void> startSession(String userId, {String? chatId}) async {
//     if (_state != VoiceAgentState.IDLE && _state != VoiceAgentState.ERROR) {
//       debugPrint('[VoiceAgent] Already active');
//       return;
//     }

//     _isIntentionalClose = false;
//     _currentUserId = userId;
//     _currentChatId = chatId;

//     final micStatus = await Permission.microphone.request();
//     if (micStatus != PermissionStatus.granted) {
//       _errorMessage = "Microphone permission denied";
//       _setState(VoiceAgentState.ERROR);
//       return;
//     }

//     _setState(VoiceAgentState.CONNECTING);
//     _errorMessage = "";
//     _interimText = "";
//     _aiText = "";
//     _audioBytesAccumulator.clear();

//     await _connectWebSocket();
//   }

//   Future<void> _connectWebSocket({bool isReconnect = false}) async {
//     try {
//       final token = StorageService.getString(AppConstants.keyAuthToken);
//       final wsUrl = token != null && token.isNotEmpty
//           ? 'wss://prod.brahmakosh.com/api/voice/agent?token=$token'
//           : 'wss://prod.brahmakosh.com/api/voice/agent';

//       debugPrint('[VoiceAgent] Connecting to $wsUrl ...');
//       _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

//       _channel!.stream.listen(
//         _handleMessage,
//         onError: (error) {
//           debugPrint('[VoiceAgent] WebSocket Error: $error');
//           _errorMessage = 'WebSocket Error: $error';
//           _setState(VoiceAgentState.ERROR);
//         },
//         onDone: () {
//           debugPrint(
//             '[VoiceAgent] WebSocket stream onDone triggered. Intentional: $_isIntentionalClose',
//           );

//           // Add WebSocket auto-reconnect on onDone (unless intentional close).
//           if (!_isIntentionalClose) {
//             debugPrint('[VoiceAgent] Unexpected close. Reconnecting in 1s...');
//             Future.delayed(const Duration(milliseconds: 1000), () {
//               if (!_isIntentionalClose) {
//                 _connectWebSocket(isReconnect: true);
//               }
//             });
//           }
//         },
//       );

//       // Send start message ONLY once per session or on reconnect
//       if (_currentUserId != null) {
//         // final selectedVoice =
//         //     StorageService.getString('ai_selected_voice') ?? 'voice_1';
//         final agentId =
//             StorageService.getString('ai_selected_agent_id') ?? 'default_agent';
//         final payload = {
//           "type": "start",
//           "userId": _currentUserId,
//           "chatId": _currentChatId ?? "new",
//           // "voice": selectedVoice,
//           "agentId": agentId,
//         };
//         _sendWSMessage(payload);
//       }
//     } catch (e) {
//       debugPrint('[VoiceAgent] Connection Exception: $e');
//       _errorMessage = 'Connection Exception: $e';
//       _setState(VoiceAgentState.ERROR);
//       _cleanup(closeWebSocket: true);
//     }
//   }

//   void _sendWSMessage(Map<String, dynamic> payload) {
//     if (_channel != null && _channel?.closeCode == null) {
//       final jsonPayload = jsonEncode(payload);
//       if (payload["type"] != "audio") {
//         debugPrint('[VoiceAgent] ============================================');
//         debugPrint('[VoiceAgent] SENDING WS MESSAGE:');
//         debugPrint('[VoiceAgent] Type: ${payload["type"]}');
//         debugPrint('[VoiceAgent] Full Payload: $jsonPayload');
//         debugPrint('[VoiceAgent] ============================================');
//       }
//       _channel!.sink.add(jsonPayload);
//     } else {
//       debugPrint(
//         '[VoiceAgent] Cannot send, channel is null or closed. Payload type: ${payload["type"]}',
//       );
//     }
//   }

//   Future<void> _startMicrophone() async {
//     try {
//       if (await _recorder.isRecording()) {
//         debugPrint('[VoiceAgent] Microphone is already recording.');
//         return;
//       }

//       if (await _recorder.hasPermission()) {
//         debugPrint('[VoiceAgent] Starting microphone recording...');

//         _hasVoiceActivity = false;
//         _lastVoiceActivity = DateTime.now();

//         // Start empty turn timeout (10s reset if no voice)
//         _startEmptyTurnTimer();

//         final stream = await _recorder.startStream(
//           const RecordConfig(
//             encoder: AudioEncoder.pcm16bits,
//             sampleRate: 16000,
//             numChannels: 1,
//           ),
//         );

//         // Align state transition: LISTENING on started/audio_complete
//         _setState(VoiceAgentState.LISTENING);
//         _recordSub = stream.listen((data) {
//           _sendAudioChunk(data);
//         });
//       }
//     } catch (e) {
//       debugPrint('[VoiceAgent] Mic Error: $e');
//       _errorMessage = 'Mic Error: $e';
//       _setState(VoiceAgentState.ERROR);
//     }
//   }

//   void _startEmptyTurnTimer() {
//     _emptyTurnTimer?.cancel();
//     _emptyTurnTimer = Timer(const Duration(seconds: 10), () {
//       if (_state == VoiceAgentState.LISTENING && !_hasVoiceActivity) {
//         debugPrint(
//           '[VoiceAgent] Empty turn timeout reached. Resetting listening state...',
//         );
//         // Just reset the empty turn timer to keep listening continuously.
//         _startEmptyTurnTimer();
//       }
//     });
//   }

//   double _calculateRMS(Uint8List bytes) {
//     if (bytes.isEmpty) return 0.0;

//     double sumOfSquares = 0.0;
//     final int samples = bytes.length ~/ 2;

//     for (int i = 0; i < bytes.length - 1; i += 2) {
//       int sample = bytes[i] | (bytes[i + 1] << 8);
//       if (sample >= 32768) {
//         sample -= 65536;
//       }
//       double normalized = sample / 32768.0;
//       sumOfSquares += normalized * normalized;
//     }

//     return sqrt(sumOfSquares / samples);
//   }

//   Future<void> _stopMicrophone() async {
//     debugPrint('[VoiceAgent] Pausing Microphone...');
//     await _recordSub?.cancel();
//     _recordSub = null;
//     if (await _recorder.isRecording()) {
//       await _recorder.stop();
//     }
//     _emptyTurnTimer?.cancel();
//   }

//   void _sendAudioChunk(Uint8List bytes) async {
//     if (_state != VoiceAgentState.LISTENING) return;

//     double rms = _calculateRMS(bytes);
//     if (rms > silenceThreshold) {
//       if (!_hasVoiceActivity) {
//         debugPrint('[VoiceAgent] Voice activity started.');
//       }
//       _hasVoiceActivity = true;
//       _lastVoiceActivity = DateTime.now();
//     } else if (_hasVoiceActivity && _lastVoiceActivity != null) {
//       // Only check silence timeout if voice was actually detected
//       final silenceDuration = DateTime.now().difference(_lastVoiceActivity!);
//       if (silenceDuration > silenceTimeout) {
//         debugPrint(
//           '[VoiceAgent] Local silence detected after voice activity. Waiting for server to send user_message...',
//         );

//         await _stopMicrophone(); // ONLY stops mic, does not send 'stop'

//         // Setup a 10s timeout after local silence if no server response
//         _processingTimeoutTimer?.cancel();
//         _processingTimeoutTimer = Timer(const Duration(seconds: 10), () {
//           if (_state == VoiceAgentState.LISTENING ||
//               _state == VoiceAgentState.PROCESSING) {
//             debugPrint(
//               '[VoiceAgent] Stuck state timeout reached after local silence. No server response. Restarting mic...',
//             );
//             _setState(VoiceAgentState.LISTENING);
//             _startMicrophone(); // Retry listening
//           }
//         });

//         // Wait for 'user_message' message to officially change state to PROCESSING from server
//         return;
//       }
//     }

//     final base64Audio = base64Encode(bytes);
//     final payload = {"type": "audio", "audio": base64Audio};
//     _sendWSMessage(payload);
//   }

//   void stopSession() {
//     debugPrint('[VoiceAgent] Stopping session (Screen Exit)...');
//     _isIntentionalClose = true;
//     _sendWSMessage({"type": "stop"});
//     _cleanup(closeWebSocket: true);
//     _setState(VoiceAgentState.IDLE);
//   }

//   void _handleMessage(dynamic message) {
//     try {
//       final data = jsonDecode(message);
//       final type = data['type'];
//       if (type != 'audio_chunk') {
//         debugPrint('[VoiceAgent] Received WS Message: $type');
//       }

//       switch (type) {
//         case 'deepgram_connected':
//           debugPrint(
//             '[VoiceAgent] Deepgram connected. Waiting for started event.',
//           );
//           break;

//         case 'started':
//           debugPrint('[VoiceAgent] Agent started. Turning on mic.');

//           // Capture new chatId if provided
//           if (data['chatId'] != null) {
//             _currentChatId = data['chatId'].toString();
//             onChatCreated?.call(_currentChatId!);
//           }

//           // Align state transition: LISTENING on started
//           _startMicrophone();
//           break;

//         case 'transcript':
//           _onTranscript(data);
//           break;

//         case 'user_message':
//           debugPrint('[VoiceAgent] User message: ${data['text']}');
//           _processingTimeoutTimer?.cancel(); // Server responded!

//           if (data['text'] != null && data['text'].toString().isNotEmpty) {
//             onUserMessage?.call(data['text'].toString());
//           }

//           // Stop mic on user_message (if not already stopped by local silence)
//           _stopMicrophone();

//           // Align state transition: PROCESSING on user_message
//           _setState(VoiceAgentState.PROCESSING);
//           break;

//         case 'ai_response':
//           debugPrint('[VoiceAgent] Agent processing AI response...');
//           if (data['text'] != null && data['text'].toString().isNotEmpty) {
//             onAiResponse?.call(data['text'].toString());
//           }
//           // State stays PROCESSING until first audio chunk
//           _onAiResponse(data);
//           break;

//         case 'audio_chunk':
//           debugPrint('🔥 AUDIO CHUNK RECEIVED');
//           _onAudioChunk(data);
//           break;

//         case 'audio_complete':
//           _onAudioComplete(data);
//           break;

//         case 'error':
//           debugPrint('[VoiceAgent] Server Error Message: ${data['message']}');
//           _errorMessage = data['message'] ?? 'Unknown Server Error';
//           _setState(VoiceAgentState.ERROR);
//           break;

//         default:
//           debugPrint('[VoiceAgent] Unhandled message type: $type');
//       }
//     } catch (e) {
//       // Ignored for raw audio or non-json if any
//     }
//   }

//   void _onTranscript(Map data) {
//     final text = data['text'];
//     final isFinal = data['isFinal'];
//     debugPrint('[VoiceAgent] Transcript: $text (isFinal: $isFinal)');

//     _interimText = text;
//     notifyListeners();
//   }

//   void _onAiResponse(Map data) {
//     final aiResponseText = data['text'];
//     debugPrint('[VoiceAgent] AI Response Text: $aiResponseText');
//     _aiText = aiResponseText;
//     notifyListeners();
//   }

//   void _onAudioChunk(Map data) {
//     // Stop mic during SPEAKING to prevent echo.
//     if (_state != VoiceAgentState.SPEAKING) {
//       // Align state transition: SPEAKING on first audio_chunk
//       _setState(VoiceAgentState.SPEAKING);
//       _stopMicrophone(); // ensure mic is off
//     }
//     final chunkBase64 = data['audio'];
//     if (chunkBase64 != null) {
//       final bytes = base64Decode(chunkBase64);
//       _audioBytesAccumulator.addAll(bytes);
//     }
//   }

//   Future<void> _onAudioComplete(Map data) async {
//     debugPrint(
//       '[VoiceAgent] Audio complete received. Playing accumulated response.',
//     );

//     if (_audioBytesAccumulator.isNotEmpty) {
//       try {
//         final directory = await getTemporaryDirectory();
//         final timestamp = DateTime.now().millisecondsSinceEpoch;
//         final chunkPath = '${directory.path}/agent_full_audio_$timestamp.mp3';
//         final chunkFile = File(chunkPath);

//         await chunkFile.writeAsBytes(_audioBytesAccumulator);
//         _tempAudioFiles.add(chunkFile);

//         await _audioCompletionSubscription?.cancel();

//         final completer = Completer<void>();
//         _audioCompletionSubscription = _player.playerStateStream.listen((
//           state,
//         ) {
//           if (state.processingState == ProcessingState.completed) {
//             if (!completer.isCompleted) completer.complete();
//           }
//         });

//         await _player.setAudioSource(AudioSource.uri(Uri.file(chunkPath)));
//         await _player.play();
//         await completer.future;

//         try {
//           if (chunkFile.existsSync()) {
//             chunkFile.delete();
//             _tempAudioFiles.remove(chunkFile);
//           }
//         } catch (e) {
//           // ignore
//         }
//       } catch (e) {
//         debugPrint('[VoiceAgent] Audio playback error: $e');
//       }

//       _audioBytesAccumulator.clear();
//     }

//     debugPrint('[VoiceAgent] Agent finished speaking. Resuming listening...');
//     _interimText = "";
//     _aiText = "";

//     await _startMicrophone();
//   }

//   Future<void> _cleanup({bool closeWebSocket = true}) async {
//     debugPrint('[VoiceAgent] Cleanup resources. closeWS=$closeWebSocket');
//     try {
//       _emptyTurnTimer?.cancel();
//       _processingTimeoutTimer?.cancel();
//       _audioCompletionSubscription?.cancel();
//       await _recordSub?.cancel();
//       _recordSub = null;
//       if (await _recorder.isRecording()) {
//         await _recorder.stop();
//       }
//       if (closeWebSocket && _channel != null) {
//         _channel!.sink.close();
//         _channel = null;
//       }
//       _audioBytesAccumulator.clear();
//       await _player.stop(); // Stop audio playback immediately

//       for (var file in _tempAudioFiles) {
//         try {
//           if (file.existsSync()) file.delete();
//         } catch (_) {}
//       }
//       _tempAudioFiles.clear();
//     } catch (e) {
//       debugPrint('[VoiceAgent] Cleanup error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _isIntentionalClose = true;
//     _cleanup(closeWebSocket: true);
//     _player.dispose();
//     _recorder.dispose();
//     super.dispose();
//   }

//   // No AppAudioSource needed
// }

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

enum VoiceAgentState {
  IDLE,
  CONNECTING,
  LISTENING,
  PROCESSING,
  SPEAKING,
  ERROR,
}

class VoiceAgentService extends ChangeNotifier {
  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  VoiceAgentState _state = VoiceAgentState.IDLE;
  VoiceAgentState get state => _state;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  String _interimText = "";
  String get interimText => _interimText;

  String _aiText = "";
  String get aiText => _aiText;

  // Audio Playback
  final List<int> _audioBytesAccumulator = [];
  final List<File> _tempAudioFiles = [];
  StreamSubscription? _audioCompletionSubscription;
  StreamSubscription? _recordSub;

  // History Sync Callbacks
  Function(String chatId)? onChatCreated;
  Function(String text)? onUserMessage;
  Function(String text)? onAiResponse;

  String? _currentUserId;
  String? _currentChatId;

  // Enhance VAD: Add 'hasVoiceActivity' flag
  bool _hasVoiceActivity = false;
  DateTime? _lastVoiceActivity;

  // Tuning silence threshold and timeout as requested
  final double silenceThreshold = 0.02;
  final Duration silenceTimeout = const Duration(milliseconds: 2000);

  // Timeouts for stuck states
  Timer? _processingTimeoutTimer;
  Timer? _emptyTurnTimer;

  bool _isIntentionalClose = false;

  void _setState(VoiceAgentState newState) {
    if (_state != newState) {
      _state = newState;
      debugPrint('[VoiceAgent] State changed: ${newState.name}');
      notifyListeners();
    }
  }

  Future<void> startSession(String userId, {String? chatId}) async {
    if (_state != VoiceAgentState.IDLE && _state != VoiceAgentState.ERROR) {
      debugPrint('[VoiceAgent] Already active');
      return;
    }

    _isIntentionalClose = false;
    _currentUserId = userId;
    _currentChatId = chatId;

    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      _errorMessage = "Microphone permission denied";
      _setState(VoiceAgentState.ERROR);
      return;
    }

    _setState(VoiceAgentState.CONNECTING);
    _errorMessage = "";
    _interimText = "";
    _aiText = "";
    _audioBytesAccumulator.clear();

    await _connectWebSocket();
  }

  Future<void> _connectWebSocket({bool isReconnect = false}) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      final wsUrl = token != null && token.isNotEmpty
          ? 'wss://prod.brahmakosh.com/api/voice/agent?token=$token'
          : 'wss://prod.brahmakosh.com/api/voice/agent';

      debugPrint('[VoiceAgent] Connecting to $wsUrl ...');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('[VoiceAgent] WebSocket Error: $error');
          _errorMessage = 'WebSocket Error: $error';
          _setState(VoiceAgentState.ERROR);
        },
        onDone: () {
          debugPrint(
            '[VoiceAgent] WebSocket stream onDone triggered. Intentional: $_isIntentionalClose',
          );

          // Add WebSocket auto-reconnect on onDone (unless intentional close).
          if (!_isIntentionalClose) {
            debugPrint('[VoiceAgent] Unexpected close. Reconnecting in 1s...');
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (!_isIntentionalClose) {
                _connectWebSocket(isReconnect: true);
              }
            });
          }
        },
      );

      // Send start message ONLY once per session or on reconnect
      if (_currentUserId != null) {
        final agentId =
            StorageService.getString('ai_selected_agent_id') ?? 'default_agent';

        final selectedVoice =
            StorageService.getString('ai_selected_voice') ?? 'voice_1';
        final payload = {
          "type": "start",
          "userId": _currentUserId,
          "chatId": _currentChatId ?? "new",
          "agentId": agentId,
          "voice": selectedVoice,
        };
        _sendWSMessage(payload);
      }
    } catch (e) {
      debugPrint('[VoiceAgent] Connection Exception: $e');
      _errorMessage = 'Connection Exception: $e';
      _setState(VoiceAgentState.ERROR);
      _cleanup(closeWebSocket: true);
    }
  }

  void _sendWSMessage(Map<String, dynamic> payload) {
    if (_channel != null && _channel?.closeCode == null) {
      final jsonPayload = jsonEncode(payload);
      if (payload["type"] != "audio") {
        debugPrint('[VoiceAgent] Sending: ${payload["type"]}');
      }
      _channel!.sink.add(jsonPayload);
    } else {
      debugPrint(
        '[VoiceAgent] Cannot send, channel is null or closed. Payload type: ${payload["type"]}',
      );
    }
  }

  Future<void> _startMicrophone() async {
    try {
      if (await _recorder.isRecording()) {
        debugPrint('[VoiceAgent] Microphone is already recording.');
        return;
      }

      if (await _recorder.hasPermission()) {
        debugPrint('[VoiceAgent] Starting microphone recording...');

        _hasVoiceActivity = false;
        _lastVoiceActivity = DateTime.now();

        // Start empty turn timeout (10s reset if no voice)
        _startEmptyTurnTimer();

        final stream = await _recorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        // Align state transition: LISTENING on started/audio_complete
        _setState(VoiceAgentState.LISTENING);
        _recordSub = stream.listen((data) {
          _sendAudioChunk(data);
        });
      }
    } catch (e) {
      debugPrint('[VoiceAgent] Mic Error: $e');
      _errorMessage = 'Mic Error: $e';
      _setState(VoiceAgentState.ERROR);
    }
  }

  void _startEmptyTurnTimer() {
    _emptyTurnTimer?.cancel();
    _emptyTurnTimer = Timer(const Duration(seconds: 10), () {
      if (_state == VoiceAgentState.LISTENING && !_hasVoiceActivity) {
        debugPrint(
          '[VoiceAgent] Empty turn timeout reached. Resetting listening state...',
        );
        // Just reset the empty turn timer to keep listening continuously.
        _startEmptyTurnTimer();
      }
    });
  }

  double _calculateRMS(Uint8List bytes) {
    if (bytes.isEmpty) return 0.0;

    double sumOfSquares = 0.0;
    final int samples = bytes.length ~/ 2;

    for (int i = 0; i < bytes.length - 1; i += 2) {
      int sample = bytes[i] | (bytes[i + 1] << 8);
      if (sample >= 32768) {
        sample -= 65536;
      }
      double normalized = sample / 32768.0;
      sumOfSquares += normalized * normalized;
    }

    return sqrt(sumOfSquares / samples);
  }

  Future<void> _stopMicrophone() async {
    debugPrint('[VoiceAgent] Pausing Microphone...');
    await _recordSub?.cancel();
    _recordSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    _emptyTurnTimer?.cancel();
  }

  void _sendAudioChunk(Uint8List bytes) async {
    if (_state != VoiceAgentState.LISTENING) return;

    double rms = _calculateRMS(bytes);
    if (rms > silenceThreshold) {
      if (!_hasVoiceActivity) {
        debugPrint('[VoiceAgent] Voice activity started.');
      }
      _hasVoiceActivity = true;
      _lastVoiceActivity = DateTime.now();
    } else if (_hasVoiceActivity && _lastVoiceActivity != null) {
      // Only check silence timeout if voice was actually detected
      final silenceDuration = DateTime.now().difference(_lastVoiceActivity!);
      if (silenceDuration > silenceTimeout) {
        debugPrint(
          '[VoiceAgent] Local silence detected after voice activity. Waiting for server to send user_message...',
        );

        await _stopMicrophone(); // ONLY stops mic, does not send 'stop'
        _sendWSMessage({"type": "stop"});
        // Setup a 10s timeout after local silence if no server response
        _processingTimeoutTimer?.cancel();
        _processingTimeoutTimer = Timer(const Duration(seconds: 10), () {
          if (_state == VoiceAgentState.LISTENING ||
              _state == VoiceAgentState.PROCESSING) {
            debugPrint(
              '[VoiceAgent] Stuck state timeout reached after local silence. No server response. Restarting mic...',
            );
            _setState(VoiceAgentState.LISTENING);
            _startMicrophone(); // Retry listening
          }
        });

        // Wait for 'user_message' message to officially change state to PROCESSING from server
        return;
      }
    }
    debugPrint("🎤 AUDIO CHUNK SENT: ${bytes.length}");
    final base64Audio = base64Encode(bytes);
    final payload = {"type": "audio", "audio": base64Audio};
    _sendWSMessage(payload);
  }

  void stopSession() {
    debugPrint('[VoiceAgent] Stopping session (Screen Exit)...');
    _isIntentionalClose = true;
    _sendWSMessage({"type": "stop"});
    _cleanup(closeWebSocket: true);
    _setState(VoiceAgentState.IDLE);
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      if (type != 'audio_chunk') {
        debugPrint('[VoiceAgent] Received WS Message: $type');
      }

      switch (type) {
        case 'deepgram_connected':
          debugPrint(
            '[VoiceAgent] Deepgram connected. Waiting for started event.',
          );
          break;

        case 'started':
          debugPrint('[VoiceAgent] Agent started. Turning on mic.');

          // Capture new chatId if provided
          if (data['chatId'] != null) {
            _currentChatId = data['chatId'].toString();
            onChatCreated?.call(_currentChatId!);
          }

          // Align state transition: LISTENING on started
          _startMicrophone();
          break;

        case 'transcript':
          _onTranscript(data);
          break;

        case 'user_message':
          debugPrint('[VoiceAgent] User message: ${data['text']}');
          _processingTimeoutTimer?.cancel(); // Server responded!

          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            onUserMessage?.call(data['text'].toString());
          }

          // Stop mic on user_message (if not already stopped by local silence)
          _stopMicrophone();

          // Align state transition: PROCESSING on user_message
          _setState(VoiceAgentState.PROCESSING);
          break;

        case 'ai_response':
          debugPrint('[VoiceAgent] Agent processing AI response...');
          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            onAiResponse?.call(data['text'].toString());
          }
          // State stays PROCESSING until first audio chunk
          _onAiResponse(data);
          break;

        case 'audio_chunk':
          // debugPrint('🔥 AUDIO CHUNK RECEIVED');
          _onAudioChunk(data);
          break;

        case 'audio_complete':
          _onAudioComplete(data);
          break;

        case 'error':
          debugPrint('[VoiceAgent] Server Error Message: ${data['message']}');
          _errorMessage = data['message'] ?? 'Unknown Server Error';
          _setState(VoiceAgentState.ERROR);
          break;

        default:
          debugPrint('[VoiceAgent] Unhandled message type: $type');
      }
    } catch (e) {
      // Ignored for raw audio or non-json if any
    }
  }

  void _onTranscript(Map data) {
    final text = data['text'];
    final isFinal = data['isFinal'];
    debugPrint('[VoiceAgent] Transcript: $text (isFinal: $isFinal)');

    _interimText = text;
    notifyListeners();
  }

  void _onAiResponse(Map data) {
    final aiResponseText = data['text'];
    debugPrint('[VoiceAgent] AI Response Text: $aiResponseText');
    _aiText = aiResponseText;
    notifyListeners();
  }

  void _onAudioChunk(Map data) {
    // Stop mic during SPEAKING to prevent echo.
    if (_state != VoiceAgentState.SPEAKING) {
      // Align state transition: SPEAKING on first audio_chunk
      _setState(VoiceAgentState.SPEAKING);
      _stopMicrophone(); // ensure mic is off
    }
    final chunkBase64 = data['audio'];
    if (chunkBase64 != null) {
      final bytes = base64Decode(chunkBase64);
      _audioBytesAccumulator.addAll(bytes);
    }
  }

  Future<void> _onAudioComplete(Map data) async {
    debugPrint(
      '[VoiceAgent] Audio complete received. Playing accumulated response.',
    );

    if (_audioBytesAccumulator.isNotEmpty) {
      try {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final chunkPath = '${directory.path}/agent_full_audio_$timestamp.mp3';
        final chunkFile = File(chunkPath);

        await chunkFile.writeAsBytes(_audioBytesAccumulator);
        _tempAudioFiles.add(chunkFile);

        await _audioCompletionSubscription?.cancel();

        final completer = Completer<void>();
        _audioCompletionSubscription = _player.playerStateStream.listen((
          state,
        ) {
          if (state.processingState == ProcessingState.completed) {
            if (!completer.isCompleted) completer.complete();
          }
        });

        await _player.setAudioSource(AudioSource.uri(Uri.file(chunkPath)));
        await _player.play();
        await completer.future;

        try {
          if (chunkFile.existsSync()) {
            chunkFile.delete();
            _tempAudioFiles.remove(chunkFile);
          }
        } catch (e) {
          // ignore
        }
      } catch (e) {
        debugPrint('[VoiceAgent] Audio playback error: $e');
      }

      _audioBytesAccumulator.clear();
    }

    debugPrint('[VoiceAgent] Agent finished speaking. Resuming listening...');
    _interimText = "";
    _aiText = "";

    await _startMicrophone();
  }

  Future<void> _cleanup({bool closeWebSocket = true}) async {
    debugPrint('[VoiceAgent] Cleanup resources. closeWS=$closeWebSocket');
    try {
      _emptyTurnTimer?.cancel();
      _processingTimeoutTimer?.cancel();
      _audioCompletionSubscription?.cancel();
      await _recordSub?.cancel();
      _recordSub = null;
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      if (closeWebSocket && _channel != null) {
        _channel!.sink.close();
        _channel = null;
      }
      _audioBytesAccumulator.clear();
      await _player.stop(); // Stop audio playback immediately

      for (var file in _tempAudioFiles) {
        try {
          if (file.existsSync()) file.delete();
        } catch (_) {}
      }
      _tempAudioFiles.clear();
    } catch (e) {
      debugPrint('[VoiceAgent] Cleanup error: $e');
    }
  }

  @override
  void dispose() {
    _isIntentionalClose = true;
    _cleanup(closeWebSocket: true);
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  // No AppAudioSource needed
}
