import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/check_in/blocs/spiritual_config/spiritual_config_bloc.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

class SpiritualConfigurationView extends StatefulWidget {
  const SpiritualConfigurationView({super.key});

  @override
  State<SpiritualConfigurationView> createState() =>
      _SpiritualConfigurationViewState();
}

class _SpiritualConfigurationViewState
    extends State<SpiritualConfigurationView> {
  late final String? categoryId;
  late final dynamic preFetchedData;
  late final String? title;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    categoryId = args is Map
        ? args['categoryId']
        : (args is String ? args : null);
    preFetchedData = args is Map ? args['preFetchedData'] : null;
    title = args is Map ? args['title'] : 'Spirituality';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SpiritualConfigBloc(repository: SpiritualRepository())..add(
            LoadConfig(
              categoryId: categoryId ?? '',
              preFetchedData: preFetchedData,
            ),
          ),
      child: BlocConsumer<SpiritualConfigBloc, SpiritualConfigState>(
        listener: (context, state) {
          if (state is SessionReady) {
            // Navigate to MeditationStart
            Get.toNamed(
              AppConstants.routeMeditationStart,
              arguments: state.navigationArgs,
            );
          }
          if (state is ConfigError) {
            Utils.showToast(state.message);
          }
        },
        builder: (context, state) {
          // Explicit check for SessionReady to ensure it's treated as Loaded
          if (state is ConfigLoading) {
            return const Scaffold(
              backgroundColor: Color(0xffFFF8E7),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is! ConfigLoaded) {
            String errorMessage = "Unable to load configurations.";
            if (state is ConfigError) {
              errorMessage = state.message;
            }

            // Show Error/Empty State
            return Scaffold(
              backgroundColor: const Color(0xffFFF8E7),
              appBar: AppBar(
                backgroundColor: const Color(0xffFFF8E7),
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xff5D4037),
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(errorMessage, style: GoogleFonts.inter()),
                  ],
                ),
              ),
            );
          }

          // Current Loaded State
          final loaded = state;

          return Scaffold(
            backgroundColor: const Color(0xffFFF8E7), // Light beige background
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          Text(
                            title ?? 'Spirituality',
                            style: GoogleFonts.lora(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff4E342E),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'How are you feeling today?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xff8D6E63),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildEmotionSelector(context, loaded),
                          const SizedBox(height: 30),
                          _buildDurationSelector(context, loaded),
                          const SizedBox(height: 15),
                          _buildConfigurationSummary(loaded),
                          const SizedBox(height: 15),
                          _buildStartButton(context),
                          const SizedBox(height: 10),
                          Text(
                            'You can stop anytime',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xff5D4037),
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionSelector(BuildContext context, ConfigLoaded state) {
    return SizedBox(
      height: 110,
      child: _EmotionList(
        availableEmotions: state.availableEmotions,
        selectedEmotion: state.selectedEmotion,
        onSelect: (emotion) {
          context.read<SpiritualConfigBloc>().add(SelectEmotion(emotion));
        },
      ),
    );
  }

  Widget _buildDurationSelector(BuildContext context, ConfigLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xffFF9B44).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: Color(0xffFF9B44),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Select Duration',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff4E342E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Builder(
            builder: (context) {
              final bloc = context.read<SpiritualConfigBloc>();
              final durations = bloc.availableDurations;
              // Safe index calculation
              int index = durations.indexOf(state.selectedDuration);
              if (index == -1) index = 0;
              final currentIndex = index.toDouble();

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(Get.context!).copyWith(
                      activeTrackColor: const Color(0xffFF9B44),
                      inactiveTrackColor: Colors.orange.withOpacity(0.2),
                      thumbColor: Colors.white,
                      overlayColor: const Color(0xffFF9B44).withOpacity(0.1),
                      valueIndicatorColor: const Color(0xffFF9B44),
                      valueIndicatorTextStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: currentIndex < 0 ? 0 : currentIndex,
                      min: 0,
                      max: (durations.length - 1).toDouble(),
                      divisions: durations.length > 1
                          ? durations.length - 1
                          : 1,
                      label: _formatDuration(durations[index]),
                      onChanged: (value) {
                        final i = value.toInt();
                        if (i >= 0 && i < durations.length) {
                          bloc.add(SelectDuration(durations[i]));
                        }
                      },
                    ),
                  ),

                  // Labels below slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(durations.first),
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                        Text(
                          _formatDuration(durations.last),
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours Hr';
      return '$hours Hr $mins Min';
    }
    return '$minutes Min';
  }

  Widget _buildConfigurationSummary(ConfigLoaded state) {
    final emoji =
        SpiritualConfigBloc.emotionEmojis[state.selectedEmotion] ?? '😐';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Summary',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff4E342E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _summaryChip(emoji, 'Mood'),
              const SizedBox(width: 24),
              _summaryChip('🕒', _formatDuration(state.selectedDuration)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xffFFF5E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xffFF9B44), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Finish to earn ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xff4E342E),
                  ),
                ),
                Text(
                  '+${state.selectedConfig?.karmaPoints ?? 10} karma Points',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffFF9B44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String icon, String label) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xff1E1E1E),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xffFF8C00), Color(0xffFFA040)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFF8C00).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<SpiritualConfigBloc>().add(StartSession());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Start',
          style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmotionList extends StatefulWidget {
  final List<String> availableEmotions;
  final String? selectedEmotion;
  final Function(String) onSelect;

  const _EmotionList({
    required this.availableEmotions,
    required this.selectedEmotion,
    required this.onSelect,
  });

  @override
  State<_EmotionList> createState() => _EmotionListState();
}

class _EmotionListState extends State<_EmotionList> {
  final ScrollController _scrollController = ScrollController();
  // removed infinite count

  // Cache emotions list to avoid static access repetition issues
  final Map<String, String> _emotionsMap = SpiritualConfigBloc.emotionEmojis;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(_EmotionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEmotion != widget.selectedEmotion) {
      // Optional: Auto-scroll on external change
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    final selectedEmotion = widget.selectedEmotion;
    if (selectedEmotion == null) return;

    final index = widget.availableEmotions.indexOf(selectedEmotion);

    if (index != -1) {
      final width = MediaQuery.of(context).size.width;
      final itemWidth = width / 3;

      // Center the item
      final targetOffset = index * itemWidth;

      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final minScroll = _scrollController.position.minScrollExtent;

        double finalOffset = targetOffset;
        if (finalOffset < minScroll) finalOffset = minScroll;
        if (finalOffset > maxScroll) finalOffset = maxScroll;

        _scrollController.animateTo(
          finalOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final itemWidth = MediaQuery.of(context).size.width / 3;

        return ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: (availableWidth - itemWidth) / 2,
          ),
          itemCount: widget.availableEmotions.length, // Filtered count
          itemBuilder: (context, index) {
            final emotion = widget.availableEmotions[index];
            final emoji = _emotionsMap[emotion] ?? '😐';
            final isSelected = widget.selectedEmotion == emotion;

            return SizedBox(
              width: itemWidth,
              child: GestureDetector(
                onTap: () {
                  widget.onSelect(emotion);
                  final target = index * itemWidth;
                  if (_scrollController.hasClients) {
                    final maxScroll =
                        _scrollController.position.maxScrollExtent;
                    _scrollController.animateTo(
                      target.clamp(0.0, maxScroll),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.3 : 0.8,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: isSelected ? 30 : 22),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 1.0 : 0.6,
                        child: Text(
                          emotion,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: isSelected ? 16 : 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: const Color(0xff1E1E1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
