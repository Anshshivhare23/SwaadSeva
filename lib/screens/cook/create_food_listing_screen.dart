import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../models/food_listing_model.dart';
import '../../services/food_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/image_service.dart';

class CreateFoodListingScreen extends StatefulWidget {
  const CreateFoodListingScreen({super.key});

  @override
  State<CreateFoodListingScreen> createState() => _CreateFoodListingScreenState();
}

class _CreateFoodListingScreenState extends State<CreateFoodListingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _specialNoteController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FoodService _foodService = FoodService();
  final ImageService _imageService = ImageService();
  bool _isLoading = false;
  DateTime _availableFrom = DateTime.now();
  DateTime _availableUntil = DateTime.now().add(const Duration(hours: 4));
  
  // Food items list
  final List<FoodItemForm> _foodItems = [
    FoodItemForm(),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
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
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _addressController.dispose();
    _specialNoteController.dispose();
    for (var item in _foodItems) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Food Listing',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.primaryColor),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildForm(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('📍 Location & Timing'),
            const SizedBox(height: 16),
            _buildAddressField(),
            const SizedBox(height: 16),
            _buildTimingSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('🍽️ Food Items'),
            const SizedBox(height: 16),
            ..._buildFoodItemsList(),
            const SizedBox(height: 16),
            _buildAddFoodItemButton(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('📝 Additional Notes'),
            const SizedBox(height: 16),
            _buildSpecialNoteField(),
            
            const SizedBox(height: 40),
            _buildCreateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Pickup Address',
        hintText: 'Enter your complete address',
        prefixIcon: const Icon(Icons.location_on, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppConstants.textSecondary),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter pickup address';
        }
        return null;
      },
      maxLines: 2,
    );
  }

  Widget _buildTimingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.textSecondary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  'Available From',
                  _availableFrom,
                  (DateTime date) => setState(() => _availableFrom = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(
                  'Available Until',
                  _availableUntil,
                  (DateTime date) => setState(() => _availableUntil = date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(String label, DateTime value, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(value, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.textSecondary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${value.day}/${value.month} ${value.hour}:${value.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFoodItemsList() {
    return _foodItems.asMap().entries.map((entry) {
      int index = entry.key;
      FoodItemForm item = entry.value;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: _buildFoodItemCard(item, index),
      );
    }).toList();
  }

  Widget _buildFoodItemCard(FoodItemForm item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.textSecondary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Food Item ${index + 1}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
              const Spacer(),
              if (_foodItems.length > 1)
                IconButton(
                  onPressed: () => _removeFoodItem(index),
                  icon: const Icon(Icons.delete, color: AppConstants.errorColor),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Photo upload section
          _buildPhotoUploadSection(item, index),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: item.nameController,
            decoration: _inputDecoration('Food Name', 'e.g., Homemade Dal Rice'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter food name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: item.descriptionController,
            decoration: _inputDecoration('Description', 'Describe your delicious food...'),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: item.priceController,
            decoration: _inputDecoration('Price (₹)', 'e.g., 150'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter valid price';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodItemButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addFoodItem,
        icon: const Icon(Icons.add, color: AppConstants.primaryColor),
        label: Text(
          'Add Another Food Item',
          style: GoogleFonts.poppins(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppConstants.primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSpecialNoteField() {
    return TextFormField(
      controller: _specialNoteController,
      decoration: _inputDecoration(
        'Special Notes (Optional)',
        'Any special instructions, dietary info, etc.',
      ),
      maxLines: 3,
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createListing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Food Listing',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppConstants.textSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(color: AppConstants.textSecondary),
      hintStyle: GoogleFonts.poppins(color: AppConstants.textSecondary),
    );
  }

  void _addFoodItem() {
    setState(() {
      _foodItems.add(FoodItemForm());
    });
  }

  void _removeFoodItem(int index) {
    if (_foodItems.length > 1) {
      setState(() {
        _foodItems[index].dispose();
        _foodItems.removeAt(index);
      });
    }
  }

  Future<void> _selectDateTime(DateTime current, Function(DateTime) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(current),
      );

      if (time != null && mounted) {
        onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Upload images and convert food item forms to food items
      List<FoodItem> foodItems = [];
      
      for (int i = 0; i < _foodItems.length; i++) {
        final item = _foodItems[i];
        String? imageUrl;
        
        // Convert image to base64 if selected
        if (item.selectedImage != null) {
          try {
            imageUrl = await _imageService.convertImageToBase64(
              item.selectedImage!,
            );
          } catch (e) {
            // Continue without image if conversion fails
            print('Failed to convert image for item ${i + 1}: $e');
          }
        }
        
        foodItems.add(FoodItem(
          name: item.nameController.text.trim(),
          description: item.descriptionController.text.trim(),
          price: double.parse(item.priceController.text.trim()),
          imageUrl: imageUrl,
          isAvailable: true,
        ));
      }

      // Create food listing
      final listing = FoodListing(
        id: '', // Will be set by Firestore
        cookId: user.id,
        cookName: user.name,
        cookPhone: user.phone ?? '',
        address: _addressController.text.trim(),
        latitude: 0.0, // TODO: Get actual coordinates
        longitude: 0.0, // TODO: Get actual coordinates
        items: foodItems,
        specialNote: _specialNoteController.text.trim(),
        availableFrom: _availableFrom,
        availableUntil: _availableUntil,
        isActive: true,
        rating: 0.0,
        totalOrders: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _foodService.createFoodListing(listing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Food listing created successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create listing: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPhotoUploadSection(FoodItemForm item, int index) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.textSecondary,
          style: BorderStyle.solid,
        ),
      ),
      child: item.selectedImage != null
          ? Stack(
              children: [
                // Display selected image
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(item.selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removePhoto(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppConstants.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Edit button
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _selectPhoto(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: () => _selectPhoto(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: AppConstants.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add Food Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select from gallery or camera',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppConstants.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _selectPhoto(int index) async {
    try {
      final File? imageFile = await _imageService.showImageSourceDialog(context);
      if (imageFile != null) {
        setState(() {
          _foodItems[index].selectedImage = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to select image: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _foodItems[index].selectedImage = null;
      _foodItems[index].imageUrl = null;
    });
  }
}

// Helper class for food item form
class FoodItemForm {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? imageUrl;
  File? selectedImage;

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
}
