import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/constants.dart';
import '../../models/food_listing_model.dart';
import '../../services/food_service.dart';
import '../../services/image_service.dart';

class FoodDiscoveryScreen extends StatefulWidget {
  const FoodDiscoveryScreen({super.key});

  @override
  State<FoodDiscoveryScreen> createState() => _FoodDiscoveryScreenState();
}

class _FoodDiscoveryScreenState extends State<FoodDiscoveryScreen>
    with TickerProviderStateMixin {
  final FoodService _foodService = FoodService();
  final ImageService _imageService = ImageService();
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Stream<List<FoodListing>>? _foodListingsStream;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = ['All', 'Available Now', 'Nearby', 'Rated 4+'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFoodListings();
  }

  void _setupAnimations() {
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
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _loadFoodListings() {
    if (_searchQuery.isEmpty) {
      _foodListingsStream = _foodService.getAvailableFoodListings();
    } else {
      _foodListingsStream = _foodService.searchFoodListings(_searchQuery);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Discover Food',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppConstants.primaryColor,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppConstants.primaryColor),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement location/filter options
          },
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchSection(),
        _buildFilterChips(),
        Expanded(child: _buildFoodList()),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for food, restaurants...',
            hintStyle: GoogleFonts.poppins(color: AppConstants.textSecondary),
            prefixIcon: const Icon(Icons.search, color: AppConstants.primaryColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear, color: AppConstants.textSecondary),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: _onSearchChanged,
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = filter == _selectedFilter;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppConstants.primaryColor,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => _onFilterChanged(filter),
              backgroundColor: Colors.white,
              selectedColor: AppConstants.primaryColor,
              side: const BorderSide(color: AppConstants.primaryColor),
              elevation: isSelected ? 4 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodList() {
    return StreamBuilder<List<FoodListing>>(
      stream: _foodListingsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final listings = snapshot.data ?? [];
        
        if (listings.isEmpty) {
          return _buildEmptyState();
        }

        return _buildListingsGrid(listings);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppConstants.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Finding delicious food for you...',
            style: GoogleFonts.poppins(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppConstants.errorColor.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _loadFoodListings()),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppConstants.textSecondary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No food available' : 'No food found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Check back later for fresh listings!'
                : 'Try searching with different keywords',
            style: GoogleFonts.poppins(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListingsGrid(List<FoodListing> listings) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _loadFoodListings());
      },
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return _buildFoodCard(listing, index);
        },
      ),
    );
  }

  Widget _buildFoodCard(FoodListing listing, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _navigateToDetail(listing),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(listing),
                const SizedBox(height: 12),
                _buildFoodItems(listing),
                const SizedBox(height: 12),
                _buildCardFooter(listing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(FoodListing listing) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          child: listing.cookImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: listing.cookImageUrl!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (context, url, error) => const Icon(Icons.person, color: AppConstants.primaryColor),
                )
              : const Icon(Icons.person, color: AppConstants.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.cookName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppConstants.textPrimary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: AppConstants.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.address,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppConstants.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (listing.rating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  listing.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFoodItems(FoodListing listing) {
    final availableItems = listing.items.where((item) => item.isAvailable).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...availableItems.take(3).map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Food item image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppConstants.surfaceColor,
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _imageService.getImageFromBase64(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.restaurant,
                        color: AppConstants.textSecondary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              // Food item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Price
              Text(
                '₹${item.price.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )),
        if (availableItems.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${availableItems.length - 3} more items available',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppConstants.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardFooter(FoodListing listing) {
    final now = DateTime.now();
    final timeLeft = listing.availableUntil.difference(now);
    
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: timeLeft.inHours < 2 ? AppConstants.errorColor : AppConstants.successColor,
        ),
        const SizedBox(width: 4),
        Text(
          timeLeft.inHours > 0
              ? 'Available for ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m'
              : 'Available for ${timeLeft.inMinutes}m',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: timeLeft.inHours < 2 ? AppConstants.errorColor : AppConstants.successColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (listing.specialNote.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Special',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppConstants.accentColor,
              ),
            ),
          ),
      ],
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _loadFoodListings();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      // TODO: Implement filter logic
    });
  }

  void _navigateToDetail(FoodListing listing) {
    Navigator.of(context).pushNamed(
      '/food-detail',
      arguments: listing,
    );
  }
}
