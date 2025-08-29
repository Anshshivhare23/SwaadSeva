import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../utils/validation_utils.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String userType;
  final String serviceType;
  
  const LoginScreen({
    super.key,
    required this.userType,
    required this.serviceType,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _obscurePassword = true;

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
    _passwordController.dispose();
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
        return Icons.person;
      case AppConstants.userTypeCook:
        return Icons.restaurant_menu;
      case AppConstants.userTypeDelivery:
        return Icons.delivery_dining;
      case AppConstants.userTypeAdmin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: widget.userType,
        serviceType: widget.serviceType,
      );

      if (success && mounted) {
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
              authService.errorMessage ?? 'Login failed',
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
                          tag: 'user_type_${widget.userType}',
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
                          'Welcome Back!',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Login as $_userTypeDisplayName',
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
                  
                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                        
                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
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
                        
                        const SizedBox(height: 16),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(
                                    userType: widget.userType,
                                    serviceType: widget.serviceType,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _userTypeColor,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Login Button
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return CustomButton(
                              text: 'Login',
                              onPressed: _login,
                              isLoading: authService.isLoading,
                              color: _userTypeColor,
                              icon: Icons.login,
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
                        
                        // Register Button
                        CustomButton(
                          text: 'Create New Account',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(
                                  userType: widget.userType,
                                  serviceType: widget.serviceType,
                                ),
                              ),
                            );
                          },
                          isOutlined: true,
                          color: _userTypeColor,
                          icon: Icons.person_add,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Center(
                    child: Text(
                      'Demo: Use any email and password (min 6 chars)',
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
