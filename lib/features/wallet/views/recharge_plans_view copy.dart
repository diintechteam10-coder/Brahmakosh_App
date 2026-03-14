// import 'package:flutter/material.dart';
// import 'package:brahmakosh/core/common_imports.dart';
// import 'dart:io';

// import '../../../core/services/payment_service.dart';
// import '../../../core/services/iap_service.dart';
// import '../../astrology/views/credit_history_view.dart';

// class RechargePlansView extends StatefulWidget {
//   const RechargePlansView({super.key});

//   @override
//   State<RechargePlansView> createState() => _RechargePlansViewState();
// }

// class _RechargePlansViewState extends State<RechargePlansView> {
//   int _selectedPlanIndex = 0;

//   bool _isLoading = true;
//   List<Map<String, dynamic>> _plans = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchPlans();
//   }

//   Future<void> _fetchPlans() async {
//     try {
//       // 1. ALWAYS fetch plans from the Backend API so they show on the screen
//       // final apiPlansResponse = await PaymentService.getPlans();
      
//       List<Map<String, dynamic>> parsedPlans = List<Map<String, dynamic>>.from(
//         apiPlansResponse.map((p) => {
//           "credits": p["credits"],
//           "price": p["amount"],
//           "priceString": "₹ ${p["amount"]}",
//           "package": null, // Will be populated on iOS if a matching IAP exists
//         })
//       );

//       // 2. If iOS, fetch RevenueCat active offerings and attach them to the matching backend plan
//       if (Platform.isIOS) {
//         final offerings = await IAPService.getOfferings();
//         if (offerings != null && offerings.current != null) {
//           final packages = offerings.current!.availablePackages;
          
//           for (var plan in parsedPlans) {
//             final credits = plan["credits"];
//             // Attempt to find a RevenueCat package that matches the credits amount
//             // Adjust this logic if your Product IDs have a specific format
//             try {
//                final matchingPackage = packages.firstWhere((pkg) {
//                  int? pkgCredits = _extractCredits(pkg.storeProduct.identifier) ?? 
//                                    _extractCredits(pkg.storeProduct.title);
//                  return pkgCredits == credits;
//                });
//                plan["package"] = matchingPackage;
//                // Optional: Override the price string to show the localized App Store price
//                plan["priceString"] = matchingPackage.storeProduct.priceString;
//             } catch (e) {
//                debugPrint("No matching IAP package found for $credits credits");
//             }
//           }
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _plans = parsedPlans;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching plans: $e");
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   int? _extractCredits(String text) {
//     final regExp = RegExp(r'\d+');
//     final match = regExp.firstMatch(text);
//     if (match != null) {
//       return int.tryParse(match.group(0) ?? "");
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDF5E6), // Premium Beige bg
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFDF5E6),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Recharge Plans",
//           style: GoogleFonts.playfairDisplay(
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//             color: const Color(0xFF6D3A0C),
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.receipt_long, color: Color(0xFF6D3A0C)),
//             tooltip: "Credit History",
//             onPressed: () {
//               Get.to(() => const CreditHistoryView());
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 8),
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF6D3A0C),
//                     ),
//                   )
//                 : GridView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 20,
//                       mainAxisSpacing: 20,
//                       childAspectRatio: 0.72,
//                     ),
//                     itemCount: _plans.length,
//                     itemBuilder: (context, index) {
//                       final plan = _plans[index];
//                       final isSelected = _selectedPlanIndex == index;
//                       return _buildPlanCard(plan, index, isSelected);
//                     },
//                   ),
//           ),
//           _buildBottomBar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlanCard(Map<String, dynamic> plan, int index, bool isSelected) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedPlanIndex = index;
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isSelected ? const Color(0xFFD4A373) : Colors.transparent,
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: isSelected
//                   ? const Color(0xFFD4A373).withOpacity(0.2)
//                   : Colors.black.withOpacity(0.04),
//               blurRadius: 15,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFDF5E6),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFFFDECB6).withOpacity(0.5),
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.monetization_on,
//                       size: 28,
//                       color: Color(0xFFD4A373),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "${plan['credits']}",
//                     style: GoogleFonts.playfairDisplay(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF6D3A0C),
//                     ),
//                   ),
//                   Text(
//                     "Credits",
//                     style: GoogleFonts.lora(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFF8D6E63),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFF3E0),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       "${plan['priceString']}",
//                       style: GoogleFonts.lora(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFFE65100),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xFFD4A373)
//                     : const Color(0xFFFDF5E6).withOpacity(0.5),
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(22),
//                 ),
//               ),
//               child: Text(
//                 isSelected ? "SELECTED" : "SELECT",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.lora(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                   color: isSelected ? Colors.white : const Color(0xFF8D6E63),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, -10),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: InkWell(
//           onTap: () async {
//             if (_plans.isEmpty) return;
//             final selectedPlan = _plans[_selectedPlanIndex];

//             bool success = false;
//             // Fallback to Stripe if no IAP package is mapped yet, or if on Android
//             if (Platform.isIOS && selectedPlan["package"] != null) {
//                success = await IAPService.purchaseProduct(selectedPlan["package"].storeProduct);
//             } else {
//                success = await PaymentService.startPayment(
//                  planAmount: selectedPlan["price"] is double ? (selectedPlan["price"] as double).toInt() : selectedPlan["price"],
//                );
//             }

//             if(success){
//               Get.snackbar("Success", "Credits processed successfully");
//             } else {
//               Get.snackbar("Error", "Payment failed or cancelled");
//             }
//           },
//           // onTap: () {
//           //   Get.dialog(
//           //     AlertDialog(
//           //       title: Text(
//           //         "Request Sent",
//           //         style: GoogleFonts.playfairDisplay(
//           //           fontWeight: FontWeight.bold,
//           //           color: const Color(0xFF6D3A0C),
//           //         ),
//           //       ),
//           //       content: Text(
//           //         "Your request has been sent for adding amount in wallet.",
//           //         style: GoogleFonts.lora(fontSize: 16),
//           //       ),
//           //       backgroundColor: const Color(0xFFFDF5E6),
//           //       shape: RoundedRectangleBorder(
//           //         borderRadius: BorderRadius.circular(16),
//           //       ),
//           //       actions: [
//           //         TextButton(
//           //           onPressed: () => Get.back(),
//           //           child: Text(
//           //             "OK",
//           //             style: GoogleFonts.lora(
//           //               fontWeight: FontWeight.bold,
//           //               fontSize: 16,
//           //               color: const Color(0xFFE65100),
//           //             ),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   );
//           // },
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             height: 56,
//             decoration: BoxDecoration(
//               color: const Color(0xFF6D3A0C),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF6D3A0C).withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.account_balance_wallet_outlined,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   "Proceed to Payment",
//                   style: GoogleFonts.lora(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
