import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../utils/validation_utils.dart';
import '../../services/firebase_auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;
  final String serviceType;

  const ForgotPasswordScreen({
    super.key,
    required this.userType,
    required this.serviceType,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Color get _userTypeColor {
    switch (widget.userType) {
      case AppConstants.userTypeCustomer:
        return AppConstants.primaryColor;
      case AppConstants.userTypeCook:
        return AppConstants.secondaryColor;
      case AppConstants.userTypeDelivery:
        return AppConstants.accentColor;
      case AppConstants.userTypeAdmin:
        return Colors.purple;
      default:
        return AppConstants.primaryColor;
    }
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      final success = await authService.resetPassword(email: _emailController.text.trim());
      
      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to ${_emailController.text}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authService.errorMessage ?? 'Failed to send reset email',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: _userTypeColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _userTypeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _userTypeColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _emailSent ? Icons.email_outlined : Icons.lock_reset,
                            size: 40,
                            color: _userTypeColor,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          _emailSent ? 'Check Your Email' : 'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _emailSent 
                                ? 'We\'ve sent password reset instructions to ${_emailController.text}'
                                : 'Enter your email address and we\'ll send you instructions to reset your password',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppConstants.textSecondary,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  if (!_emailSent) ...[
                    // Reset Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'Email Address',
                            hint: 'Enter your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidationUtils.validateEmail,
                            borderColor: _userTypeColor,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: _userTypeColor,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Consumer<FirebaseAuthService>(
                            builder: (context, authService, child) {
                              return CustomButton(
                                text: 'Send Reset Email',
                                onPressed: _sendResetEmail,
                                isLoading: authService.isLoading,
                                color: _userTypeColor,
                                icon: Icons.send,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Success state
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppConstants.successColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.mark_email_read,
                                size: 48,
                                color: AppConstants.successColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Email Sent Successfully!',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.successColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check your inbox and follow the instructions to reset your password.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppConstants.textSecondary,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        CustomButton(
                          text: 'Back to Login',
                          onPressed: () => Navigator.of(context).pop(),
                          color: _userTypeColor,
                          icon: Icons.arrow_back,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomButton(
                          text: 'Resend Email',
                          onPressed: () {
                            setState(() {
                              _emailSent = false;
                            });
                          },
                          isOutlined: true,
                          color: _userTypeColor,
                          icon: Icons.refresh,
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Center(
                    child: Text(
                      'Need help? Contact support',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
