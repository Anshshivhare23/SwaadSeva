import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  final List<ServiceOption> services = [
    ServiceOption(
      type: 'tiffin_service',
      title: 'HOME-COOKED TIFFIN DELIVERY',
      subtitle: 'Ready-to-eat homemade meals',
      description: 'Order delicious homemade tiffins delivered to your doorstep',
      icon: Icons.delivery_dining,
      color: AppConstants.primaryColor,
      gradient: [
        const Color(0xFF4CAF50),
        const Color(0xFF66BB6A),
        const Color(0xFF81C784),
      ],
    ),
    ServiceOption(
      type: 'cook_service',
      title: 'COOK-ON-CALL',
      subtitle: 'Personal cook at your location',
      description: 'Book a cook to prepare fresh meals at your location',
      icon: Icons.person_2,
      color: AppConstants.secondaryColor,
      gradient: [
        const Color(0xFFFF9800),
        const Color(0xFFFFB74D),
        const Color(0xFFFFCC80),
      ],
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
      services.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.3 + (index * 0.2),
          0.8 + (index * 0.1),
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

  void _selectService(String serviceType) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(
      '/user-type-selection',
      arguments: serviceType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top spacing
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  
                  // Header section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Logo
                          Hero(
                            tag: 'app_logo',
                            child: Container(
                              width: isSmallScreen ? 70 : 80,
                              height: isSmallScreen ? 70 : 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/logo.jpeg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppConstants.primaryColor,
                                            AppConstants.secondaryColor,
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                            )),
                            child: Text(
                              'Welcome to\n${AppConstants.appName}',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 22 : 26,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
                            )),
                            child: Text(
                              'Choose your preferred service',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: AppConstants.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 25 : 35), // Reduced spacing
                  
                  // Service options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(                          children: services.asMap().entries.map((entry) {
                            int index = entry.key;
                            ServiceOption service = entry.value;
                            return SlideTransition(
                              position: _slideAnimations[index],
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: isSmallScreen ? 14 : 18, // Reduced spacing
                                  ),
                                  child: ServiceCard(
                                    service: service,
                                    onTap: () => _selectService(service.type),
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 15 : 25), // Reduced spacing
                  
                  // Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Ghar ka Khana, Sirf Ek Click Mein!',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppConstants.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 15 : 25), // Reduced final spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceOption service;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
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
    final cardHeight = widget.isSmallScreen ? 170.0 : 190.0; // Increased height
    final iconSize = widget.isSmallScreen ? 50.0 : 60.0;
    final titleFontSize = widget.isSmallScreen ? 15.0 : 17.0; // Slightly smaller
    final subtitleFontSize = widget.isSmallScreen ? 12.0 : 13.0; // Slightly smaller
    final descriptionFontSize = widget.isSmallScreen ? 10.0 : 11.0; // Slightly smaller
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) {
        _hoverController.forward();
      },
      onTapUp: (_) {
        _hoverController.reverse();
      },
      onTapCancel: () {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: cardHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.service.gradient,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.service.color.withValues(alpha: 0.3),
                    blurRadius: _elevationAnimation.value,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: widget.service.color.withValues(alpha: 0.1),
                    blurRadius: _elevationAnimation.value * 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern with animation
                  AnimatedPositioned(
                    duration: Duration(milliseconds: _hoverController.isAnimating ? 200 : 0),
                    right: _hoverController.value > 0.5 ? -25 : -30,
                    top: _hoverController.value > 0.5 ? -25 : -30,
                    child: Container(
                      width: widget.isSmallScreen ? 100 : 120,
                      height: widget.isSmallScreen ? 100 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: EdgeInsets.all(widget.isSmallScreen ? 18.0 : 22.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            widget.service.icon,
                            size: widget.isSmallScreen ? 25 : 30,
                            color: Colors.white,
                          ),
                        ),
                        
                        SizedBox(height: widget.isSmallScreen ? 10 : 14), // Reduced spacing
                        
                        // Title
                        Text(
                          widget.service.title,
                          style: GoogleFonts.poppins(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0, // Tighter line height
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: widget.isSmallScreen ? 4 : 6), // Reduced spacing
                        
                        // Subtitle
                        Text(
                          widget.service.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: subtitleFontSize,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                            height: 1.2, // Controlled line height
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: widget.isSmallScreen ? 6 : 10), // Reduced spacing
                        
                        // Description with flexible space
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.service.description,
                              style: GoogleFonts.poppins(
                                fontSize: descriptionFontSize,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.3,
                              ),
                              maxLines: widget.isSmallScreen ? 2 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                        // Bottom spacing to account for arrow
                        SizedBox(height: widget.isSmallScreen ? 8 : 12),
                      ],
                    ),
                  ),
                  
                  // Arrow indicator
                  Positioned(
                    bottom: widget.isSmallScreen ? 10 : 14,
                    right: widget.isSmallScreen ? 10 : 14,
                    child: Container(
                      width: widget.isSmallScreen ? 32 : 36,
                      height: widget.isSmallScreen ? 32 : 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          widget.isSmallScreen ? 16 : 18,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: widget.isSmallScreen ? 16 : 18,
                      ),
                    ),
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

class ServiceOption {
  final String type;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  ServiceOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
