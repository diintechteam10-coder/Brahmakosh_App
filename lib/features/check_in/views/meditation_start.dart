import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_clip_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brahmakosh/features/check_in/blocs/meditation_session/meditation_session_bloc.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

class MeditationStart extends StatelessWidget {
  const MeditationStart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MeditationSessionBloc(repository: SpiritualRepository()),
      child: const MeditationPlaybackView(),
    );
  }
}

class MeditationPlaybackView extends StatefulWidget {
  const MeditationPlaybackView({super.key});

  @override
  State<MeditationPlaybackView> createState() => _MeditationPlaybackViewState();
}

class _MeditationPlaybackViewState extends State<MeditationPlaybackView>
    with TickerProviderStateMixin {
  // 🔹 Entry animation
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 🔹 Breathing / Pulse
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bgScaleAnimation;
  // 🔹 Halo & Rotation
  late AnimationController _haloController;

  // 🔹 Ripple
  late AnimationController _rippleController;

  bool showPlayImage = false;
  bool showPlayUI = false;
  bool _isStarted = false;
  bool _isPlaying = false;

  late AnimationController _timerController;

  int _totalDuration = 60; // Default, will be updated from arguments
  SpiritualConfiguration? _config;

  // 🔹 Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioUrl;
  String? _currentVideoUrl; // Added to store video URL from API
  bool _isAudioInitialized = false;

  // 🔹 Video Player
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  /*
  bool _showSongSelection = false;
  int _selectedTrack = 0;
  final List<String> _tracks = [
    "Zen Garden",
    "Deep Space",
    "Healing Rain",
    "Morning Mist",
    "Cosmic Om",
    "Nature's Call",
  ];
  */

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null) {
      if (args['duration'] != null) {
        // duration passed in minutes, convert to seconds
        _totalDuration = (args['duration'] as num).toInt() * 60;
      }
      if (args['config'] != null) {
        _config = args['config'] as SpiritualConfiguration?;
      }
    }

    _parseMediaUrls(); // Parse URLs early

    /// 1️⃣ ENTRY
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const _SafeCurve(Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const _SafeCurve(Curves.elasticOut),
      ),
    );

    /// 2️⃣ BREATHING (Pulsating heart of the scene)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: const _SafeCurve(Curves.easeInOutSine),
      ),
    );
    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: const _SafeCurve(Curves.easeInOutSine),
      ),
    );

    /// 3️⃣ HALO ROTATION (Constant celestial rotation)
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    /// 4️⃣ RIPPLE
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    /// 5️⃣ TIMER
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalDuration),
    );

    // Listen for timer completion
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Stop audio when timer completes
        if (_isAudioInitialized) {
          try {
            _audioPlayer.stop();
          } catch (e) {
            print("Error stopping audio: $e");
          }
        }
        setState(() {
          _isPlaying = false;
          _isStarted = false;
        });

        // Save Session
        _triggerSaveSession();
      }
    });

    _initVideo();
    _initAudio(); // Start initializing and buffering audio early
  }

  void _parseMediaUrls() {
    final args = Get.arguments;
    List? clips;
    if (args != null) {
      if (args['clips'] is List) {
        clips = args['clips'];
      } else if (args['audioUrl'] != null) {
        // Handle case where audioUrl is passed directly
        clips = [
          {'audioUrl': args['audioUrl'], 'videoUrl': args['videoUrl']},
        ];
      }
    }

    String sourceUrl = "";
    String? videoSourceUrl;

    if (clips != null && clips.isNotEmpty) {
      final clip = clips[0];
      // Handle SpiritualClip Object
      if (clip is SpiritualClip) {
        if (clip.audioUrl != null && clip.audioUrl!.isNotEmpty) {
          sourceUrl = clip.audioUrl!;
        } else if (clip.fileUrl != null && clip.fileUrl!.isNotEmpty) {
          sourceUrl = clip.fileUrl!;
        }
        // capture video url
        if (clip.videoUrl != null && clip.videoUrl!.isNotEmpty) {
          videoSourceUrl = clip.videoUrl;
        }
      }
      // Handle Map (JSON)
      else if (clip is Map) {
        final audio = clip['audioUrl'];
        final file = clip['url'] ?? clip['fileUrl'];
        final video = clip['videoUrl'];

        if (audio != null && audio.toString().isNotEmpty) {
          sourceUrl = audio.toString();
        } else if (file != null && file.toString().isNotEmpty) {
          sourceUrl = file.toString();
        }

        if (video != null && video.toString().isNotEmpty) {
          videoSourceUrl = video.toString();
        }
      }
      // Final fallback (Dynamic access)
      else {
        try {
          dynamic c = clip;
          if (c.audioUrl != null && c.audioUrl.isNotEmpty) {
            sourceUrl = c.audioUrl;
          } else if (c.fileUrl != null && c.fileUrl.isNotEmpty) {
            sourceUrl = c.fileUrl;
          }

          if (c.videoUrl != null && c.videoUrl.isNotEmpty) {
            videoSourceUrl = c.videoUrl;
          }
        } catch (e) {
          print("Error accessing clip properties: $e");
        }
      }
    }

    _currentVideoUrl = videoSourceUrl;

    if (sourceUrl.isEmpty || !sourceUrl.startsWith('http')) {
      // If no URL or it's not a network URL, prepare for asset fallback
      // (Unless it's already an explicit local asset path we recognize)
      if (!sourceUrl.startsWith('images/') &&
          !sourceUrl.startsWith('assets/')) {
        sourceUrl = 'images/Default_music.mpeg';
      }
    }
    _currentAudioUrl = sourceUrl;
  }

  bool _isTransitionPlayed = false;

  void _initVideo() {
    _videoController =
        VideoPlayerController.asset(
            'assets/images/Transition.mp4',
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController.setLooping(false);
            _videoController.setVolume(0);
            _videoController.play();

            _videoController.addListener(() {
              if (_videoController.value.position >=
                      _videoController.value.duration &&
                  !_isTransitionPlayed) {
                _isTransitionPlayed = true;
                _switchToMainVideo();
              }
            });
          });
  }

  void _switchToMainVideo() {
    // Prevent multiple calls
    _videoController.dispose();
    setState(() {
      _isVideoInitialized = false;
    });

    // ALWAYS use default video as per user request
    _videoController =
        VideoPlayerController.asset(
            'assets/images/Meditation_video.mp4',
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize().then((_) {
            _videoController.setLooping(true);
            _videoController.setVolume(0);
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController.play();

            // Start the actual meditation flow (animations, audio) only after transition
            _startFlow();
          });
  }

  // ... _triggerSaveSession ...

  // ... _showCompletionDialog ...

  void _startFlow() async {
    final isPrayer = _config?.prayerType != null;

    if (isPrayer) {
      // Direct play for Prayer
      setState(() {
        showPlayImage = true;
        _isStarted = true;
        _isPlaying = true;
      });
      _entryController.forward();

      // Auto-start controllers
      _timerController.forward();
      _breathingController.repeat(reverse: true);
      _rippleController.repeat();

      await _initAudio();
      try {
        await _audioPlayer.resume();
      } catch (e) {
        print("Error resuming audio on auto-start: $e");
      }
    } else {
      _entryController.forward();
      setState(() => showPlayImage = true);
      // No longer need to call _initAudio here as it was started in initState
    }
  }

  Future<void> _initAudio() async {
    try {
      String sourceUrl = _currentAudioUrl ?? 'images/Default_music.mpeg';
      bool isNetwork = sourceUrl.toLowerCase().startsWith('http');
      bool isAsset =
          sourceUrl.toLowerCase().startsWith('assets/') ||
          sourceUrl.toLowerCase().startsWith('images/');

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      debugPrint(
        "🎵 Audio Init: URL=$sourceUrl, Network=$isNetwork, Asset=$isAsset",
      );

      if (isNetwork) {
        await _audioPlayer.setSourceUrl(sourceUrl);
      } else if (isAsset) {
        // If it starts with assets/, remove it because AssetSource assumes it
        String assetPath = sourceUrl;
        if (assetPath.startsWith('assets/')) {
          assetPath = assetPath.replaceFirst('assets/', '');
        }
        await _audioPlayer.setSource(AssetSource(assetPath));
      } else {
        // Final Fallback if URL is invalid or unknown
        debugPrint("🔊 Unknown audio source, falling back to default asset.");
        await _audioPlayer.setSource(AssetSource('images/Default_music.mpeg'));
      }

      _isAudioInitialized = true;
      debugPrint("✅ Audio Initialized Successfully");

      // Fix: Ensure video continues playing if it was impacted by audio init
      if (_isVideoInitialized && !_videoController.value.isPlaying) {
        _videoController.play();
      }
    } catch (e) {
      debugPrint("❌ Error initializing audio: $e");
    }
  }

  void _triggerSaveSession({
    String status = "completed",
    int karmaPoints = -1, // -1 sentinel to use config default
    int? actualDurationSeconds,
    int completionPercentage = 100,
  }) {
    int durationMins = _totalDuration ~/ 60;
    int actDuration = actualDurationSeconds != null
        ? (actualDurationSeconds ~/ 60)
        : durationMins;
    // ensure at least 0
    if (actDuration < 0) actDuration = 0;

    int finalKarma = karmaPoints != -1
        ? karmaPoints
        : (_config?.karmaPoints ?? 0);

    // Construct Request
    SpiritualSessionRequest request = SpiritualSessionRequest(
      type: _config?.type ?? "chanting",
      title: _config?.title ?? "Meditation Session",
      targetDuration: durationMins,
      actualDuration: actDuration,
      chantingName: _config?.title ?? "Meditation",
      chantCount: 108,
      karmaPoints: finalKarma,
      emotion: _config?.emotion ?? "neutral",
      status: status,
      completionPercentage: completionPercentage,
      videoUrl: _currentVideoUrl ?? "",
      audioUrl: _currentAudioUrl ?? "",
      configurationId: _config?.sId,
    );

    // Dispatch Event
    // We need context to access BLoC.
    // Since this is called from initState->Listener, context IS available (StatefulWidget).
    if (mounted) {
      context.read<MeditationSessionBloc>().add(SaveSession(request));
    }
  }

  void _showCompletionDialog(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    int earnedKarma = 0;
    if (response['data'] != null && response['data'] is Map) {
      earnedKarma =
          response['data']['karmaPoints'] ??
          response['data']['karma_points'] ??
          0;
    } else if (response['karmaPoints'] != null) {
      earnedKarma = response['karmaPoints'];
    }

    // Fallback: If 0 found in response, show the configured/requested points
    if (earnedKarma == 0) {
      earnedKarma = _config?.karmaPoints ?? 60;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Session Completed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You have successfully completed a meditation session.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+$earnedKarma Karma Points",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Get.until(
                      (route) =>
                          route.settings.name == AppConstants.routeDashboard,
                    );
                  },
                  child: const Text(
                    "Got it",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _breathingController.dispose();
    _haloController.dispose();
    _rippleController.dispose();
    _timerController.dispose();
    _audioPlayer.dispose();
    if (_isVideoInitialized) {
      _videoController.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleMeditation() async {
    if (!_isStarted) {
      setState(() {
        _isStarted = true;
        _isPlaying = true;
      });
      _timerController.forward();
      _breathingController.repeat(reverse: true);
      _rippleController.repeat();

      // NEW: If not initialized yet, wait for it
      if (!_isAudioInitialized) {
        debugPrint("⏳ Audio not ready, waiting for initialization...");
        await _initAudio();
      }

      if (_isAudioInitialized) {
        try {
          await _audioPlayer.resume();
        } catch (e) {
          debugPrint("Error resuming audio: $e");
        }
      }
      // Ensure video plays
      if (_isVideoInitialized && !_videoController.value.isPlaying) {
        _videoController.play();
      }
    } else if (_isPlaying) {
      setState(() {
        _isPlaying = false;
      });
      _timerController.stop();
      _breathingController.stop();
      _rippleController.stop();
      if (_isAudioInitialized) {
        try {
          await _audioPlayer.pause();
        } catch (e) {
          print("Error pausing audio: $e");
        }
      }
      // Pause video if user pauses meditation
      if (_isVideoInitialized) _videoController.pause();
    } else {
      setState(() {
        _isPlaying = true;
      });
      _timerController.forward();
      _breathingController.repeat(reverse: true);
      _rippleController.repeat();
      if (_isAudioInitialized) {
        try {
          // Explicit resume - player should maintain position
          await _audioPlayer.resume();
        } catch (e) {
          print("Error resuming audio (2): $e");
        }
      }
      if (_isVideoInitialized) _videoController.play();
    }
  }

  void _handleBackNavigation() {
    bool wasPlaying = _isPlaying;
    if (wasPlaying) {
      _toggleMeditation(); // Pause if currently playing
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Exit Session?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to exit?\nYou will receive 0 Karma points.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (wasPlaying) {
                _toggleMeditation(); // Resume only if it was playing
              }
            },
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation dialog

              // Calculate partial stats
              double elapsedSeconds =
                  _timerController.value *
                  _timerController.duration!.inSeconds.toDouble();
              int actualSec = elapsedSeconds.toInt();
              int percent = ((elapsedSeconds / _totalDuration) * 100)
                  .toInt()
                  .clamp(0, 100);

              _isManualExit = true;

              // Save as incomplete with 0 karma
              _triggerSaveSession(
                status: "incomplete",
                karmaPoints: 0,
                actualDurationSeconds: actualSec,
                completionPercentage: percent,
              );

              // Show Incomplete Dialog instead of direct exit
              _showIncompleteDialog(context, percent);
            },
            child: const Text(
              "Exit",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncompleteDialog(BuildContext context, int percentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xffFFF8E7), // Creamy background like screenshot
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 3),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Incomplete",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4A3B32), // Dark brown
                ),
              ),
              const SizedBox(height: 16),

              // Warning + Percent
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Session partially completed\n($percentage%)",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff6D5D53),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "+0 Karma Points",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFF9B44), // Orange
                ),
              ),
              const SizedBox(height: 30),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5D4037), // Dark Brown
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Pill shape
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Get.until(
                      (route) =>
                          route.settings.name == AppConstants.routeDashboard,
                    );
                  },
                  child: const Text(
                    "DONE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isManualExit = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<MeditationSessionBloc, MeditationSessionState>(
      listener: (context, state) {
        if (state is SessionSaved) {
          // Only show completion dialog if NOT manually exited (i.e. timer finished)
          if (!_isManualExit) {
            _showCompletionDialog(context, state.response);
          }
        }
        if (state is SessionError) {
          Utils.showToast(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            /// 🌌 Parallax Breathing Background or Video
            Positioned.fill(
              child: _isVideoInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _bgScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _bgScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/medi_bg.png', // Fallback
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            /// 🌌 Celestial Aurora Glow (Animated Mesh Glow)
            const Positioned.fill(child: _AuroraGlow()),

            /// ✨ Magic Particles
            for (int i = 0; i < 25; i++) _MagicParticle(index: i),

            /// ✖️ Top Controls
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Song Selection (Hidden as per request)
                  /*
                  GestureDetector(
                    onTap: () => setState(
                      () => _showSongSelection = !_showSongSelection,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.music_note,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tracks[_selectedTrack],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  */
                  const SizedBox(), // Spacer placeholder if needed or just empty
                  if (_isTransitionPlayed)
                    _CloseButton(onPressed: _handleBackNavigation),
                ],
              ),
            ),

            /// 🌠 DIVINE CENTER (Halo + Image + Breathing)
            Align(
              alignment: const Alignment(0, -0.25),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// 1. The Divine Halo (Rotating)
                  RotationTransition(
                    turns: _haloController,
                    child: Container(
                      width: size.width * 0.9,
                      height: size.width * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.amber.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  /// 2. Zen Ripples (Only when playing)
                  if (_isPlaying)
                    for (int i = 0; i < 3; i++)
                      _ZenRipple(controller: _rippleController, index: i),

                  /// 3. The Main Avatar (Breathing & Switching)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1600),
                          switchInCurve: const _SafeCurve(Curves.elasticInOut),
                          switchOutCurve: const _SafeCurve(Curves.easeIn),
                          transitionBuilder: (child, animation) {
                            if ((child.key as ValueKey).value == true) {
                              animation.addStatusListener((status) {
                                if (status == AnimationStatus.completed &&
                                    !showPlayUI) {
                                  setState(() => showPlayUI = true);
                                }
                              });
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: const _SafeCurve(
                                          Curves.elasticOut,
                                        ),
                                      ),
                                    ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            }
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          // Replaced Image.asset with SizedBox as per request to hide images but keep logic
                          child: SizedBox.shrink(key: ValueKey(showPlayImage)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔘 ELEGANT CONTROLS
            _BottomControls(
              isVisible: showPlayUI,
              isStarted: _isStarted,
              isPlaying: _isPlaying,
              onToggle: _toggleMeditation,
              timerController: _timerController,
              totalDuration: _totalDuration,
              isPrayer: _config?.prayerType != null,
            ),

            /// 🎵 SONG SELECTION GRID
            /*
            if (_showSongSelection)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showSongSelection = false),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          color: Colors.black.withOpacity(0.6 * value),
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: 0.9 + (0.1 * value),
                            child: GestureDetector(
                              onTap: () {}, // Prevent tap through
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900]?.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white12,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(width: 24),
                                        const Text(
                                          "SELECT MUSIC",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => setState(
                                            () => _showSongSelection = false,
                                          ),
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white54,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 1.8,
                                          ),
                                      itemCount: _tracks.length,
                                      itemBuilder: (context, index) {
                                        bool isSelected =
                                            _selectedTrack == index;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedTrack = index;
                                              _showSongSelection = false;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white10
                                                  : Colors.white.withOpacity(
                                                      0.04,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.amber.withOpacity(
                                                        0.5,
                                                      )
                                                    : Colors.white12,
                                                width: isSelected ? 2 : 1.2,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.amber
                                                            .withOpacity(0.15),
                                                        blurRadius: 15,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              _tracks[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.amber[200]
                                                    : Colors.white.withOpacity(
                                                        0.8,
                                                      ),
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            */
          ],
        ),
      ),
    );
  }
}

/// --- SUPPORTING WIDGETS ---

class _ZenRipple extends StatelessWidget {
  final AnimationController controller;
  final int index;
  const _ZenRipple({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = (controller.value + (index * 0.33)) % 1.0;
        double opacity = (1.0 - progress).clamp(0.0, 1.0);
        double sizeFactor = 1.0 + (progress * 1.8);

        return Container(
          width: 220 * sizeFactor,
          height: 220 * sizeFactor,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(opacity * 0.3),
              width: 1.2,
            ),
          ),
        );
      },
    );
  }
}

class _AuroraGlow extends StatefulWidget {
  const _AuroraGlow();
  @override
  State<_AuroraGlow> createState() => _AuroraGlowState();
}

class _AuroraGlowState extends State<_AuroraGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.3 * math.sin(_controller.value * 2 * math.pi),
                -0.3 * math.cos(_controller.value * 2 * math.pi),
              ),
              colors: [
                const Color(0xFF6A1B9A).withOpacity(0.1),
                const Color(0xFF1A237E).withOpacity(0.0),
              ],
              radius: 1.5,
            ),
          ),
        );
      },
    );
  }
}

class _MagicParticle extends StatefulWidget {
  final int index;
  const _MagicParticle({required this.index});
  @override
  State<_MagicParticle> createState() => _MagicParticleState();
}

class _MagicParticleState extends State<_MagicParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double x, y, size;
  late Color color;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    x = r.nextDouble();
    y = r.nextDouble();
    size = r.nextDouble() * 4 + 1;
    color = r.nextBool() ? Colors.white : Colors.amber.withOpacity(0.5);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8 + r.nextInt(10)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              MediaQuery.of(context).size.height *
                  (0.1 * math.sin(_controller.value * math.pi)),
            ),
            child: Opacity(
              opacity: 0.1 + (0.4 * _controller.value),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CloseButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black38,
          border: Border.all(color: Colors.white12),
        ),
        child: const Icon(Icons.close, color: Colors.white70, size: 24),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool isVisible;
  final bool isStarted;
  final bool isPlaying;
  final VoidCallback onToggle;
  final AnimationController timerController;
  final int totalDuration;
  final bool isPrayer;

  const _BottomControls({
    required this.isVisible,
    required this.isStarted,
    required this.isPlaying,
    required this.onToggle,
    required this.timerController,
    required this.totalDuration,
    this.isPrayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1200),
      curve: const _SafeCurve(Curves.easeOutExpo),
      bottom: isVisible ? 80 : -300,
      left: 30,
      right: 30,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: isVisible ? 1.0 : 0.0,
        child: Column(
          children: [
            Text(
              !isStarted
                  ? "READY TO MEDITATE"
                  : isPlaying
                  ? (isPrayer ? "PRAYER IN PROGRESS" : "INHALE ... EXHALE")
                  : "PAUSED",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 35),
            GestureDetector(
              onTap: onToggle,
              child: _PlayButton(isPlaying: isPlaying, isStarted: isStarted),
            ),
            const SizedBox(height: 45),
            _ZenTimer(
              timerController: timerController,
              totalDuration: totalDuration,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isStarted;
  const _PlayButton({required this.isPlaying, required this.isStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        !isStarted || !isPlaying
            ? Icons.play_arrow_rounded
            : Icons.pause_rounded,
        color: Colors.white,
        size: 45,
      ),
    );
  }
}

class _ZenTimer extends StatelessWidget {
  final AnimationController timerController;
  final int totalDuration;
  const _ZenTimer({required this.timerController, required this.totalDuration});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timerController,
      builder: (context, child) {
        int rem =
            totalDuration - (timerController.value * totalDuration).round();
        String time =
            "${(rem ~/ 60).toString().padLeft(2, '0')}:${(rem % 60).toString().padLeft(2, '0')}";
        return Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w200,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timerController.value,
                minHeight: 2,
                backgroundColor: Colors.white10,
                color: Colors.white60,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SafeCurve extends Curve {
  final Curve curve;
  const _SafeCurve(this.curve);
  @override
  double transform(double t) => curve.transform(t.clamp(0.0, 1.0));
}
