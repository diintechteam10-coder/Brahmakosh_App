import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class VoiceWebSocketService {
  static const String _wsUrl =
      'wss://backend-jfg8.onrender.com/api/voice/agent';

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _currentChatId;
  String? _currentUserId;

  // Callbacks
  Function(String chatId)? onStarted;
  Function(String message)? onDeepgramConnected;
  Function(String text, bool isFinal)? onTranscript;
  Function(String text)? onUserMessage;
  Function(String text)? onAiResponse;
  Function(Uint8List audioData, int chunkIndex)? onAudioChunk;
  Function(int totalChunks)? onAudioComplete;
  Function(String message)? onStopped;
  Function(String message, String? errorCode)? onError;

  // Start WebSocket session
  Future<void> startSession({String? chatId}) async {
    print('🔵 [WebSocket] ============================================');
    print('🔵 [WebSocket] Starting WebSocket session...');
    print('🔵 [WebSocket] WebSocket URL: $_wsUrl');
    print('🔵 [WebSocket] ChatId: ${chatId ?? "new"}');

    if (_isConnected) {
      print('🔵 [WebSocket] Already connected, stopping previous session...');
      await stopSession();
    }

    final token = StorageService.getString(AppConstants.keyAuthToken);
    _currentUserId = StorageService.getString(AppConstants.keyUserId);

    print('🔵 [WebSocket] Token exists: ${token != null && token.isNotEmpty}');
    print('🔵 [WebSocket] UserId: $_currentUserId');

    if (token == null || token.isEmpty || _currentUserId == null) {
      print('🔴 [WebSocket] ERROR: Authentication required');
      onError?.call('Authentication required', 'AUTH_ERROR');
      return;
    }

    try {
      // Connect to WebSocket with auth token
      // Try with token in query parameter first
      final fullUrl = '$_wsUrl?token=$token';
      print('🔵 [WebSocket] Connecting to: $fullUrl');
      print('🔵 [WebSocket] Parsing URI...');
      final uri = Uri.parse(fullUrl);
      print('🔵 [WebSocket] URI parsed: ${uri.toString()}');
      print(
        '🔵 [WebSocket] Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}',
      );

      print('🔵 [WebSocket] Creating WebSocket connection...');
      _channel = WebSocketChannel.connect(uri);
      print('🔵 [WebSocket] WebSocketChannel created');

      // Listen to messages
      print('🔵 [WebSocket] Setting up message listener...');
      _subscription = _channel!.stream.listen(
        (message) {
          print('🟢 [WebSocket] ============================================');
          print('🟢 [WebSocket] RECEIVED MESSAGE:');
          print('🟢 [WebSocket] Raw message: $message');
          try {
            final decoded = jsonDecode(message.toString());
            print('🟢 [WebSocket] Parsed JSON: $decoded');
          } catch (e) {
            print('🟢 [WebSocket] Message is not JSON: $e');
          }
          print('🟢 [WebSocket] ============================================');
          _handleMessage(message);
        },
        onError: (error) {
          print('🔴 [WebSocket] ============================================');
          print('🔴 [WebSocket] STREAM ERROR:');
          print('🔴 [WebSocket] Error: $error');
          print('🔴 [WebSocket] Error Type: ${error.runtimeType}');
          print('🔴 [WebSocket] ============================================');
          _isConnected = false;
          onError?.call('WebSocket error: $error', 'WS_ERROR');
        },
        onDone: () {
          print('🟡 [WebSocket] Stream done - connection closed by server');
          _isConnected = false;
        },
        cancelOnError: false,
      );
      print('🔵 [WebSocket] Message listener set up successfully');

      // Wait a moment for connection to stabilize, then send start message
      print('🔵 [WebSocket] Waiting 100ms for connection to stabilize...');
      await Future.delayed(const Duration(milliseconds: 100));
final agentId =
            StorageService.getString('ai_selected_agent_id') ?? 'default_agent';
              // Send start message
      final startMessage = jsonEncode({
        'type': 'start',
        'userId': _currentUserId,
        'chatId': chatId ?? 'new',
        'agentId': agentId,
      });

      print('🟡 [WebSocket] ============================================');
      print('🟡 [WebSocket] SENDING START MESSAGE:');
      print('🟡 START PAYLOAD JSON: $startMessage');
      print('🟡 [WebSocket] Message: $startMessage');
      print('🟡 [WebSocket] ============================================');

      _channel!.sink.add(startMessage);
      _isConnected = true;

      print('✅ [WebSocket] ============================================');
      print('✅ [WebSocket] WebSocket CONNECTED successfully!');
      print('✅ [WebSocket] Connection state: $_isConnected');
      print('✅ [WebSocket] Start message sent');
      print('✅ [WebSocket] ============================================');
    } catch (e, stackTrace) {
      print('🔴 [WebSocket] ============================================');
      print('🔴 [WebSocket] CONNECTION FAILED:');
      print('🔴 [WebSocket] Error: $e');
      print('🔴 [WebSocket] StackTrace: $stackTrace');
      print('🔴 [WebSocket] ============================================');
      _isConnected = false;
      onError?.call('Failed to connect: $e', 'CONNECTION_ERROR');
    }
  }

  // Send audio chunk (base64 encoded PCM)
  void sendAudioChunk(String base64AudioData) {
    if (!_isConnected || _channel == null) {
      print('⚠️ [WebSocket] Cannot send audio chunk - WebSocket not connected');
      print(
        '⚠️ [WebSocket] isConnected: $_isConnected, channel: ${_channel != null}',
      );
      return;
    }

    try {
      if (base64AudioData.isEmpty) {
        print('⚠️ [WebSocket] Attempted to send empty audio chunk');
        return;
      }

      final audioSize = base64AudioData.length;
      final message = jsonEncode({'type': 'audio', 'audio': base64AudioData});

      print(
        '🟡 [WebSocket] Sending audio chunk (size: $audioSize bytes, base64 length: ${base64AudioData.length})',
      );
      _channel!.sink.add(message);
      print('✅ [WebSocket] Audio chunk sent successfully');
    } catch (e, stackTrace) {
      print('🔴 [WebSocket] Error sending audio chunk: $e');
      print('🔴 [WebSocket] StackTrace: $stackTrace');
      onError?.call('Failed to send audio: $e', 'SEND_ERROR');
    }
  }

  // Stop session
  Future<void> stopSession() async {
    print('🟡 [WebSocket] ============================================');
    print('🟡 [WebSocket] Stopping WebSocket session...');
    print('🟡 [WebSocket] isConnected: $_isConnected');
    print('🟡 [WebSocket] channel exists: ${_channel != null}');

    if (_channel != null && _isConnected) {
      try {
        final stopMessage = jsonEncode({'type': 'stop'});
        print('🟡 [WebSocket] Sending stop message: $stopMessage');
        _channel!.sink.add(stopMessage);
        print('✅ [WebSocket] Stop message sent');
      } catch (e) {
        print('⚠️ [WebSocket] Error sending stop message: $e');
        // Ignore errors on stop
      }
    }

    print('🟡 [WebSocket] Cancelling subscription...');
    await _subscription?.cancel();
    _subscription = null;

    print('🟡 [WebSocket] Closing channel...');
    await _channel?.sink.close();
    _channel = null;

    _isConnected = false;
    print('✅ [WebSocket] WebSocket session stopped');
    print('🟡 [WebSocket] ============================================');
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      print('🔵 [WebSocket] Parsing message...');
      final Map<String, dynamic> data = jsonDecode(message.toString());
      final messageType = data['type']?.toString() ?? 'unknown';

      print('🔵 [WebSocket] Message type: $messageType');
      print('🔵 [WebSocket] Full data: $data');

      switch (data['type']) {
        case 'started':
          _currentChatId = data['chatId']?.toString();
          print('✅ [WebSocket] Session started! ChatId: $_currentChatId');
          onStarted?.call(_currentChatId ?? '');
          break;

        case 'deepgram_connected':
          final msg = data['message']?.toString() ?? '';
          print('✅ [WebSocket] Deepgram connected: $msg');
          onDeepgramConnected?.call(msg);
          break;

        case 'transcript':
          final text = data['text']?.toString() ?? '';
          final isFinal = data['isFinal'] == true;
          print('📝 [WebSocket] Transcript (isFinal: $isFinal): $text');
          onTranscript?.call(text, isFinal);
          break;

        case 'user_message':
          final text = data['text']?.toString() ?? '';
          print('👤 [WebSocket] User message: $text');
          onUserMessage?.call(text);
          break;

        case 'ai_response':
          final text = data['text']?.toString() ?? '';
          print('🤖 [WebSocket] AI response: $text');
          onAiResponse?.call(text);
          break;

        case 'audio_chunk':
          final audioBase64 = data['audio']?.toString() ?? '';
          final chunkIndex = data['chunkIndex'] is int
              ? data['chunkIndex'] as int
              : int.tryParse(data['chunkIndex']?.toString() ?? '0') ?? 0;
          print(
            '🎵 [WebSocket] Audio chunk received: index=$chunkIndex, size=${audioBase64.length} bytes (base64)',
          );
          if (audioBase64.isNotEmpty) {
            final audioBytes = base64Decode(audioBase64);
            print('🎵 [WebSocket] Audio decoded: ${audioBytes.length} bytes');
            onAudioChunk?.call(Uint8List.fromList(audioBytes), chunkIndex);
          } else {
            print('⚠️ [WebSocket] Empty audio chunk received');
          }
          break;

        case 'audio_complete':
          final totalChunks = data['totalChunks'] is int
              ? data['totalChunks'] as int
              : int.tryParse(data['totalChunks']?.toString() ?? '0') ?? 0;
          print('✅ [WebSocket] Audio complete! Total chunks: $totalChunks');
          onAudioComplete?.call(totalChunks);
          break;

        case 'stopped':
          final msg = data['message']?.toString() ?? '';
          print('🟡 [WebSocket] Session stopped: $msg');
          onStopped?.call(msg);
          break;

        case 'error':
          final errorMsg = data['message']?.toString() ?? 'Unknown error';
          final errorCode = data['error']?.toString();
          print('🔴 [WebSocket] ============================================');
          print('🔴 [WebSocket] ERROR MESSAGE RECEIVED:');
          print('🔴 [WebSocket] Error: $errorMsg');
          print('🔴 [WebSocket] Code: $errorCode');
          print('🔴 [WebSocket] Full error data: $data');
          print('🔴 [WebSocket] ============================================');
          onError?.call(errorMsg, errorCode);
          break;

        default:
          print('⚠️ [WebSocket] Unknown message type: $messageType');
          print('⚠️ [WebSocket] Full message data: $data');
          break;
      }
    } catch (e, stackTrace) {
      print('🔴 [WebSocket] ============================================');
      print('🔴 [WebSocket] Failed to parse message:');
      print('🔴 [WebSocket] Error: $e');
      print('🔴 [WebSocket] StackTrace: $stackTrace');
      print('🔴 [WebSocket] Raw message: $message');
      print('🔴 [WebSocket] ============================================');
      onError?.call('Failed to parse message: $e', 'PARSE_ERROR');
    }
  }

  bool get isConnected => _isConnected;
  String? get currentChatId => _currentChatId;

  void dispose() {
    stopSession();
  }
}
