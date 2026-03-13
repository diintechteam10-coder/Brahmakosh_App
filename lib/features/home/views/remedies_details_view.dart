import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/models/remedies_model.dart';
import 'package:brahmakosh/common/api_urls.dart';

class GemstoneDetailView extends StatefulWidget {
  final Gemstones gemstones;
  const GemstoneDetailView({super.key, required this.gemstones});

  @override
  State<GemstoneDetailView> createState() => _GemstoneDetailViewState();
}

class _GemstoneDetailViewState extends State<GemstoneDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6), // Old Lace / Beige bg
      appBar: AppBar(
        title: Text(
          "Gemstone Details",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4E342E),
          ),
        ),
        backgroundColor: const Color(0xFFFDF5E6),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff4E342E),
          unselectedLabelColor: const Color(0xff8D6E63),
          indicatorColor: const Color(0xffff7438),
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: "Life"),
            Tab(text: "Benefic"),
            Tab(text: "Lucky"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGemstonePage(widget.gemstones.life),
          _buildGemstonePage(widget.gemstones.benefic),
          _buildGemstonePage(widget.gemstones.lucky),
        ],
      ),
    );
  }

  Widget _buildGemstonePage(GemstoneDetail? detail) {
    if (detail == null) {
      return const Center(child: Text("No details available"));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A373).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFFDECB6).withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.name ?? "Gemstone",
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xff4E342E),
              ),
            ),
            const SizedBox(height: 8),
            if (detail.semiGem != null && detail.semiGem!.isNotEmpty)
              Text(
                "Sub-Gem: ${detail.semiGem}",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const Divider(height: 32),
            _buildDetailRow("Wear Finger", detail.wearFinger),
            _buildDetailRow("Weight (Carat)", detail.weightCaret),
            _buildDetailRow("Metal", detail.wearMetal),
            _buildDetailRow("Wear Day", detail.wearDay),
            _buildDetailRow("Deity", detail.gemDeity),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff8D6E63),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xff4E342E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RudrakshaDetailView extends StatelessWidget {
  final Rudraksha rudraksha;
  const RudrakshaDetailView({super.key, required this.rudraksha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: Text(
          "Rudraksha Details",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4E342E),
          ),
        ),
        backgroundColor: const Color(0xFFFDF5E6),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Placeholder (or real image if url is valid/handled)
            // Assuming local mapping or network image based on user setup.
            // Using a placeholder icon for now as base_url handling for images might vary.
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(20),
                image: rudraksha.imgUrl != null
                    ? DecorationImage(
                        image: NetworkImage(
                          "${ApiUrls.baseUrl}${rudraksha.imgUrl}",
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: rudraksha.imgUrl == null
                  ? const Icon(Icons.spa, size: 80, color: Color(0xFF8D6E63))
                  : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A373).withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFDECB6).withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rudraksha.name ?? "Rudraksha",
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff4E342E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Recommendation",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff8D6E63),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rudraksha.recommend ?? "Recommended for you.",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xff5D4037),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    "Details & Benefits",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff8D6E63),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rudraksha.detail ?? "No additional details.",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xff5D4037),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PujaDetailView extends StatefulWidget {
  final Puja puja;
  const PujaDetailView({super.key, required this.puja});

  @override
  State<PujaDetailView> createState() => _PujaDetailViewState();
}

class _PujaDetailViewState extends State<PujaDetailView> {
  final Set<int> _expandedCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: Text(
          "Puja Suggestions",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4E342E),
          ),
        ),
        backgroundColor: const Color(0xFFFDF5E6),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Summary Card ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A373).withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFDECB6).withOpacity(0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xffff7438).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xffff7438),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Overview",
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffff7438),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.puja.summary ??
                        "Puja recommendations based on your horoscope and planetary combinations.",
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xff5D4037),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Suggested Pujas Section ───
            if (widget.puja.suggestions != null &&
                widget.puja.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 24),

              // Section header
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.temple_hindu,
                      color: Color(0xffff7438),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Recommended Pujas",
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4E342E),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffff7438).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${widget.puja.suggestions!.length}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xffff7438),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Suggestion cards
              ...widget.puja.suggestions!.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return _buildSuggestionCard(suggestion, index);
              }),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(PujaSuggestion suggestion, int index) {
    final isExpanded = _expandedCards.contains(index);
    final hasSummary =
        suggestion.summary != null && suggestion.summary!.isNotEmpty;
    final hasLink = suggestion.link != null && suggestion.link!.isNotEmpty;
    final hasStatus =
        suggestion.status != null && suggestion.status!.isNotEmpty;
    final hasPujaId =
        suggestion.pujaId != null && suggestion.pujaId!.isNotEmpty;

    // Priority styling
    Color accentColor;
    String priorityLabel;
    IconData priorityIcon;

    final priority = suggestion.priority ?? 0;
    if (priority <= 1) {
      accentColor = const Color(0xFFE53935);
      priorityLabel = "High";
      priorityIcon = Icons.keyboard_double_arrow_up;
    } else if (priority <= 3) {
      accentColor = const Color(0xFFFB8C00);
      priorityLabel = "Medium";
      priorityIcon = Icons.keyboard_arrow_up;
    } else {
      accentColor = const Color(0xFF43A047);
      priorityLabel = "Low";
      priorityIcon = Icons.remove;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A373).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFFDECB6).withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Colored top accent bar ───
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.4)],
              ),
            ),
          ),

          // ─── Title Row ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index number
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    suggestion.title ?? "Puja Suggestion",
                    style: GoogleFonts.lora(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff4E342E),
                      height: 1.3,
                    ),
                  ),
                ),
                 _buildChip(
                  icon: priorityIcon,
                  label: priorityLabel,
                  color: accentColor,
                ),
              ],
            ),
          ),

          // ─── Detail Chips Row ───
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(56, 10, 16, 0),
          //   child: Wrap(
          //     spacing: 8,
          //     runSpacing: 6,
          //     children: [
          //       // Priority chip
               
          //       // Status chip
          //       // if (hasStatus)
          //       //   _buildChip(
          //       //     icon: Icons.info_outline,
          //       //     label: suggestion.status!,
          //       //     color: const Color(0xff5D4037),
          //       //   ),
          //       // Puja ID chip
          //       // if (hasPujaId)
          //       //   _buildChip(
          //       //     icon: Icons.tag,
          //       //     label: suggestion.pujaId!,
          //       //     color: const Color(0xff8D6E63),
          //       //   ),
          //     ],
          //   ),
          // ),

          // ─── Divider ───
          if (hasSummary)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 16, 0),
              child: Divider(
                height: 1,
                color: const Color(0xFFE0D5C8).withOpacity(0.7),
              ),
            ),

          // ─── Summary Text (expandable) ───
          if (hasSummary)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.summary!,
                    maxLines: isExpanded ? null : 3,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xff6D4C41),
                      height: 1.55,
                    ),
                  ),
                  if (suggestion.summary!.length > 120)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedCards.remove(index);
                          } else {
                            _expandedCards.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          isExpanded ? "Show Less" : "Read More",
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xffff7438),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ─── Link Button ───
          if (hasLink)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 16, 0),
              child: InkWell(
                onTap: () {
                  Get.snackbar(
                    "Puja Link",
                    suggestion.link!,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xff4E342E),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffff7438), Color(0xFFFF8F5E)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Learn More",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
