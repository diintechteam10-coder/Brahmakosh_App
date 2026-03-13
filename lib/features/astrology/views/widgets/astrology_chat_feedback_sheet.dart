import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/astrology_chat_controller.dart';

class AstrologyChatFeedbackSheet extends StatefulWidget {
  final AstrologyChatController controller;

  const AstrologyChatFeedbackSheet({Key? key, required this.controller})
    : super(key: key);

  @override
  State<AstrologyChatFeedbackSheet> createState() =>
      _AstrologyChatFeedbackSheetState();
}

class _AstrologyChatFeedbackSheetState
    extends State<AstrologyChatFeedbackSheet> {
  double _rating = 0;
  String? _satisfaction;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: const Color(0xFFFBE6D0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Rate your Experience",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How was your conversation?",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.star_rounded,
                      size: 40,
                      color: index < _rating
                          ? const Color(0xFFFFA000) // Gold/Orange
                          : Colors.grey[300], // Inactive
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Sentiment Chips (Mapped to selection for visual feedback)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSentimentChip(
                  "very_unhappy",
                  "Very Unhappy",
                  Icons.sentiment_very_dissatisfied,
                ),
                _buildSentimentChip(
                  "unhappy",
                  "Unhappy",
                  Icons.sentiment_dissatisfied,
                ),
                _buildSentimentChip(
                  "neutral",
                  "Neutral",
                  Icons.sentiment_neutral,
                ),
                _buildSentimentChip(
                  "happy",
                  "Happy",
                  Icons.sentiment_satisfied,
                ),
                _buildSentimentChip(
                  "very_happy",
                  "Very Happy",
                  Icons.sentiment_very_satisfied,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comment Field
            TextField(
              controller: _commentController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add a comment (optional)",
                hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF5F5F5), // Light grey
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0
                    ? () {
                        widget.controller.submitFeedback(
                          rating: _rating,
                          comment: _commentController.text.trim(),
                          satisfaction: _satisfaction!,
                        );
                      }
                    : null, // Disable if no rating
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold, // Orange/Gold
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[200],
                  disabledForegroundColor: Colors.grey[400],
                ),
                child: Text(
                  "Submit Review",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentChip(String apiKey, String label, IconData icon) {
    final isSelected = _satisfaction == apiKey; // 👈 compare API key
    final color = isSelected ? AppTheme.primaryGold : Colors.grey[400];
    final bgColor = isSelected
        ? AppTheme.primaryGold.withOpacity(0.1)
        : Colors.transparent;
    final textColor = isSelected ? AppTheme.primaryGold : Colors.grey[600];
    final borderColor = isSelected ? AppTheme.primaryGold : Colors.grey[300];

    return GestureDetector(
      onTap: () {
        setState(() {
          _satisfaction = apiKey; // 👈 store API key (e.g. "very_happy")
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
