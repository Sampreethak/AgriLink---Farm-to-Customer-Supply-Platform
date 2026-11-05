import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../services/auth_service.dart';
import '../../services/user_registry.dart';
import '../customer/customer_dashboard.dart';
import '../farmer/farmer_dashboard.dart';
import '../aggregator/aggregator_dashboard.dart';
import '../delivery/delivery_dashboard.dart';
import '../admin/admin_dashboard.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;
  final String purpose; // 'login' or 'registration'
  final String channel; // 'email', 'phone', or 'whatsapp'
  final int otpLength;  // 8 for Supabase email, 6 for SMS/WhatsApp

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
    this.email,
    required this.purpose,
    this.channel = 'phone',
    this.otpLength = 6,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>.broadcast();

  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _errorController.close();
    super.dispose();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < widget.otpLength) {
      _errorController.add(ErrorAnimationType.shake);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      AppUserModel? user;

      if (widget.channel == 'email') {
        user = await authService.verifyEmailOTP(
          email: widget.email ?? '',
          token: otp,
        );
      } else {
        user = await authService.verifyOTP(
          phone: widget.phoneNumber ?? '',
          code: otp,
          purpose: widget.purpose,
        );
      }

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome ${user.fullName} (${user.customerType})!"),
            backgroundColor: AppColors.success,
          ),
        );

        Widget target;
        switch (user.role.toLowerCase()) {
          case 'farmer':
            target = const FarmerDashboard();
            break;
          case 'aggregator':
            target = const AggregatorDashboard();
            break;
          case 'delivery':
            target = const DeliveryDashboard();
            break;
          case 'admin':
            target = const AdminDashboard();
            break;
          default:
            target = const CustomerDashboard();
            break;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => target),
          (route) => false,
        );
      } else if (mounted) {
        _errorController.add(ErrorAnimationType.shake);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP code. Please check and try again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _errorController.add(ErrorAnimationType.shake);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0) return;

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();

      if (widget.channel == 'email') {
        await authService.sendEmailOTP(widget.email ?? '');
      } else {
        final res = await authService.sendOTP(
          phone: widget.phoneNumber ?? '',
          purpose: widget.purpose,
          channel: widget.channel,
        );
        if (res['isSimulated'] == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Dev Testing OTP: ${res['otp']}"),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }

      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New OTP sent successfully!"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to resend: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getChannelIcon() {
    switch (widget.channel) {
      case 'email':
        return Icons.mark_email_read;
      case 'whatsapp':
        return Icons.chat_bubble_outline;
      case 'phone':
      default:
        return Icons.sms_outlined;
    }
  }

  String _getSubtitleText(LanguageProvider lang) {
    if (widget.channel == 'email') {
      return "Enter the ${widget.otpLength}-digit verification code sent to:\n${widget.email}";
    } else if (widget.channel == 'whatsapp') {
      return "Enter the ${widget.otpLength}-digit code sent via WhatsApp to:\n+91 ${widget.phoneNumber}";
    } else {
      return "${lang.translate('enter_otp')}\n+91 ${widget.phoneNumber}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isEightDigit = widget.otpLength == 8;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(langProvider.translate('otp_verification')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                _getChannelIcon(),
                size: 75,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 20),
              Text(
                langProvider.translate('otp_verification'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getSubtitleText(langProvider),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 35),

              // Pin code input field (adapts width for 6 or 8 digits)
              PinCodeTextField(
                appContext: context,
                length: widget.otpLength,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: isEightDigit ? 46 : 50,
                  fieldWidth: isEightDigit ? 34 : 45,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: AppColors.greyLight,
                  activeColor: AppColors.primaryGreen,
                  selectedColor: AppColors.accent,
                  inactiveColor: AppColors.border,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                errorAnimationController: _errorController,
                controller: _otpController,
                keyboardType: TextInputType.number,
                onCompleted: (_) => _verifyOtp(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 20),

              // Resend Countdown Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0
                        ? "Resend OTP in $_secondsRemaining s"
                        : "Didn't receive code? ",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (_secondsRemaining == 0)
                    TextButton(
                      onPressed: _isLoading ? null : _resendOtp,
                      child: Text(
                        langProvider.translate('resend_otp'),
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 35),

              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        langProvider.translate('verify'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
