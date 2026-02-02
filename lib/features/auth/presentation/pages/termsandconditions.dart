import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _isChecked = false;

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.privacypolicygenerator.info/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _handleConfirm() {
    if (_isChecked) {
      // Handle confirmation logic here
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Privacy Policy to continue'),
          backgroundColor: AppColors.gradientTop,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.18,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'My Website one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by My Website and how we use it.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'This privacy policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in My Website. This policy is not applicable to any information collected offline or via channels other than this website.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Consent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'By using our website, you hereby consent to our Privacy Policy and agree to its terms. This Privacy Policy has been generated with the Privacy Policy Generator which is available from https://www.privacypolicygenerator.info/',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isChecked
                                ? AppColors.gradientTop
                                : Colors.white,
                            border: Border.all(
                              color: _isChecked
                                  ? AppColors.gradientTop
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _isChecked
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            children: [
                              const Text(
                                'I agree with the ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              GestureDetector(
                                onTap: _launchURL,
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.gradientTop,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientTop,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}