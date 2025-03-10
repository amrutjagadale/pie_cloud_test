import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentDemo extends StatefulWidget {
  const RazorpayPaymentDemo({Key? key}) : super(key: key);

  @override
  _RazorpayPaymentDemoState createState() => _RazorpayPaymentDemoState();
}

class _RazorpayPaymentDemoState extends State<RazorpayPaymentDemo> {
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    // Attach event listeners
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  // Handler for successful payments
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  // Handler for failed payments
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  // Handler for external wallet selections
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  // Open Razorpay checkout
  void _openCheckout() {
    var options = {
      'key': 'rzp_test_0cumN2yiHhZiuG',
      'amount': 50000, // Amount in paise (e.g. ₹500.00 is 50000 paise)
      'name': 'Acme Corp.',
      'description': 'Test Payment',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@example.com'
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Payment Demo")),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout,
          child: const Text("Pay Now"),
        ),
      ),
    );
  }
}
