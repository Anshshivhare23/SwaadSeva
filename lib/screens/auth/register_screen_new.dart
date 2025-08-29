import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../utils/validation_utils.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';
import '../home/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String userType;
  final String serviceType;
  
  const RegisterScreen({
    super.key,
    required this.userType,
    required this.serviceType,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _userTypeDisplayName {
    switch (widget.userType) {
      case AppConstants.userTypeCustomer:
        return AppStrings.customer;
      case AppConstants.userTypeCook:
        return AppStrings.homeCook;
      case AppConstants.userTypeDelivery:
        return AppStrings.deliveryBoy;
      case AppConstants.userTypeAdmin:
        return AppStrings.admin;
      default:
        return 'User';
    }
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

  IconData get _userTypeIcon {
    switch (widget.userType) {
      case AppConstants.userTypeCustomer:
        return Icons.person_add;
      case AppConstants.userTypeCook:
        return Icons.restaurant_menu;
      case AppConstants.userTypeDelivery:
        return Icons.delivery_dining;
      case AppConstants.userTypeAdmin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person_add;
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please agree to the Terms and Conditions',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.warningColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      HapticFeedback.lightImpact();
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: ValidationUtils.formatPhoneNumber(_phoneController.text.trim()),
        userType: widget.userType,
        serviceType: widget.serviceType,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Welcome to SwaadSeva!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authService.errorMessage ?? 'Registration failed',
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
                        // User Type Icon
                        Hero(
                          tag: 'user_type_register_${widget.userType}',
                          child: Container(
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
                              _userTypeIcon,
                              size: 40,
                              color: _userTypeColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Join as $_userTypeDisplayName',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _userTypeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _userTypeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            widget.serviceType.replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _userTypeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Registration Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          validator: ValidationUtils.validateName,
                          borderColor: _userTypeColor,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: _userTypeColor,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Email Field
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
                        
                        const SizedBox(height: 20),
                        
                        // Phone Field
                        CustomTextField(
                          label: 'Phone Number',
                          hint: 'Enter your 10-digit phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: ValidationUtils.validatePhone,
                          borderColor: _userTypeColor,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: _userTypeColor,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          hint: 'Create a strong password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: ValidationUtils.validatePassword,
                          borderColor: _userTypeColor,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _userTypeColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: _userTypeColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Confirm Password Field
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) => ValidationUtils.validateConfirmPassword(
                            value, 
                            _passwordController.text,
                          ),
                          borderColor: _userTypeColor,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _userTypeColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: _userTypeColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Terms and Conditions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: _userTypeColor,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppConstants.textSecondary,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: GoogleFonts.poppins(
                                          color: _userTypeColor,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: GoogleFonts.poppins(
                                          color: _userTypeColor,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Register Button
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return CustomButton(
                              text: 'Create Account',
                              onPressed: _register,
                              isLoading: authService.isLoading,
                              color: _userTypeColor,
                              icon: Icons.person_add,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppConstants.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppConstants.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppConstants.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login Button
                        CustomButton(
                          text: 'Already Have Account? Login',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                  userType: widget.userType,
                                  serviceType: widget.serviceType,
                                ),
                              ),
                            );
                          },
                          isOutlined: true,
                          color: _userTypeColor,
                          icon: Icons.login,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Center(
                    child: Text(
                      'Demo: Registration will create a test account',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppConstants.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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
