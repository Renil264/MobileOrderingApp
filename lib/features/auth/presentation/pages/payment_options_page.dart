import 'dart:async';
import 'dart:convert';
import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:concession_tracker_ui/core/global_selected_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';

class PaymentOptionsDialog extends StatefulWidget {
  final double paymentAmount;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentCancel;

  const PaymentOptionsDialog({
    super.key,
    required this.paymentAmount,
    required this.onPaymentSuccess,
    required this.onPaymentCancel,
  });

  @override
  State<PaymentOptionsDialog> createState() => _PaymentOptionsDialogState();
}

class _PaymentOptionsDialogState extends State<PaymentOptionsDialog>
    with TickerProviderStateMixin {
  String? _selectedPaymentMethod;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_selectedPaymentMethod == null) return;

    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EdgeExpressPaymentScreen(
          paymentAmount: widget.paymentAmount,
          paymentType: _selectedPaymentMethod!,
          onSuccess: widget.onPaymentSuccess,
          onCancel: widget.onPaymentCancel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how you\'d like to pay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gradientTop.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gradientTop.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Amount to Pay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${widget.paymentAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gradientTop,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                _buildPaymentOption(
                  icon: Icons.payments_outlined,
                  title: 'Credit Card',
                  subtitle: 'Use your credit card for payment',
                  value: 'credit',
                ),
                const SizedBox(height: 32),

                SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedPaymentMethod != null
                            ? AppColors.gradientTop
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _selectedPaymentMethod != null ? 4 : 0,
                      ),
                      onPressed: _selectedPaymentMethod != null
                          ? _proceedToPayment
                          : null,
                      child: Text(
                        'Continue to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedPaymentMethod != null
                              ? Colors.white
                              : Colors.grey[600],
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onPaymentCancel();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.gradientTop
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1.5,
            ),
            color: isSelected
                ? AppColors.gradientTop.withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.gradientTop.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.gradientTop,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.gradientTop,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Payment Screen
class EdgeExpressPaymentScreen extends StatefulWidget {
  final double paymentAmount;
  final String paymentType;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const EdgeExpressPaymentScreen({
    super.key,
    required this.paymentAmount,
    required this.paymentType,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<EdgeExpressPaymentScreen> createState() =>
      _EdgeExpressPaymentScreenState();
}

class _EdgeExpressPaymentScreenState extends State<EdgeExpressPaymentScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _pageLoaded = false;
  String? _error;
  String _apiUrl = 'http://192.168.10.144/ConcessionTracker/api';
  int _concessionId = GlobalSelectedItem.concessionId;
  int _retryCount = 0;
  final int _maxRetries = 2;
  Timer? _loadingTimeout;
  bool _errorShown = false;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
    _initializePayment();

    // Longer timeout for slow test server
    _loadingTimeout = Timer(const Duration(seconds: 12), () {
      if (mounted && _isLoading) {
        print('[EdgeExpress] Timeout - hiding loader');
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _showBackConfirmation() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Exit',
      text: 'Are you sure you want to go back? Your payment session will be cancelled.',
      confirmBtnText: 'Continue Payment',
      cancelBtnText: 'Go Back',
      showCancelBtn: true,
      barrierDismissible: false,
      confirmBtnColor: AppColors.gradientTop,
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
      onCancelBtnTap: () {
        Navigator.pop(context); // Close QuickAlert
        Navigator.pop(context); // Go back from payment screen
        widget.onCancel();
      },
    );
  }

  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('[WebView] 🔄 Page started: $url');
          },
          onPageFinished: (String url) {
            print('[WebView] ✅ Page finished: $url');

            if (mounted) {
              setState(() {
                _pageLoaded = true;
                _isLoading = false;
              });
              print('[WebView] Page loaded and ready');
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('[WebView] ⚠️ Error Code: ${error.errorCode}');
            print('[WebView] ⚠️ Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('[WebView] 🔗 Navigation: ${request.url}');

            if (request.url.contains('asinquiryapp/?params=')) {
              print('[WebView] 💳 Payment response detected!');
              _processPaymentResponse(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.contains('cancel')) {
              print('[WebView] ❌ Payment cancelled');
              if (mounted) {
                Navigator.pop(context);
                widget.onCancel();
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );
  }

  void _showExitConfirmation() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Exit Payment?',
      text: 'Are you sure you want to exit the payment process? Your transaction will be cancelled.',
      confirmBtnText: 'Continue Payment',
      cancelBtnText: 'Exit',
      showCancelBtn: true,
      barrierDismissible: false,
      confirmBtnColor: AppColors.gradientTop,
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
      onCancelBtnTap: () {
        Navigator.pop(context); // Close QuickAlert
        Navigator.pop(context); // Go back from payment screen
        widget.onCancel();
      },
    );
  }

  Future<void> _initializePayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _concessionId = prefs.getInt('concessionId') ?? 49;
      await _fetchEdgeExpressDetailsAndPay();
    } catch (e) {
      print('[EdgeExpress] ❌ Initialization Error: $e');
      setState(() {
        _error = 'Failed to initialize payment: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchEdgeExpressDetailsAndPay() async {
    try {
      final url = Uri.parse(
        '$_apiUrl/Users/edgexpress-details?concessionId=$_concessionId',
      );

      print('[EdgeExpress] 📡 Fetching details from: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('[EdgeExpress] ✅ Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        String terminalId = jsonData['terminalId'] ?? '';
        String xWebId = jsonData['xWebId'] ?? '';
        String authId = jsonData['authId'] ?? '';
        String paymentUrl = jsonData['paymentUrl'] ?? '';

        if (terminalId.isEmpty || xWebId.isEmpty || authId.isEmpty) {
          throw Exception('Invalid Edge Express configuration');
        }

        await _submitPaymentRequest(
          terminalId: terminalId,
          xWebId: xWebId,
          authId: authId,
          paymentUrl: paymentUrl,
        );
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[EdgeExpress] ❌ Fetch Error: $e');

      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('[EdgeExpress] 🔄 Retry ${_retryCount}/$_maxRetries...');
        await Future.delayed(const Duration(seconds: 2));
        await _fetchEdgeExpressDetailsAndPay();
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitPaymentRequest({
    required String terminalId,
    required String xWebId,
    required String authId,
    required String paymentUrl,
  }) async {
    try {
      String xmlBody = _generateXmlRequest(
        terminalId: terminalId,
        xWebId: xWebId,
        authId: authId,
        amount: widget.paymentAmount.toString(),
      );

      print('[EdgeExpress] 📨 Submitting XML Request');

      final url = Uri.parse(
        paymentUrl.replaceAll('/paypage/', '/transactions/'),
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/xml'},
        body: xmlBody,
      ).timeout(const Duration(seconds: 30));

      print('[EdgeExpress] ✅ XML Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        String cleanedXml = _cleanXmlString(response.body);
        var xmlDoc = XmlDocument.parse(cleanedXml);

        String payPageUrl = xmlDoc
            .findElements('RESULT')
            .single
            .findElements('PAYPAGEURL')
            .single
            .innerText;

        print('[EdgeExpress] 🌐 Pay Page URL: $payPageUrl');

        if (mounted) {
          print('[EdgeExpress] 📲 Loading payment page...');
          await _webViewController.loadRequest(Uri.parse(payPageUrl));
        }
      } else {
        throw Exception('Payment gateway returned ${response.statusCode}');
      }
    } catch (e) {
      print('[EdgeExpress] ❌ Submit Error: $e');

      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('[EdgeExpress] 🔄 Retry ${_retryCount}/$_maxRetries...');
        await Future.delayed(const Duration(seconds: 2));
        await _fetchEdgeExpressDetailsAndPay();
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processPaymentResponse(String url) async {
    try {
      String? paramsXml = Uri.parse(url).queryParameters['params'];
      if (paramsXml == null) {
        throw Exception('No payment response received');
      }

      print('[EdgeExpress] 💳 Payment Response Received');

      String cleanedXml = _cleanXmlString(paramsXml);
      var xmlDoc = XmlDocument.parse(cleanedXml);

      String responseCode = xmlDoc
          .findElements('RESULT')
          .single
          .findElements('RESPONSECODE')
          .single
          .innerText;

      String responseDesc = xmlDoc
          .findElements('RESULT')
          .single
          .findElements('RESPONSEDESCRIPTION')
          .single
          .innerText;

      String orderId = xmlDoc
          .findElements('RESULT')
          .single
          .findElements('ORDERID')
          .single
          .innerText;

      print('[EdgeExpress] ✅ Response Code: $responseCode');
      print('[EdgeExpress] ✅ Response Desc: $responseDesc');
      print('[EdgeExpress] ✅ Order ID: $orderId');

      if (responseCode == '000' && responseDesc.toUpperCase() == 'APPROVAL') {
        await _savePaymentDetails(
          responseCode: responseCode,
          responseDesc: responseDesc,
          orderId: orderId,
        );

        if (mounted) {
          Navigator.pop(context);
          widget.onSuccess();
        }
      } else {
        throw Exception('Payment declined: $responseDesc');
      }
    } catch (e) {
      print('[EdgeExpress] ❌ Response Error: $e');
      if (mounted && !_errorShown) {
        _errorShown = true;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Payment Failed',
          text: e.toString(),
          confirmBtnText: 'OK',
          confirmBtnColor: Colors.red,
          onConfirmBtnTap: () {
            Navigator.pop(context); // Close QuickAlert
            // Navigate to home page and clear navigation stack
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          },
        );
      }
    }
  }

  Future<void> _savePaymentDetails({
    required String responseCode,
    required String responseDesc,
    required String orderId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('paymentResponseCode', responseCode);
      await prefs.setString('paymentResponseDesc', responseDesc);
      await prefs.setString('paymentOrderId', orderId);
      await prefs.setDouble('paymentAmount', widget.paymentAmount);
      await prefs.setString('paymentType', widget.paymentType);
      await prefs.setString(
        'paymentDateTime',
        DateTime.now().toIso8601String(),
      );

      print('[EdgeExpress] ✅ Payment details saved');
    } catch (e) {
      print('[EdgeExpress] ❌ Save Error: $e');
    }
  }

  String _generateXmlRequest({
    required String terminalId,
    required String xWebId,
    required String authId,
    required String amount,
  }) {
    int unixTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    String orderId = unixTimestamp.toString();

    return '''<?xml version="1.0" encoding="utf-8"?>
<REQUEST>
  <XWEBID>$xWebId</XWEBID>
  <XWEBTERMINALID>$terminalId</XWEBTERMINALID>
  <XWEBAUTHKEY>$authId</XWEBAUTHKEY>
  <TRANSACTIONTYPE>CREDITSALE</TRANSACTIONTYPE>
  <AMOUNT>$amount</AMOUNT>
  <ALLOWDUPLICATES>TRUE</ALLOWDUPLICATES>
  <ORDERID>$orderId</ORDERID>
  <HOSTPAYSETTING>
    <RETURNOPTION>
      <RETURNTARGET>_self</RETURNTARGET>
      <RETURNURL>http://asinquiryapp/?params=</RETURNURL>
    </RETURNOPTION>
    <DISABLEFRAMING>False</DISABLEFRAMING>
    <POSDEVICE>
      <TYPE>KEYED</TYPE>
    </POSDEVICE>
    <CUSTOMIZATION>
      <PAGE>
        <CREDITCARDVERIFICATIONNUMBER>
          <REQUIRED>TRUE</REQUIRED>
        </CREDITCARDVERIFICATIONNUMBER>
        <BILLINGADDRESSONE>
          <EDIT>TRUE</EDIT>
          <VISIBLE>TRUE</VISIBLE>
          <REQUIRED>TRUE</REQUIRED>
        </BILLINGADDRESSONE>
        <BILLINGPOSTALCODE>
          <EDIT>TRUE</EDIT>
          <VISIBLE>TRUE</VISIBLE>
          <REQUIRED>TRUE</REQUIRED>
        </BILLINGPOSTALCODE>
        <CANCELBUTTON>
          <LABEL>Cancel</LABEL>
          <VISIBLE>TRUE</VISIBLE>
        </CANCELBUTTON>
      </PAGE>
    </CUSTOMIZATION>
  </HOSTPAYSETTING>
</REQUEST>''';
  }

  String _cleanXmlString(String input) {
    return input.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.gradientTop,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: _showBackConfirmation,
        ),
        title: const Text(
          'Concession Tracker App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _error == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.gradientTop,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading payment gateway...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Payment Error: $_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gradientTop,
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: WebViewWidget(controller: _webViewController),
                ),
    );
  }
}