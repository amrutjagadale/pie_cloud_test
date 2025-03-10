import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class HDPackagesPage extends StatefulWidget {
  const HDPackagesPage({Key? key}) : super(key: key);

  @override
  State<HDPackagesPage> createState() => _HDPackagesPageState();
}

class _HDPackagesPageState extends State<HDPackagesPage> {
  Razorpay? _razorpay;

  // Example data
  int hdPhotosDownloaded = 0;
  int hdVideosDownloaded = 0;
  int selectedPackageIndex = 0;

  // List of packages (price in GBP)
  final List<Map<String, dynamic>> packages = [
    {
      'title': 'HD Photos',
      'subtitle': 'Pack 50 photos',
      'price': 4.99, // in GBP
      'note': null,
    },
    {
      'title': 'HD Videos',
      'subtitle': 'Pack 50 videos',
      'price': 9.99, // in GBP
      'note': '*Only for PIE1058 and PIE1067',
    },
  ];

  // Fixed conversion rate: 1 GBP = 100 INR (example)
  static const double conversionRate = 100.0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    // Attach event listeners for payment outcomes
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  // Payment success handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  // Payment error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  // External wallet selection handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the selected package's INR price
    final selectedPackage = packages[selectedPackageIndex];
    double priceGBP = selectedPackage['price'] as double;
    double priceINR = priceGBP * conversionRate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HD Package'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Downloads available section
            const Text(
              'Downloads available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$hdPhotosDownloaded HD Photos'),
                Text('$hdVideosDownloaded HD Videos'),
              ],
            ),
            const SizedBox(height: 24),
            // Package selection header
            const Text(
              'Buy a new pack',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // List of available packages with radio selection
            ...List.generate(packages.length, (index) {
              final package = packages[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: selectedPackageIndex,
                  onChanged: (val) {
                    setState(() {
                      selectedPackageIndex = val!;
                    });
                  },
                  title: Text(package['title'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package['subtitle'] as String),
                      if (package['note'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          package['note'] as String,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  secondary: Text(
                    '£ ${package['price']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
            const Spacer(),
            // Razorpay payment button with inline integration
            ElevatedButton(
              onPressed: () {
                final selectedPackage = packages[selectedPackageIndex];
                double priceGBP = selectedPackage['price'] as double;

                // Convert GBP to INR (if your Razorpay account uses INR)
                double priceINR = priceGBP * conversionRate;
                int amountPaise = (priceINR * 100).toInt(); // 1 INR = 100 paise

                var options = {
                  'key': 'rzp_test_0cumN2yiHhZiuG', // Replace with your key
                  'amount': amountPaise,
                  'currency': 'INR', // Match your Razorpay account's currency
                  'name': selectedPackage['title'],
                  'description': selectedPackage['subtitle'],
                  'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
                  'theme': {'color': '#F37254'},
                };

                try {
                  _razorpay?.open(options);
                } catch (e) {
                  debugPrint('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Payment Error: ${e.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text('Pay Now (₹${priceINR.toStringAsFixed(2)})'),
            ),
          ],
        ),
      ),
    );
  }
}
