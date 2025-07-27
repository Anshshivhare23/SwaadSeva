import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import 'login_screen.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;

  final List<UserTypeOption> userTypes = [
    UserTypeOption(
      type: AppConstants.userTypeCustomer,
      title: AppStrings.customer,
      subtitle: 'Order delicious homemade food',
      icon: Icons.person,
      color: AppConstants.primaryColor,
      description: 'Browse nearby home cooks, order fresh meals, and enjoy ghar ka khana delivered to your doorstep.',
    ),
    UserTypeOption(
      type: AppConstants.userTypeCook,
      title: AppStrings.homeCook,
      subtitle: 'Share your cooking skills',
      icon: Icons.restaurant_menu,
      color: AppConstants.secondaryColor,
      description: 'Cook from home, list your daily menu, and earn money by serving delicious homemade meals.',
    ),
    UserTypeOption(
      type: AppConstants.userTypeDelivery,
      title: AppStrings.deliveryBoy,
      subtitle: 'Deliver food and earn',
      icon: Icons.delivery_dining,
      color: AppConstants.accentColor,
      description: 'Join our delivery network, pick up orders from home cooks, and deliver to hungry customers.',
    ),
    UserTypeOption(
      type: AppConstants.userTypeAdmin,
      title: AppStrings.admin,
      subtitle: 'Manage the platform',
      icon: Icons.admin_panel_settings,
      color: Colors.purple,
      description: 'Admin access to manage users, monitor operations, and maintain platform quality.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));
    
    _slideAnimations = List.generate(
      userTypes.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.2 + (index * 0.1),
          0.7 + (index * 0.1),
          curve: Curves.easeOutBack,
        ),
      )),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Welcome to ${AppConstants.appName}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Choose how you want to join our community',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppConstants.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // User Type Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                itemCount: userTypes.length,
                itemBuilder: (context, index) {
                  final userType = userTypes[index];
                  return SlideTransition(
                    position: _slideAnimations[index],
                    child: UserTypeCard(
                      userType: userType,
                      onTap: () => _selectUserType(userType.type),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectUserType(String userType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(userType: userType),
      ),
    );
  }
}

class UserTypeOption {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;

  UserTypeOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class UserTypeCard extends StatefulWidget {
  final UserTypeOption userType;
  final VoidCallback onTap;

  const UserTypeCard({
    super.key,
    required this.userType,
    required this.onTap,
  });

  @override
  State<UserTypeCard> createState() => _UserTypeCardState();
}

class _UserTypeCardState extends State<UserTypeCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: widget.userType.color.withValues(alpha: _isHovered ? 0.3 : 0.1),
                    blurRadius: _isHovered ? 15 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: widget.userType.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.userType.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      widget.userType.icon,
                      size: 30,
                      color: widget.userType.color,
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.defaultPadding),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userType.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          widget.userType.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          widget.userType.description,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: widget.userType.color,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
