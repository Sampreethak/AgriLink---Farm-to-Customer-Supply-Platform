import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../services/auth_service.dart';
import '../customer/customer_dashboard.dart';
import '../farmer/farmer_dashboard.dart';
import '../aggregator/aggregator_dashboard.dart';
import '../delivery/delivery_dashboard.dart';
import '../admin/admin_dashboard.dart';
// We'll navigate to home tab or dashboards depending on role

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String purpose; // 'login' or 'registration'

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.purpose,
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;
    if (otp.length < 6) {
      _errorController.add(ErrorAnimationType.shake);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final user = await authService.verifyOTP(
        phone: widget.phoneNumber,
        code: otp,
        purpose: widget.purpose,
      );

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
            content: Text("Invalid OTP, please try again"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _errorController.add(ErrorAnimationType.shake);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.sendOTP(phone: widget.phoneNumber, purpose: widget.purpose);
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP Resent Successfully"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to resend: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Icon(
                Icons.lock_person,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 30),
              Text(
                langProvider.translate('otp_verification'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${langProvider.translate('enter_otp')}\n+91 ${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 50,
                  fieldWidth: 45,
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
                onCompleted: (v) {
                  _verifyOtp();
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 40),
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
