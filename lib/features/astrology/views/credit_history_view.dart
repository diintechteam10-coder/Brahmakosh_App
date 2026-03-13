import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/credit_history_controller.dart';

class CreditHistoryView extends StatelessWidget {
  const CreditHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreditHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Credit History',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }

        if (controller.creditHistory.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppTheme.primaryGold,
          onRefresh: () => controller.fetchCreditHistory(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 100) {
                controller.fetchCreditHistory(loadMore: true);
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount:
                  controller.creditHistory.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.creditHistory.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGold,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                return _buildHistoryCard(controller.creditHistory[index]);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No credit history yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your credit usage will appear here',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final int creditsUsed = item['creditsUsed'] ?? 0;
    final int billableMinutes = item['billableMinutes'] ?? 0;
    final String createdAt = item['createdAt'] ?? '';
    final partner = item['partner'];
    final String partnerName = partner is Map
        ? (partner['name'] ?? 'Astrologer')
        : 'Astrologer';
    final String partnerPhoto = partner is Map
        ? (partner['profilePhoto'] ?? partner['profilePicture'] ?? '')
        : '';
    final String expertise = partner is Map
        ? _parseExpertise(partner['expertise'])
        : '';

    // Format date
    String formattedDate = '';
    String formattedTime = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
        formattedTime = DateFormat('hh:mm a').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0D5CC).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Partner info + credits
          Row(
            children: [
              // Partner avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFFFF3E0),
                  backgroundImage: partnerPhoto.isNotEmpty
                      ? NetworkImage(partnerPhoto)
                      : null,
                  child: partnerPhoto.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF8D6E63),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Partner name & expertise
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                    if (expertise.isNotEmpty)
                      Text(
                        expertise,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF8D6E63),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Credits badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.toll, size: 14, color: AppTheme.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      '$creditsUsed',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: const Color(0xFFF5EDE6)),
          const SizedBox(height: 10),

          // Bottom row: Duration & Date
          Row(
            children: [
              // Duration
              _buildInfoChip(Icons.timer_outlined, '$billableMinutes min'),
              const SizedBox(width: 16),
              // Date
              _buildInfoChip(Icons.calendar_today_outlined, formattedDate),
              const Spacer(),
              // Time
              Text(
                formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8D6E63)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }

  String _parseExpertise(dynamic value) {
    if (value is List) return value.join(', ');
    if (value is String) return value;
    return '';
  }
}
