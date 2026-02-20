import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/features/auth/presentation/screens/login_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/signup_screen.dart';
import 'package:four_ideas/services/order_service.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHereScreen extends StatefulWidget {
  const OrderHereScreen({super.key});

  @override
  State<OrderHereScreen> createState() => _OrderHereScreenState();
}

class _OrderHereScreenState extends State<OrderHereScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Email Service Configuration
  // Choose one of the following options:

  // OPTION 1: Formspree (Recommended - Simple & Reliable)
  // 1. Go to https://formspree.io/ and sign up (free tier: 50 submissions/month)
  // 2. Create a new form and get your form endpoint
  // 3. Replace the endpoint below with your Formspree form endpoint
  // 4. Configure the recipient email in your Formspree dashboard (Settings > Email)
  // Example: 'https://formspree.io/f/YOUR_FORM_ID'
  // Note: Free tier sends to the email used when creating the form. Custom _to field requires paid plan.
  static const String _formspreeEndpoint = 'https://formspree.io/f/maqwlqlq';

  // OPTION 2: Web3Forms (Alternative - Also Free)
  // 1. Go to https://web3forms.com/ and sign up (free tier: 250 submissions/month)
  // 2. Get your access key from the dashboard
  // 3. Replace the access key below
  // 4. Set _useWeb3Forms to true and _useFormspree to false
  static const String _web3FormsAccessKey = 'YOUR_WEB3FORMS_ACCESS_KEY';

  // Which service to use (set to true for the service you want to use)
  static const bool _useFormspree =
      true; // Set to false to use Web3Forms instead
  static const bool _useWeb3Forms = false;

  // Recipient email (where you want to receive the form submissions)
  // Note: For Formspree free tier, this should match the email in your Formspree dashboard.
  // The _recipientEmail constant is currently only used by Web3Forms.
  static const String _recipientEmail = 'johnacolani@gmail.com';

  // Controllers
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();
  final TextEditingController _clientCompanyController =
      TextEditingController();
  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _appDescriptionController =
      TextEditingController();
  final TextEditingController _appFeaturesController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();
  final TextEditingController _colorSchemeController = TextEditingController();
  final TextEditingController _designInspirationController =
      TextEditingController();
  final TextEditingController _brandGuidelinesController =
      TextEditingController();

  // Dropdown values
  String? _selectedAppType;
  String? _selectedPriority;
  String? _selectedDesignStyle;
  String? _selectedDesignComplexity;

  // Platform checkboxes
  Set<String> _selectedPlatforms = {};

  // Storage keys
  static const String _storageKeyPrefix = 'order_form_';
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedFormData();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientCompanyController.dispose();
    _appNameController.dispose();
    _appDescriptionController.dispose();
    _appFeaturesController.dispose();
    _budgetController.dispose();
    _timelineController.dispose();
    _additionalNotesController.dispose();
    _colorSchemeController.dispose();
    _designInspirationController.dispose();
    _brandGuidelinesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Check authentication first
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      _showSignUpRequiredDialog();
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_selectedPlatforms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one target platform'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Save form data before submission in case of failure
      await _saveFormData();

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Save order to Firestore
        final orderService = OrderService();
        await orderService.saveOrder(
          clientName: _clientNameController.text,
          clientEmail: _clientEmailController.text,
          clientPhone: _clientPhoneController.text.isNotEmpty ? _clientPhoneController.text : null,
          clientCompany: _clientCompanyController.text.isNotEmpty ? _clientCompanyController.text : null,
          appName: _appNameController.text,
          appType: _selectedAppType,
          appDescription: _appDescriptionController.text.isNotEmpty ? _appDescriptionController.text : null,
          appFeatures: _appFeaturesController.text.isNotEmpty ? _appFeaturesController.text : null,
          budget: _budgetController.text.isNotEmpty ? _budgetController.text : null,
          timeline: _timelineController.text.isNotEmpty ? _timelineController.text : null,
          priority: _selectedPriority,
          designStyle: _selectedDesignStyle,
          designComplexity: _selectedDesignComplexity,
          selectedPlatforms: _selectedPlatforms.isNotEmpty ? _selectedPlatforms : null,
          colorScheme: _colorSchemeController.text.isNotEmpty ? _colorSchemeController.text : null,
          designInspiration: _designInspirationController.text.isNotEmpty ? _designInspirationController.text : null,
          brandGuidelines: _brandGuidelinesController.text.isNotEmpty ? _brandGuidelinesController.text : null,
          additionalNotes: _additionalNotesController.text.isNotEmpty ? _additionalNotesController.text : null,
        );

        http.Response response;

        if (_useFormspree) {
          // Send email using Formspree
          response = await _sendViaFormspree();
        } else if (_useWeb3Forms) {
          // Send email using Web3Forms
          response = await _sendViaWeb3Forms();
        } else {
          throw Exception(
              'No email service configured. Please set _useFormspree or _useWeb3Forms to true.');
        }

        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Clear saved form data on success
          await _clearSavedFormData();
          // Show success dialog
          _showSuccessDialog();
        } else {
          // Show error message with more details
          String errorMessage = 'Failed to send email. Please try again later.';
          try {
            final responseBody = jsonDecode(response.body);
            if (responseBody.containsKey('error')) {
              errorMessage = 'Error: ${responseBody['error']}';
            } else if (responseBody.containsKey('message')) {
              errorMessage = 'Error: ${responseBody['message']}';
            } else if (responseBody.containsKey('errors')) {
              // Formspree error format
              final errors = responseBody['errors'];
              if (errors is List && errors.isNotEmpty) {
                errorMessage =
                    'Error: ${errors[0]['message'] ?? 'Validation error'}';
              }
            }
          } catch (e) {
            // If parsing fails, use default message
            errorMessage =
                'Failed to send email (Status: ${response.statusCode}). Please check your email service configuration.';
          }
          _showErrorDialog(errorMessage);
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        String errorMessage = 'Error: ${e.toString()}';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        } else if (_useFormspree &&
            _formspreeEndpoint.contains('YOUR_FORM_ID')) {
          errorMessage =
              'Formspree configuration error. Please configure your Formspree endpoint in the code.';
        } else if (_useWeb3Forms &&
            _web3FormsAccessKey.contains('YOUR_WEB3FORMS_ACCESS_KEY')) {
          errorMessage =
              'Web3Forms configuration error. Please configure your Web3Forms access key in the code.';
        }
        _showErrorDialog(errorMessage);
      }
    }
  }

  Future<http.Response> _sendViaFormspree() async {
    final emailBody = _buildEmailBody();

    // Note: Formspree free tier sends emails to the email address used when creating the form.
    // The _to field and subject field require a paid plan. Configure these in your Formspree dashboard.
    return await http
        .post(
      Uri.parse(_formspreeEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': _clientNameController.text,
        'email': _clientEmailController.text,
        'phone': _clientPhoneController.text.isNotEmpty
            ? _clientPhoneController.text
            : 'Not provided',
        'company': _clientCompanyController.text.isNotEmpty
            ? _clientCompanyController.text
            : 'Not provided',
        'app_name': _appNameController.text,
        'app_type': _selectedAppType ?? 'Not specified',
        'app_description': _appDescriptionController.text,
        'app_features': _appFeaturesController.text.isNotEmpty
            ? _appFeaturesController.text
            : 'Not specified',
        'target_platforms': _selectedPlatforms.join(', '),
        'priority': _selectedPriority ?? 'Not specified',
        'budget': _budgetController.text.isNotEmpty
            ? _budgetController.text
            : 'Not specified',
        'timeline': _timelineController.text.isNotEmpty
            ? _timelineController.text
            : 'Not specified',
        'additional_notes': _additionalNotesController.text.isNotEmpty
            ? _additionalNotesController.text
            : 'None',
        'design_style': _selectedDesignStyle ?? 'Not specified',
        'design_complexity': _selectedDesignComplexity ?? 'Not specified',
        'color_scheme': _colorSchemeController.text.isNotEmpty
            ? _colorSchemeController.text
            : 'Not specified',
        'design_inspiration': _designInspirationController.text.isNotEmpty
            ? _designInspirationController.text
            : 'Not specified',
        'brand_guidelines': _brandGuidelinesController.text.isNotEmpty
            ? _brandGuidelinesController.text
            : 'Not specified',
        'message': emailBody,
        // Removed 'subject' and '_to' fields - these require a paid Formspree plan.
        // Email recipient is set in Formspree dashboard when creating the form.
        // Subject can be configured in the Formspree dashboard or email template.
      }),
    )
        .timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception(
            'Request timeout. Please check your internet connection and try again.');
      },
    );
  }

  Future<http.Response> _sendViaWeb3Forms() async {
    final emailBody = _buildEmailBody();

    return await http
        .post(
      Uri.parse('https://api.web3forms.com/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'access_key': _web3FormsAccessKey,
        'subject': 'New Order Request: ${_appNameController.text}',
        'from_name': _clientNameController.text,
        'from_email': _clientEmailController.text,
        'to_email': _recipientEmail,
        'name': _clientNameController.text,
        'email': _clientEmailController.text,
        'phone': _clientPhoneController.text.isNotEmpty
            ? _clientPhoneController.text
            : 'Not provided',
        'company': _clientCompanyController.text.isNotEmpty
            ? _clientCompanyController.text
            : 'Not provided',
        'app_name': _appNameController.text,
        'app_type': _selectedAppType ?? 'Not specified',
        'app_description': _appDescriptionController.text,
        'app_features': _appFeaturesController.text.isNotEmpty
            ? _appFeaturesController.text
            : 'Not specified',
        'target_platforms': _selectedPlatforms.join(', '),
        'priority': _selectedPriority ?? 'Not specified',
        'budget': _budgetController.text.isNotEmpty
            ? _budgetController.text
            : 'Not specified',
        'timeline': _timelineController.text.isNotEmpty
            ? _timelineController.text
            : 'Not specified',
        'additional_notes': _additionalNotesController.text.isNotEmpty
            ? _additionalNotesController.text
            : 'None',
        'design_style': _selectedDesignStyle ?? 'Not specified',
        'design_complexity': _selectedDesignComplexity ?? 'Not specified',
        'color_scheme': _colorSchemeController.text.isNotEmpty
            ? _colorSchemeController.text
            : 'Not specified',
        'design_inspiration': _designInspirationController.text.isNotEmpty
            ? _designInspirationController.text
            : 'Not specified',
        'brand_guidelines': _brandGuidelinesController.text.isNotEmpty
            ? _brandGuidelinesController.text
            : 'Not specified',
        'message': emailBody,
      }),
    )
        .timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception(
            'Request timeout. Please check your internet connection and try again.');
      },
    );
  }

  String _buildEmailBody() {
    final buffer = StringBuffer();
    buffer.writeln('=== NEW ORDER REQUEST ===\n');

    buffer.writeln('CLIENT INFORMATION:');
    buffer.writeln('Name: ${_clientNameController.text}');
    buffer.writeln('Email: ${_clientEmailController.text}');
    buffer.writeln(
        'Phone: ${_clientPhoneController.text.isNotEmpty ? _clientPhoneController.text : "Not provided"}');
    buffer.writeln(
        'Company: ${_clientCompanyController.text.isNotEmpty ? _clientCompanyController.text : "Not provided"}');
    buffer.writeln('');

    buffer.writeln('APP DETAILS:');
    buffer.writeln('App Name: ${_appNameController.text}');
    buffer.writeln('App Type: ${_selectedAppType ?? "Not specified"}');
    buffer.writeln('Description: ${_appDescriptionController.text}');
    buffer.writeln(
        'Features: ${_appFeaturesController.text.isNotEmpty ? _appFeaturesController.text : "Not specified"}');
    buffer.writeln('');

    buffer.writeln('TARGET PLATFORMS:');
    buffer.writeln(_selectedPlatforms.join(', '));
    buffer.writeln('');

    buffer.writeln('PROJECT DETAILS:');
    buffer.writeln('Priority: ${_selectedPriority ?? "Not specified"}');
    buffer.writeln(
        'Budget: ${_budgetController.text.isNotEmpty ? _budgetController.text : "Not specified"}');
    buffer.writeln(
        'Timeline: ${_timelineController.text.isNotEmpty ? _timelineController.text : "Not specified"}');
    buffer.writeln(
        'Additional Notes: ${_additionalNotesController.text.isNotEmpty ? _additionalNotesController.text : "None"}');
    buffer.writeln('');

    buffer.writeln('DESIGN REQUIREMENTS:');
    buffer.writeln(
        'Style Preference: ${_selectedDesignStyle ?? "Not specified"}');
    buffer.writeln(
        'Complexity Level: ${_selectedDesignComplexity ?? "Not specified"}');
    buffer.writeln(
        'Color Scheme: ${_colorSchemeController.text.isNotEmpty ? _colorSchemeController.text : "Not specified"}');
    buffer.writeln(
        'Design Inspiration: ${_designInspirationController.text.isNotEmpty ? _designInspirationController.text : "Not specified"}');
    buffer.writeln(
        'Brand Guidelines: ${_brandGuidelinesController.text.isNotEmpty ? _brandGuidelinesController.text : "Not specified"}');

    return buffer.toString();
  }

  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save text fields
      await prefs.setString(
          '${_storageKeyPrefix}clientName', _clientNameController.text);
      await prefs.setString(
          '${_storageKeyPrefix}clientEmail', _clientEmailController.text);
      await prefs.setString(
          '${_storageKeyPrefix}clientPhone', _clientPhoneController.text);
      await prefs.setString(
          '${_storageKeyPrefix}clientCompany', _clientCompanyController.text);
      await prefs.setString(
          '${_storageKeyPrefix}appName', _appNameController.text);
      await prefs.setString(
          '${_storageKeyPrefix}appDescription', _appDescriptionController.text);
      await prefs.setString(
          '${_storageKeyPrefix}appFeatures', _appFeaturesController.text);
      await prefs.setString(
          '${_storageKeyPrefix}budget', _budgetController.text);
      await prefs.setString(
          '${_storageKeyPrefix}timeline', _timelineController.text);
      await prefs.setString('${_storageKeyPrefix}additionalNotes',
          _additionalNotesController.text);
      await prefs.setString(
          '${_storageKeyPrefix}colorScheme', _colorSchemeController.text);
      await prefs.setString('${_storageKeyPrefix}designInspiration',
          _designInspirationController.text);
      await prefs.setString('${_storageKeyPrefix}brandGuidelines',
          _brandGuidelinesController.text);

      // Save dropdown values
      await prefs.setString(
          '${_storageKeyPrefix}appType', _selectedAppType ?? '');
      await prefs.setString(
          '${_storageKeyPrefix}priority', _selectedPriority ?? '');
      await prefs.setString(
          '${_storageKeyPrefix}designStyle', _selectedDesignStyle ?? '');
      await prefs.setString('${_storageKeyPrefix}designComplexity',
          _selectedDesignComplexity ?? '');

      // Save selected platforms
      await prefs.setStringList(
          '${_storageKeyPrefix}platforms', _selectedPlatforms.toList());
    } catch (e) {
      // Silently fail - form data saving is not critical
      debugPrint('Error saving form data: $e');
    }
  }

  Future<void> _loadSavedFormData() async {
    if (_isDataLoaded) return; // Prevent multiple loads

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load text fields
      _clientNameController.text =
          prefs.getString('${_storageKeyPrefix}clientName') ?? '';
      _clientEmailController.text =
          prefs.getString('${_storageKeyPrefix}clientEmail') ?? '';
      _clientPhoneController.text =
          prefs.getString('${_storageKeyPrefix}clientPhone') ?? '';
      _clientCompanyController.text =
          prefs.getString('${_storageKeyPrefix}clientCompany') ?? '';
      _appNameController.text =
          prefs.getString('${_storageKeyPrefix}appName') ?? '';
      _appDescriptionController.text =
          prefs.getString('${_storageKeyPrefix}appDescription') ?? '';
      _appFeaturesController.text =
          prefs.getString('${_storageKeyPrefix}appFeatures') ?? '';
      _budgetController.text =
          prefs.getString('${_storageKeyPrefix}budget') ?? '';
      _timelineController.text =
          prefs.getString('${_storageKeyPrefix}timeline') ?? '';
      _additionalNotesController.text =
          prefs.getString('${_storageKeyPrefix}additionalNotes') ?? '';
      _colorSchemeController.text =
          prefs.getString('${_storageKeyPrefix}colorScheme') ?? '';
      _designInspirationController.text =
          prefs.getString('${_storageKeyPrefix}designInspiration') ?? '';
      _brandGuidelinesController.text =
          prefs.getString('${_storageKeyPrefix}brandGuidelines') ?? '';

      // Load dropdown values
      final appType = prefs.getString('${_storageKeyPrefix}appType');
      if (appType != null && appType.isNotEmpty) {
        _selectedAppType = appType;
      }
      final priority = prefs.getString('${_storageKeyPrefix}priority');
      if (priority != null && priority.isNotEmpty) {
        _selectedPriority = priority;
      }
      final designStyle = prefs.getString('${_storageKeyPrefix}designStyle');
      if (designStyle != null && designStyle.isNotEmpty) {
        _selectedDesignStyle = designStyle;
      }
      final designComplexity =
          prefs.getString('${_storageKeyPrefix}designComplexity');
      if (designComplexity != null && designComplexity.isNotEmpty) {
        _selectedDesignComplexity = designComplexity;
      }

      // Load selected platforms
      final platforms = prefs.getStringList('${_storageKeyPrefix}platforms');
      if (platforms != null && platforms.isNotEmpty) {
        _selectedPlatforms = platforms.toSet();
      }

      _isDataLoaded = true;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Silently fail - form data loading is not critical
      debugPrint('Error loading form data: $e');
      _isDataLoaded = true;
    }
  }

  Future<void> _clearSavedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all form data keys
      await prefs.remove('${_storageKeyPrefix}clientName');
      await prefs.remove('${_storageKeyPrefix}clientEmail');
      await prefs.remove('${_storageKeyPrefix}clientPhone');
      await prefs.remove('${_storageKeyPrefix}clientCompany');
      await prefs.remove('${_storageKeyPrefix}appName');
      await prefs.remove('${_storageKeyPrefix}appDescription');
      await prefs.remove('${_storageKeyPrefix}appFeatures');
      await prefs.remove('${_storageKeyPrefix}budget');
      await prefs.remove('${_storageKeyPrefix}timeline');
      await prefs.remove('${_storageKeyPrefix}additionalNotes');
      await prefs.remove('${_storageKeyPrefix}colorScheme');
      await prefs.remove('${_storageKeyPrefix}designInspiration');
      await prefs.remove('${_storageKeyPrefix}brandGuidelines');
      await prefs.remove('${_storageKeyPrefix}appType');
      await prefs.remove('${_storageKeyPrefix}priority');
      await prefs.remove('${_storageKeyPrefix}designStyle');
      await prefs.remove('${_storageKeyPrefix}designComplexity');
      await prefs.remove('${_storageKeyPrefix}platforms');
    } catch (e) {
      debugPrint('Error clearing form data: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff020923),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
              SizedBox(width: 2.w),
              Text(
                'Order Submitted!',
                style: GoogleFonts.albertSans(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Thank you for your order. We have received your request and will contact you soon.',
            style: GoogleFonts.albertSans(
              color: ColorManager.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset form
                _formKey.currentState!.reset();
                _selectedPlatforms.clear();
                _selectedAppType = null;
                _selectedPriority = null;
                _selectedDesignStyle = null;
                _selectedDesignComplexity = null;
                // Clear controllers
                _clientNameController.clear();
                _clientEmailController.clear();
                _clientPhoneController.clear();
                _clientCompanyController.clear();
                _appNameController.clear();
                _appDescriptionController.clear();
                _appFeaturesController.clear();
                _budgetController.clear();
                _timelineController.clear();
                _additionalNotesController.clear();
                _colorSchemeController.clear();
                _designInspirationController.clear();
                _brandGuidelinesController.clear();
              },
              child: Text(
                'OK',
                style: GoogleFonts.albertSans(
                  color: ColorManager.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff020923),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24.sp),
              SizedBox(width: 2.w),
              Text(
                'Error',
                style: GoogleFonts.albertSans(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.albertSans(
                  color: ColorManager.white,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: ColorManager.blue, size: 16.sp),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      'Your form data has been saved. You can try again without retyping.',
                      style: GoogleFonts.albertSans(
                        color: ColorManager.blue.withValues(alpha: 0.9),
                        fontSize: isMobile ? 9.sp : 4.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.albertSans(
                  color: ColorManager.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = true,
    int maxLines = 1,
    bool isMobile = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 0.4.h : 0.5.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1F35).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.albertSans(
            color: ColorManager.white,
            fontSize: isMobile ? 10.sp : 5.sp,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: GoogleFonts.albertSans(
              color: ColorManager.white.withValues(alpha: 0.8),
              fontSize: isMobile ? 9.sp : 4.5.sp,
            ),
            hintStyle: GoogleFonts.albertSans(
              color: ColorManager.white.withValues(alpha: 0.5),
              fontSize: isMobile ? 9.sp : 4.5.sp,
            ),
            fillColor: const Color(0xFF0F1F35).withValues(alpha: 0.55),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorManager.blue.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorManager.blue.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorManager.blue,
                width: 2,
              ),
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $label';
                  }
                  return null;
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = true,
    bool isMobile = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 0.4.h : 0.5.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1F35).withValues(alpha: 0.6),
              const Color(0xFF1A2F4A).withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorManager.blue.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.blue.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.albertSans(
              color: ColorManager.white.withValues(alpha: 0.8),
              fontSize: isMobile ? 9.sp : 4.5.sp,
            ),
            fillColor: const Color(0xFF0F1F35).withValues(alpha: 0.55),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorManager.blue.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorManager.blue.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorManager.blue,
                width: 2,
              ),
            ),
          ),
          dropdownColor: const Color(0xFF0F1F35),
          style: GoogleFonts.albertSans(
            color: ColorManager.white,
            fontSize: isMobile ? 10.sp : 5.sp,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.albertSans(
                  color: ColorManager.white,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select $label';
                  }
                  return null;
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildPlatformCheckboxes() {
    final platforms = [
      {'name': 'iOS', 'icon': Icons.phone_iphone},
      {'name': 'Android', 'icon': Icons.android},
      {'name': 'Web', 'icon': Icons.language},
      {'name': 'Windows', 'icon': Icons.desktop_windows},
      {'name': 'macOS', 'icon': Icons.laptop_mac},
      {'name': 'Linux', 'icon': Icons.computer},
    ];

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1F35).withValues(alpha: 0.7),
            const Color(0xFF1A2F4A).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorManager.blue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.blue.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 1.h : 0.6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Platforms *',
            style: GoogleFonts.albertSans(
              color: ColorManager.white,
              fontSize: isMobile ? 9.sp : 4.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 0.8.h : 0.4.h),
          Wrap(
            spacing: isMobile ? 1.w : 0.6.w,
            runSpacing: isMobile ? 0.6.h : 0.3.h,
            children: platforms.map((platform) {
              final isSelected = _selectedPlatforms.contains(platform['name']);
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      platform['icon'] as IconData,
                      size: isMobile ? 14.sp : 9.sp,
                      color: isSelected ? Colors.white : ColorManager.white,
                    ),
                    SizedBox(width: isMobile ? 0.4.w : 0.25.w),
                    Text(
                      platform['name'] as String,
                      style: GoogleFonts.albertSans(
                        color: isSelected ? Colors.white : ColorManager.white,
                        fontSize: isMobile ? 9.sp : 4.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPlatforms.add(platform['name'] as String);
                    } else {
                      _selectedPlatforms.remove(platform['name'] as String);
                    }
                  });
                },
                backgroundColor: const Color(0xFF0F1F35).withValues(alpha: 0.6),
                selectedColor: ColorManager.blue.withValues(alpha: 0.7),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? ColorManager.blue
                      : ColorManager.blue.withValues(alpha: 0.5),
                  width: isMobile ? 1.5 : 0.8,
                ),
                labelPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 1.w : 0.5.w,
                  vertical: isMobile ? 0.4.h : 0.2.h,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    bool isMobile = false,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 1.h : 1.2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(isMobile ? 0.6.h : 0.5.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.orange.withValues(alpha: 0.3),
                        ColorManager.orange.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: ColorManager.orange,
                    size: isMobile ? 14.sp : 12.sp,
                  ),
                ),
                SizedBox(width: 1.w),
              ],
              Text(
                title,
                style: GoogleFonts.albertSans(
                  color: ColorManager.orange,
                  fontSize: isMobile ? 14.sp : 7.sp,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: ColorManager.orange.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 0.8.h : 0.8.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFancyDesignSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1F35).withValues(alpha: 0.7),
              const Color(0xFF1A2F4A).withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorManager.orange.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.orange.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 1.5.h : 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 0.8.h : 1.h),
                  decoration: BoxDecoration(
                    color: ColorManager.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: ColorManager.orange,
                    size: isMobile ? 16.sp : 14.sp,
                  ),
                ),
                SizedBox(width: 1.5.w),
                Text(
                  'Design Requirements',
                  style: GoogleFonts.albertSans(
                    color: ColorManager.orange,
                    fontSize: isMobile ? 14.sp : 6.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 1.2.h : 1.h),

            // Design Style Preference with icons
            Container(
              padding: EdgeInsets.all(isMobile ? 1.h : 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1F35).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.style,
                        color: ColorManager.blue,
                        size: isMobile ? 14.sp : 8.sp,
                      ),
                      SizedBox(width: 0.8.w),
                      Text(
                        'Design Style Preference',
                        style: GoogleFonts.albertSans(
                          color: ColorManager.white,
                          fontSize: isMobile ? 10.sp : 5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 0.8.h : 0.6.h),
                  _buildDropdown(
                    label: '',
                    items: [
                      'Modern & Minimalist',
                      'Bold & Colorful',
                      'Professional & Corporate',
                      'Playful & Creative',
                      'Custom/Other',
                    ],
                    value: _selectedDesignStyle,
                    onChanged: (value) {
                      setState(() {
                        _selectedDesignStyle = value;
                      });
                    },
                    isRequired: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 1.h : 0.8.h),

            // Design Complexity Level
            Container(
              padding: EdgeInsets.all(isMobile ? 1.h : 1.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F1F35).withValues(alpha: 0.5),
                    const Color(0xFF1A2F4A).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.blue.withValues(alpha: 0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.layers,
                        color: ColorManager.blue,
                        size: isMobile ? 14.sp : 8.sp,
                      ),
                      SizedBox(width: 0.8.w),
                      Text(
                        'Design Complexity Level',
                        style: GoogleFonts.albertSans(
                          color: ColorManager.white,
                          fontSize: isMobile ? 10.sp : 5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 0.8.h : 0.6.h),
                  _buildDropdown(
                    label: '',
                    items: [
                      'Simple',
                      'Moderate',
                      'Complex',
                      'Very Complex',
                    ],
                    value: _selectedDesignComplexity,
                    onChanged: (value) {
                      setState(() {
                        _selectedDesignComplexity = value;
                      });
                    },
                    isRequired: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 1.h : 0.8.h),

            // Color Scheme
            Container(
              padding: EdgeInsets.all(isMobile ? 1.h : 1.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F1F35).withValues(alpha: 0.5),
                    const Color(0xFF1A2F4A).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.blue.withValues(alpha: 0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.color_lens,
                        color: ColorManager.blue,
                        size: isMobile ? 14.sp : 8.sp,
                      ),
                      SizedBox(width: 0.8.w),
                      Text(
                        'Color Scheme / Brand Colors',
                        style: GoogleFonts.albertSans(
                          color: ColorManager.white,
                          fontSize: isMobile ? 10.sp : 5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 0.8.h : 0.6.h),
                  _buildTextField(
                    label: '',
                    hint:
                        'Describe your preferred color palette or brand colors',
                    controller: _colorSchemeController,
                    maxLines: 2,
                    isRequired: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 1.h : 0.8.h),

            // Design Inspiration
            Container(
              padding: EdgeInsets.all(isMobile ? 1.h : 1.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F1F35).withValues(alpha: 0.5),
                    const Color(0xFF1A2F4A).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.blue.withValues(alpha: 0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: ColorManager.blue,
                        size: isMobile ? 14.sp : 8.sp,
                      ),
                      SizedBox(width: 0.8.w),
                      Text(
                        'Design Inspiration / References',
                        style: GoogleFonts.albertSans(
                          color: ColorManager.white,
                          fontSize: isMobile ? 10.sp : 5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 0.8.h : 0.6.h),
                  _buildTextField(
                    label: '',
                    hint:
                        'Links to apps or websites you like, or describe your vision',
                    controller: _designInspirationController,
                    maxLines: 3,
                    isRequired: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 1.h : 0.8.h),

            // Brand Guidelines
            Container(
              padding: EdgeInsets.all(isMobile ? 1.h : 1.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F1F35).withValues(alpha: 0.5),
                    const Color(0xFF1A2F4A).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.blue.withValues(alpha: 0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_special,
                        color: ColorManager.blue,
                        size: isMobile ? 14.sp : 8.sp,
                      ),
                      SizedBox(width: 0.8.w),
                      Text(
                        'Brand Guidelines / Assets',
                        style: GoogleFonts.albertSans(
                          color: ColorManager.white,
                          fontSize: isMobile ? 10.sp : 5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 0.8.h : 0.6.h),
                  _buildTextField(
                    label: '',
                    hint:
                        'Do you have a logo, brand guidelines, or design assets?',
                    controller: _brandGuidelinesController,
                    maxLines: 3,
                    isRequired: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: ColorManager.blue,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Order Here',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 4.w : 8.w,
                vertical: isMobile ? 1.h : 1.2.h,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Information
                        _buildSection(
                          title: 'Client Information',
                          children: [
                            _buildTextField(
                              label: 'Full Name *',
                              hint: 'Enter your full name',
                              controller: _clientNameController,
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Email *',
                              hint: 'your.email@example.com',
                              controller: _clientEmailController,
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Phone Number',
                              hint: '+1 (555) 123-4567',
                              controller: _clientPhoneController,
                              isRequired: false,
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Company/Organization',
                              hint: 'Your company name (optional)',
                              controller: _clientCompanyController,
                              isRequired: false,
                              isMobile: isMobile,
                            ),
                          ],
                          isMobile: isMobile,
                        ),

                        // App Details
                        _buildSection(
                          title: 'App Details',
                          icon: Icons.apps,
                          children: [
                            _buildTextField(
                              label: 'App Name *',
                              hint: 'Enter your app name',
                              controller: _appNameController,
                              isMobile: isMobile,
                            ),
                            _buildDropdown(
                              label: 'App Type *',
                              items: [
                                'Mobile App',
                                'Web App',
                                'Desktop App',
                                'Cross-Platform App',
                                'Progressive Web App (PWA)',
                                'Other',
                              ],
                              value: _selectedAppType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAppType = value;
                                });
                              },
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'App Description *',
                              hint: 'Describe what your app does',
                              controller: _appDescriptionController,
                              maxLines: 4,
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Key Features',
                              hint:
                                  'List main features (e.g., User authentication, Payment processing, etc.)',
                              controller: _appFeaturesController,
                              maxLines: 4,
                              isRequired: false,
                              isMobile: isMobile,
                            ),
                          ],
                          isMobile: isMobile,
                        ),

                        // Target Platforms
                        _buildSection(
                          title: 'Target Platforms',
                          icon: Icons.devices,
                          children: [
                            _buildPlatformCheckboxes(),
                          ],
                          isMobile: isMobile,
                        ),

                        // Project Details
                        _buildSection(
                          title: 'Project Details',
                          icon: Icons.assignment,
                          children: [
                            _buildDropdown(
                              label: 'Project Priority *',
                              items: [
                                'Low',
                                'Medium',
                                'High',
                                'Urgent',
                              ],
                              value: _selectedPriority,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value;
                                });
                              },
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Budget Range',
                              hint: r'e.g., $5,000 - $10,000 or Flexible',
                              controller: _budgetController,
                              isRequired: false,
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Timeline',
                              hint: 'e.g., 3 months, ASAP, Flexible',
                              controller: _timelineController,
                              isRequired: false,
                              isMobile: isMobile,
                            ),
                            _buildTextField(
                              label: 'Additional Notes',
                              hint:
                                  'Any other information you\'d like to share',
                              controller: _additionalNotesController,
                              maxLines: 4,
                              isRequired: false,
                              isMobile: isMobile,
                            ),
                          ],
                          isMobile: isMobile,
                        ),

                        // Design Requirements
                        _buildFancyDesignSection(isMobile),

                        SizedBox(height: 3.h),

                        // Submit Button
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorManager.blue,
                                  ColorManager.blue.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      ColorManager.blue.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8.w : 6.w,
                                  vertical: isMobile ? 2.h : 1.5.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.transparent,
                              ),
                              child: _isSubmitting
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: isMobile ? 16.sp : 14.sp,
                                          height: isMobile ? 16.sp : 14.sp,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Submitting...',
                                          style: GoogleFonts.albertSans(
                                            color: Colors.white,
                                            fontSize: isMobile ? 14.sp : 7.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: isMobile ? 16.sp : 14.sp,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'Submit Order',
                                          style: GoogleFonts.albertSans(
                                            color: Colors.white,
                                            fontSize: isMobile ? 14.sp : 7.sp,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),
                      ],
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

  void _showSignUpRequiredDialog() {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4B556E).withValues(alpha: 0.95),
                  const Color(0xFF2D3748).withValues(alpha: 0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: ColorManager.orange,
                ),
                SizedBox(height: isMobile ? 16 : 20),
                Text(
                  'Sign Up Required',
                  style: GoogleFonts.albertSans(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'You need to sign up first to place an order. Please create an account to continue.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isMobile ? 15 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 24 : 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 24,
                          vertical: isMobile ? 12 : 14,
                        ),
                        backgroundColor:
                            ColorManager.blue.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: ColorManager.blue,
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? 120 : 140,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isMobile ? 14 : 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
