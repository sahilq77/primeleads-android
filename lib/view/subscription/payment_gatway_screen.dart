import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prime_leads/controller/subscription/set_order_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/subscription/get_subscription_response.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/utility/app_utility.dart';
import '../../controller/subscription/set_payment_controller.dart';

class RazorpayGateway extends StatefulWidget {
  final num totalPayable;
  final String subscriptionId;
  final num finalOrderPrice;

  const RazorpayGateway({
    super.key,
    required this.totalPayable,
    required this.subscriptionId,
    required this.finalOrderPrice,
  });

  @override
  State<RazorpayGateway> createState() => _RazorpayGatewayState();
}

class _RazorpayGatewayState extends State<RazorpayGateway> {
  late Razorpay _razorpay;
  final SetPaymentController _setPaymentController = Get.put(
    SetPaymentController(),
  );
  final SetOrderController setOrderController = Get.put(SetOrderController());

  // Test Credentials (Replace with production credentials as needed)
  // final String _keyId = 'rzp_test_R7Swkdhjyig54S';
  // final String _keySecret = 'jS36wByFlnpeVgyEicfK2AFb';

  final String _keyId = 'rzp_live_R7zacfGtzhXGgs'; //live
  final String _keySecret = 'uJvnRhRllfqNuqqticemkVKX';

  String transactionId = "RT${DateTime.now().millisecondsSinceEpoch}";

  // StringBuffer to collect all logs
  final StringBuffer _logBuffer = StringBuffer();

  @override
  void initState() {
    super.initState();
    _log('[RazorpayGateway] Initializing with:');
    _log('[RazorpayGateway] totalPayable: ${widget.totalPayable}');
    _log('[RazorpayGateway] subscriptionId: ${widget.subscriptionId}');
    _log('[RazorpayGateway] finalOrderPrice: ${widget.finalOrderPrice}');
    _log('[RazorpayGateway] transactionId: $transactionId');
    _initializeRazorpay();
    _createOrder();
  }

  // Helper method to log to both debugPrint and StringBuffer
  void _log(String message) {
    debugPrint(message);
    _logBuffer.writeln('${DateTime.now().toIso8601String()}: $message');
  }

  void _initializeRazorpay() {
    _log('[RazorpayGateway] Initializing Razorpay');
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _createOrder() async {
    try {
      // Validate amount
      if (widget.finalOrderPrice < 1) {
        _log(
          '[RazorpayGateway] Error: finalOrderPrice (${widget.finalOrderPrice}) is less than minimum allowed (₹1.00)',
        );
        _showErrorSnackBar('Invalid amount: Minimum ₹1.00 required');
        return;
      }

      final authString = base64Encode(utf8.encode('$_keyId:$_keySecret'));
      _log('[RazorpayGateway] Auth String: $authString');

      final amountInPaise = (widget.finalOrderPrice * 100).toInt();
      _log(
        '[RazorpayGateway] Sending amount to Razorpay: $amountInPaise paise (₹${widget.finalOrderPrice})',
      );

      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $authString',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'currency': 'INR',
          'receipt': transactionId,
          'payment_capture': 1,
        }),
      );

      _log(
        '[RazorpayGateway] Order Creation Response Status Code: ${response.statusCode}',
      );
      _log(
        '[RazorpayGateway] Order Creation Response Headers: ${response.headers}',
      );
      _log('[RazorpayGateway] Order Creation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);
        _log(
          '[RazorpayGateway] Order created successfully: ${orderData['id']}',
        );
        _log('[RazorpayGateway] Full Order Data: $orderData');
        _openCheckout(orderData['id']);
      } else {
        _log('[RazorpayGateway] Order creation failed: ${response.body}');
        _showErrorSnackBar('Order creation failed: ${response.body}');
      }
    } catch (e) {
      _log('[RazorpayGateway] Error creating order: $e');
      _showErrorSnackBar('Error creating order: $e');
    }
  }

  void _openCheckout(String orderId) {
    final amountInPaise = (widget.finalOrderPrice * 100).toInt();
    _log(
      '[RazorpayGateway] Opening checkout with orderId: $orderId, amount: $amountInPaise paise',
    );

    var options = {
      'key': _keyId,
      'amount': amountInPaise,
      'name': 'Prime Leads',
      'description': 'Payment for Subscription Package',
      'order_id': orderId,
      'prefill': {'contact': AppUtility.mobileNumber ?? '', 'email': ''},
      'theme': {'color': '#00A89F'},
    };

    _log('[RazorpayGateway] Checkout Options: $options');

    try {
      _razorpay.open(options);
      _log('[RazorpayGateway] Razorpay checkout opened');
    } catch (e) {
      _log('[RazorpayGateway] Error opening Razorpay checkout: $e');
      _showErrorSnackBar('Error opening checkout: $e');
    }
  }

  Future<bool> _callSetPaymentApi(String paymentStatus) async {
    try {
      _log('[RazorpayGateway] Calling setPayment API with:');
      _log('[RazorpayGateway] subscriptionId: ${widget.subscriptionId}');
      _log('[RazorpayGateway] paymentStatus: $paymentStatus');
      _log('[RazorpayGateway] transactionId: $transactionId');

      await _setPaymentController.setPayment(
        refNo: setOrderController.setOrderList.first.refNo,
        subsUserid: setOrderController.setOrderList.first.id,
        context: context,
        subscriptionid: setOrderController.setOrderList.first.subscribtionId,
        paymentStaus: paymentStatus,
        transactionID: transactionId,
      );

      _log(
        '[RazorpayGateway] setPayment API call completed. isLoading: ${_setPaymentController.isLoading.value}',
      );

      return !_setPaymentController.isLoading.value;
    } catch (e) {
      _log('[RazorpayGateway] Error in setPayment API: $e');
      _showErrorSnackBar('Failed to update payment status: $e');
      return false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _log('[RazorpayGateway] Payment Success Response:');
    _log('[RazorpayGateway]   paymentId: ${response.paymentId}');
    _log('[RazorpayGateway]   orderId: ${response.orderId}');
    _log('[RazorpayGateway]   signature: ${response.signature}');
    _log('[RazorpayGateway] Full Success Response: ${response.data}');

    _log('[RazorpayGateway] Calling setPayment API with:');
    _log('[RazorpayGateway] transactionId: $transactionId');
    _log('[RazorpayGateway] subscriptionId: ${widget.subscriptionId}');
    _log('[RazorpayGateway] paymentStatus: 1');

    bool apiSuccess = await _callSetPaymentApi("1");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(
        AppRoutes.paymentRieceipt,
        arguments: {
          'transactionId': transactionId,
          'subscriptionId': widget.subscriptionId,
          'amount': widget.finalOrderPrice,
          'paymentId': response.paymentId,
        },
      );
    });

    if (!apiSuccess) {
      _log(
        '[RazorpayGateway] setPayment API call failed, but navigating to receipt',
      );
      _showErrorSnackBar(
        'Payment recorded, but status update failed. Contact support if needed.',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    _log('[RazorpayGateway] Payment Error Response:');
    _log('[RazorpayGateway]   code: ${response.code}');
    _log('[RazorpayGateway]   message: ${response.message}');
    _log('[RazorpayGateway] Full Error Response: ${response.error}');

    await _callSetPaymentApi("0");
    _showErrorSnackBar(response.message ?? "Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _log('[RazorpayGateway] External Wallet Selected: ${response.walletName}');
  }

  void _showErrorSnackBar(String message) {
    _log('[RazorpayGateway] Showing error snackbar: $message');
    Get.snackbar(
      'Payment Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
    Navigator.of(context).pop();
  }

  // Method to retrieve full logs
  String getFullLogs() {
    return _logBuffer.toString();
  }

  @override
  void dispose() {
    _log('[RazorpayGateway] Disposing RazorpayGateway');
    _razorpay.clear();
    // Optionally, save logs to a file or display them
    debugPrint('[RazorpayGateway] Full Logs:\n${getFullLogs()}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Center(
          child:
              _setPaymentController.isLoading.value
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Processing Payment...'),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      const Text('Initiating Payment...'),
                      const SizedBox(height: 20),
                      // Button to display full logs (for testing)
                      ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Payment Logs',
                            getFullLogs(),
                            duration: const Duration(seconds: 10),
                            snackPosition: SnackPosition.TOP,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          );
                        },
                        child: const Text('Show Full Logs'),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
