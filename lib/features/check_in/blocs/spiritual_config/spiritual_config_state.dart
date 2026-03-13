part of 'spiritual_config_bloc.dart';

abstract class SpiritualConfigState extends Equatable {
  const SpiritualConfigState();

  @override
  List<Object?> get props => [];
}

class ConfigInitial extends SpiritualConfigState {}

class ConfigLoading extends SpiritualConfigState {}

class ConfigLoaded extends SpiritualConfigState {
  final List<String> availableEmotions;
  final List<SpiritualConfiguration> configurations;
  final SpiritualConfiguration? selectedConfig;
  final String selectedEmotion;
  final int selectedDuration;

  const ConfigLoaded({
    required this.configurations,
    this.availableEmotions = const [],
    this.selectedConfig,
    this.selectedEmotion = 'Happy',
    this.selectedDuration = 1,
  });

  ConfigLoaded copyWith({
    List<String>? availableEmotions,
    List<SpiritualConfiguration>? configurations,
    SpiritualConfiguration? selectedConfig,
    String? selectedEmotion,
    int? selectedDuration,
  }) {
    return ConfigLoaded(
      availableEmotions: availableEmotions ?? this.availableEmotions,
      configurations: configurations ?? this.configurations,
      selectedConfig:
          selectedConfig, // Can be null so we don't default to this.selectedConfig if passed explicitly?
      // Actually standard copyWith uses ?? check. If we want to set nullable to null, we need a wrapper.
      // For simplicity, we assume we re-calculate selectedConfig whenever params change.
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      selectedDuration: selectedDuration ?? this.selectedDuration,
    );
  }

  @override
  List<Object?> get props => [
    configurations,
    selectedConfig,
    selectedEmotion,
    selectedDuration,
  ];
}

class ConfigError extends SpiritualConfigState {
  final String message;
  const ConfigError(this.message);
  @override
  List<Object> get props => [message];
}

class SessionStarting extends SpiritualConfigState {}

class SessionReady extends ConfigLoaded {
  final Map<String, dynamic> navigationArgs;

  const SessionReady({
    required this.navigationArgs,
    required super.configurations,
    super.availableEmotions,
    super.selectedConfig,
    super.selectedEmotion,
    super.selectedDuration,
  });

  @override
  List<Object?> get props => [
    navigationArgs,
    configurations,
    selectedConfig,
    selectedEmotion,
    selectedDuration,
  ];
}
