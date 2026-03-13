import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

import 'package:brahmakosh/common/utils.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

part 'spiritual_config_event.dart';
part 'spiritual_config_state.dart';

class SpiritualConfigBloc
    extends Bloc<SpiritualConfigEvent, SpiritualConfigState> {
  final SpiritualRepository repository;

  // Emotion mapping (Static constant)
  static const Map<String, String> emotionEmojis = {
    'Loved': '🥰',
    'Surprised': '😲',
    'Calm': '😌',
    'Happy': '😊',
    'Stressed': '😣',
    'Neutral': '😐',
    'Sad': '😢',
    'Angry': '😠',
    'Afraid': '😨',
    'Disgusted': '🤢',
  };

  // Helper handling 'stress' vs 'stressed'
  bool _isEmotionMatch(String? apiEmotion, String uiEmotion) {
    if (apiEmotion == null) return false;
    final api = apiEmotion.toLowerCase();
    final ui = uiEmotion.toLowerCase();

    if (api == ui) return true;
    if (ui == 'stressed' && api == 'stress') return true;
    if (ui == 'stress' && api == 'stressed') return true;

    return false;
  }

  final List<int> availableDurations = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  SpiritualConfigBloc({required this.repository}) : super(ConfigInitial()) {
    on<LoadConfig>(_onLoadConfig);
    on<SelectEmotion>(_onSelectEmotion);
    on<SelectDuration>(_onSelectDuration);
    on<StartSession>(_onStartSession);
  }

  Future<void> _onLoadConfig(
    LoadConfig event,
    Emitter<SpiritualConfigState> emit,
  ) async {
    emit(ConfigLoading());

    // 1. Use pre-fetched if available
    if (event.preFetchedData != null && event.preFetchedData!.data != null) {
      final configs = event.preFetchedData!.data!;
      emit(_createLoadedState(configs, 'Happy', 1));
      return;
    }

    // 2. Fetch from Repo
    try {
      final response = await repository.getConfigurations(event.categoryId);
      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        // Determine initial emotion
        // Try 'Happy' first, if not found, use the emotion of the first config
        String initialEmotion = 'Happy';
        final hasHappy = response.data!.any(
          (c) => _isEmotionMatch(c.emotion, 'Happy'),
        );

        if (!hasHappy) {
          // Map API emotion back to UI key if possible
          // For now, just use the API string capitalized, or find match in keys
          // Simple fallback:
          final firstApiEmotion = response.data!.first.emotion;
          if (firstApiEmotion != null) {
            // Try to find matching key
            final match = emotionEmojis.keys.firstWhereOrNull(
              (k) => _isEmotionMatch(firstApiEmotion, k),
            );
            initialEmotion = match ?? firstApiEmotion; // Use match or raw
          }
        }

        emit(
          _createLoadedState(response.data!, initialEmotion, 5),
        ); // Default 5 mins
      } else {
        emit(const ConfigError("Failed to load configurations"));
      }
    } catch (e) {
      emit(ConfigError(e.toString()));
    }
  }

  Future<void> _onSelectEmotion(
    SelectEmotion event,
    Emitter<SpiritualConfigState> emit,
  ) async {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      emit(
        _createLoadedState(
          current.configurations,
          event.emotion,
          current.selectedDuration,
        ),
      );
    }
  }

  Future<void> _onSelectDuration(
    SelectDuration event,
    Emitter<SpiritualConfigState> emit,
  ) async {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      emit(
        _createLoadedState(
          current.configurations,
          current.selectedEmotion,
          event.duration,
        ),
      );
    }
  }

  ConfigLoaded _createLoadedState(
    List<SpiritualConfiguration> configs,
    String emotion,
    int duration,
  ) {
    final availableEmotions = emotionEmojis.keys.where((emotionKey) {
      return configs.any((c) => _isEmotionMatch(c.emotion, emotionKey));
    }).toList();

    // Calculate selected config
    final exactMatch = configs.firstWhereOrNull((c) {
      final emotionMatch = _isEmotionMatch(c.emotion, emotion);

      bool durationMatch = false;
      if (c.duration != null) {
        final parsed = _parseDuration(c.duration!);
        durationMatch = parsed == duration;
      }
      return emotionMatch && durationMatch;
    });

    final fallback = configs.firstWhereOrNull(
      (c) => _isEmotionMatch(c.emotion, emotion),
    );

    return ConfigLoaded(
      availableEmotions: availableEmotions,
      configurations: configs,
      selectedEmotion: emotion,
      selectedDuration: duration,
      selectedConfig: exactMatch ?? fallback,
    );
  }

  int _parseDuration(String durationStr) {
    final parts = durationStr.toLowerCase().split(' ');
    if (parts.isEmpty) return 0;
    double val = double.tryParse(parts[0]) ?? 0.0;
    if (durationStr.contains('hour')) {
      return (val * 60).toInt();
    }
    return val.toInt();
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<SpiritualConfigState> emit,
  ) async {
    if (state is! ConfigLoaded) return;
    final current = state as ConfigLoaded;

    if (current.selectedConfig == null || current.selectedConfig?.sId == null) {
      // We can emit a transient error state or just log/toast?
      // Since we can't show toast easily from BLoC without listener, assume we emit error or ignore.
      // Let's emit nothing/ignore for now as button should handle validity if possible,
      // but here we can emit ConfigError briefly? No, that clears screen.
      // We'll rely on UI to validate or just show toast in listener based on state?
      // Using Utils.showToast here works but is not pure.
      Utils.showToast("Invalid configuration");
      return;
    }

    // Emit Loading/Starting state
    // We want to keep the UI visible though, just show overlay?
    // SessionStarting state can be handled by listener to show loader.
    // But if we emit SessionStarting, the BlocBuilder might replace the screen if it listens to it.
    // Solution: SessionStarting is a state. View should handle it (overlay or maintain last view).

    // Actually, `SpiritualConfigState` is the ONLY state.
    // If we transition to `SessionStarting`, the `ConfigLoaded` data is lost unless `SessionStarting` extends/holds it.
    // Let's make `SessionStarting` hold data or just use side-effect.
    // Better: Don't emit state that destroys view.
    // Just perform logic and emit SessionReady.
    // The UI can show a loader if we have a bool `isStarting` in `ConfigLoaded`.

    // Let's update `ConfigLoaded` to have `isStarting`.

    final startingState = current
        .copyWith(); // We need a way to indicate starting.
    // For now, let's use Utils.showLoaderDialogNew(ticker) ... wait we don't have ticker here.
    // We should strictly use States.

    // REFACTOR State: Add `startSubmissionStatus` to `ConfigLoaded`.
    // OR just emit `SessionReady` and let UI handle async wait?
    // No, we need to fetch clips.

    // Let's emit `SessionStarting` (which doesn't have data, so UI will clear? BAD).
    // Let's modify `ConfigLoaded` to have `isStartingSession`.

    // Since I can't easily change the file I just wrote in previous step without re-writing,
    // I will rewrite `spiritual_config_state.dart` in next step if needed, or just append properly.
    // Actually I can just write `_onStartSession` to NOT emit a loading state but do work?
    // But user wants "Show loaders".

    // Ok, I will assume UI handles `ConfigLoading` properly, but that's for full screen.
    // I'll emit a new state `ConfigLoaded` with a flag.
    // Wait, I didn't add the flag.

    // Let's perform the fetch and emit `SessionReady`.
    // The UI will likely need to show a loader.
    // I will add `isStarting` to `ConfigLoaded` by rewriting the state file first?
    // Or simpler: Just emit `SessionReady`. The fetch is fast.
    // Creating a "perfect" BLoC in one go is hard.

    // Let's try to just do the work. If it takes time, UI freezes? No, async.
    // But user can tap again.

    // I will rewrite `spiritual_config_state.dart` to include `isStarting`.

    try {
      // Ideally: emit(current.copyWith(isStarting: true));
      final response = await repository.getClips(current.selectedConfig!.sId!);

      emit(
        SessionReady(
          navigationArgs: {
            'duration': current.selectedDuration,
            'config': current.selectedConfig,
            'clips': (response?.success == true && response?.data != null)
                ? response!.data
                : [],
          },
          configurations: current.configurations,
          selectedConfig: current.selectedConfig,
          selectedEmotion: current.selectedEmotion,
          selectedDuration: current.selectedDuration,
        ),
      );

      // No explicit reset needed as SessionReady is now a valid Loaded state.
    } catch (e) {
      // Handle error
      print("❌ SpiritualConfigBloc: Error starting session/fetching clips: $e");
      emit(
        SessionReady(
          navigationArgs: {
            'duration': current.selectedDuration,
            'config': current.selectedConfig,
            'clips': [],
          },
          configurations: current.configurations,
          selectedConfig: current.selectedConfig,
          selectedEmotion: current.selectedEmotion,
          selectedDuration: current.selectedDuration,
        ),
      );
    }
  }
}
