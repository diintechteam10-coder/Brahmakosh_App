import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/chanting_mantra.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart'; // Added
import 'package:brahmakosh/core/constants/app_constants.dart';

class MantraChantingController extends GetxController
    with GetTickerProviderStateMixin {
  var chantCount = 0.obs;
  var isCompleted = false.obs;
  final _chantingMantras = <Data>[].obs; // Observable for list of mantras
  final _selectedIndex = 0.obs; // Observable for selected mantra index
  final _isLoading = false.obs; // Observable for loading state

  // New Variables for Dynamic Config
  SpiritualConfiguration? _spiritualConfig;
  String? _audioUrl;
  final AudioPlayer _backgroundAudioPlayer =
      AudioPlayer(); // For background chant

  // Animation State for Mantra Text Emergence
  final isMantraVisible = false.obs;
  final animationTriggers = <int>[].obs;

  List<Data> get chantingMantras => _chantingMantras.value;
  Data? get chantingMantra => _chantingMantras.isNotEmpty
      ? _chantingMantras[_selectedIndex.value]
      : null;
  RxInt get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading.value;
  late AnimationController scaleController;
  late AnimationController rippleController;
  late AnimationController glowController;
  late AnimationController celebrationController;

  late Animation<double> scaleAnimation;
  late Animation<double> rippleAnimation;
  late Animation<double> glowAnimation;

  final AudioPlayer _effectAudioPlayer = AudioPlayer(); // For bell sound

  Timer? _timer;
  final elapsedSeconds = 0.obs;

  String get formattedTime {
    final minutes = (elapsedSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void onInit() {
    super.onInit();
    // fetchChantingMantras(); // Logic modified to handle args first

    // Initial state: visible at top
    isMantraVisible.value = true;

    scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
    );

    rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: rippleController, curve: Curves.easeOut));

    glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut));

    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _handleArguments();

    // Play Background Audio (handles fallback internally)
    _playBackgroundAudio();
  }

  void _handleArguments() {
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      // 1. Check for Spiritual Configuration (New Flow)
      if (args.containsKey('configuration')) {
        final config = args['configuration'];
        if (config is SpiritualConfiguration) {
          _spiritualConfig = config;

          // Create a synthetic Data object for UI compatibility
          final mantraName = _getMantraNameFromConfig(config);
          final count = args['count'] as int? ?? 108;

          final syntheticMantra = Data(
            sId: config.sId,
            name: mantraName,
            description: config.description,
            malaCount: count,
            // Add other fields if necessary
          );

          _chantingMantras.assignAll([syntheticMantra]);
          _selectedIndex.value = 0;

          // Audio URL
          if (args.containsKey('audioUrl')) {
            _audioUrl = args['audioUrl'];
          }
          return; // Skip normal fetch
        }
      }

      // Legacy/Fallback Logic
      fetchChantingMantras();
    } else {
      fetchChantingMantras();
    }
  }

  String _getMantraNameFromConfig(SpiritualConfiguration config) {
    if (config.chantingType != null &&
        config.chantingType!.isNotEmpty &&
        config.chantingType != "Other") {
      return config.chantingType!;
    }
    if (config.customChantingType != null &&
        config.customChantingType!.isNotEmpty) {
      return config.customChantingType!;
    }
    return "Mantra";
  }

  Future<void> _playBackgroundAudio() async {
    try {
      if (_audioUrl != null && _audioUrl!.startsWith('http')) {
        // Network Source
        await _backgroundAudioPlayer.setSourceUrl(_audioUrl!);
      } else {
        // Fallback to Asset Source
        debugPrint("🔊 No valid network audio URL, using default fallback.");
        await _backgroundAudioPlayer.setSource(
          AssetSource('images/Default_music.mpeg'),
        );
      }

      await _backgroundAudioPlayer.setReleaseMode(ReleaseMode.loop); // Loop
      await _backgroundAudioPlayer.setVolume(0.5); // Moderate volume
      await _backgroundAudioPlayer.resume();
    } catch (e) {
      debugPrint("❌ Error playing background audio: $e");
    }
  }

  Future<void> fetchChantingMantras() async {
    _isLoading.value = true;
    try {
      final response = await getChantingMantras(null);
      if (response != null &&
          response.success == true &&
          response.data != null) {
        _chantingMantras.assignAll(response.data!);

        // Apply arguments override legacy
        if (Get.arguments != null && Get.arguments is Map) {
          final args = Get.arguments as Map;

          // 1. Handle Selection of Mantra
          if (args.containsKey('mantra')) {
            final selectedM = args['mantra'];
            if (selectedM != null && selectedM is Data) {
              final index = _chantingMantras.indexWhere(
                (m) => m.sId == selectedM.sId,
              );
              if (index != -1) {
                _selectedIndex.value = index;
              }
            }
          }

          // 2. Handle Count Override
          final count = args['count'];
          if (count != null && count is int) {
            for (var mantra in _chantingMantras) {
              mantra.malaCount = count;
            }
          }
        } else if (_chantingMantras.isNotEmpty) {
          _selectedIndex.value = 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching chanting mantras: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> incrementCount() async {
    if (chantingMantra == null ||
        chantCount.value >= (chantingMantra!.malaCount ?? 108))
      return;

    // Start timer if first chant
    startTimer();

    chantCount.value++;

    // Trigger animations
    scaleController.forward().then((_) => scaleController.reverse());
    rippleController.forward(from: 0.0);

    // Trigger Projectile Animation
    animationTriggers.add(DateTime.now().millisecondsSinceEpoch);

    // Check if completed 108
    if (chantCount.value == (chantingMantra!.malaCount ?? 108)) {
      await _backgroundAudioPlayer.stop(); // Stop immediately
      isCompleted.value = true;
      stopTimer(); // Stop timer
      celebrationController.forward();
      await _celebrateCompletion();
    }
  }

  Future<void> _celebrateCompletion() async {
    // Vibrate the device
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500, amplitude: 128);
    }

    // Play completion sound
    try {
      await _effectAudioPlayer.play(AssetSource('sounds/bell.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }

    // Dialog is now handled by the View listening to 'isCompleted'
  }

  void resetCount() {
    chantCount.value = 0;
    isCompleted.value = false;
    stopTimer();
    elapsedSeconds.value = 0;
    celebrationController.reset();
  }

  void selectMantra(int index) {
    if (index >= 0 && index < _chantingMantras.length) {
      _selectedIndex.value = index;
      resetCount(); // Reset count when changing mantra
    }
  }

  @override
  void onClose() {
    _effectAudioPlayer.dispose();
    _backgroundAudioPlayer.dispose();
    scaleController.dispose();
    rippleController.dispose();
    glowController.dispose();
    celebrationController.dispose();
    stopTimer();
    super.onClose();
  }
}
