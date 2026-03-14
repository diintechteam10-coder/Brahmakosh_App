import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_progress_screen.dart';
import 'choose_sankalp_screen.dart';

class CompletedSankalpTab extends StatelessWidget {
  const CompletedSankalpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SankalpBloc, SankalpState>(
      builder: (context, state) {
        if (state is SankalpLoading && state is! SankalpLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SankalpError) {
          return Center(child: Text(state.message));
        }

        List<UserSankalpModel> completedSankalps = [];
        if (state is SankalpLoaded) {
          completedSankalps = state.userSankalps
              .where((s) => s.status == 'completed')
              .toList();
        }

        Widget _buildEmptyState(BuildContext context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative Illustration
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.history_outlined,
                          size: 80,
                          color: Color(0xff8D6E63),
                        ),
                        Positioned(
                          top: 40,
                          right: 40,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.withOpacity(0.5),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Your Journey Awaits",
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff4E342E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You haven't completed any sankalps yet.\nEvery journey begins with a single step.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xff7D6E63),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      final bloc = context.read<SankalpBloc>();
                      Get.to(
                        () => BlocProvider.value(
                          value: bloc,
                          child: const ChooseSankalpScreen(),
                        ),
                        transition: Transition.downToUp,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffff7438),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffff7438).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        "Choose a Sankalp",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (completedSankalps.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: completedSankalps.length,
          itemBuilder: (context, index) {
            final userSankalp = completedSankalps[index];
            return _buildCompletedCard(context, userSankalp);
          },
        );
      },
    );
  }

  Widget _buildCompletedCard(
    BuildContext context,
    UserSankalpModel userSankalp,
  ) {
    final sankalp = userSankalp.sankalp;
    return GestureDetector(
      onTap: () {
        final bloc = context.read<SankalpBloc>();
        Get.to(
          () => BlocProvider.value(
            value: bloc,
            child: SankalpProgressScreen(sankalpId: userSankalp.id),
          ),
          transition: Transition.rightToLeft,
        )?.then((_) {
          bloc.add(FetchUserSankalps());
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(
                          sankalp.bannerImage.isNotEmpty
                              ? sankalp.bannerImage
                              : "https://images.unsplash.com/photo-1604881991720-f91add269bed?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sankalp.title,
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff4E342E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.history_edu,
                              size: 14,
                              color: Color(0xff8D6E63),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${userSankalp.totalDays} Days Completed",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff8D6E63),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "SUCCESS",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    size: 18,
                    color: Color(0xffD4AF37),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Total Karma Earned",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "+${userSankalp.totalDays * sankalp.karmaPointsPerDay}",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff4E342E),
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
