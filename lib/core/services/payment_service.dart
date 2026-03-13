import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class PaymentService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://prod.brahmakosh.com/api/user/payment",
      headers: {
        'clientId': AppConstants.clientId,
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  
static Future<void> initialize() async {
  try {
    final res = await _dio.get("/config");

    final publishableKey = res.data["publishableKey"];

    if (publishableKey != null) {
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = 'merchant.com.brahmakosh';
      await Stripe.instance.applySettings();
    }
  } catch (e) {
    print("Stripe initialization failed: $e");
  }
}
  static Future<List<dynamic>> getPlans() async {
    final res = await _dio.get("/plans");
    return res.data["data"]["plans"];
  }
  static Future<bool> startPayment({
    int? planAmount,
    int? amount,
  }) async {
    try {
      print("---- create-intent API Request ----");
      print("Request body: { 'planAmount': $planAmount }");
      final res = await _dio.post(
        "/create-intent",
        data: {
          "planAmount": planAmount,
        },
      );
      print("---- create-intent API Response ----");
      print("Response data: ${res.data}");
      final clientSecret = res.data["clientSecret"];
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: "Brahmakosh",
          paymentIntentClientSecret: clientSecret,
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: "IN",
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final paymentIntentId = clientSecret.split("_secret")[0];
      print("Payment Intent ID: $paymentIntentId");

      await _dio.post(
        "/confirm",
        data: {
          "paymentIntentId": paymentIntentId,
        },
      );

      return true;
    } catch (e) {
      print("Payment error $e");
      return false;
    }
  }
}