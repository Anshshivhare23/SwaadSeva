# SwaadSeva - Ghar ka Khana, Sirf Ek Click Mein! 🍛

SwaadSeva is a revolutionary food delivery app that offers **TWO AMAZING SERVICES** connecting home cooks with food lovers, bringing the authentic taste of homemade meals to your doorstep or location.

## 🌟 Our Two Service Models

### 1. 🚚 **HOME-COOKED TIFFIN DELIVERY**
Traditional tiffin delivery service where home cooks prepare meals and deliver them to customers.
- **The Problem**: College students and working professionals living away from home miss ghar ka khana.
- **The Solution**: Connect hungry souls with talented home cooks who prepare fresh tiffins delivered to your doorstep.

### 2. 👨‍🍳 **COOK-ON-CALL**
Personal cooking service where professional cooks travel to customer locations to prepare fresh meals.
- **The Problem**: Need fresh, customized meals prepared at your own location for events, parties, or daily cooking.
- **The Solution**: Book skilled cooks who come to your location and prepare fresh, personalized meals using your kitchen.

## 👥 User Types for Each Service

### 🚚 **For TIFFIN DELIVERY Service**

#### 1. 🍽️ **Customer**
- Browse available tiffins within 7 km radius
- View menus, prices, and ratings
- Place orders for fresh homemade tiffins
- Track delivery in real-time

#### 2. 👩‍🍳 **Home Cook**
- List daily tiffin menu (2 sabzi + roti + rice)
- Set availability for 4-hour windows
- Manage orders and earnings from home
- Build customer relationships

#### 3. 🛵 **Delivery Partner**
- View pickup and delivery locations
- Get directions via integrated maps
- Manage delivery schedules
- Earn money with flexible hours

#### 4. 👨‍💼 **Admin**
- Monitor all users and activities
- Approve cook registrations
- Handle complaints and feedback
- Manage platform quality

### 👨‍🍳 **For COOK-ON-CALL Service**

#### 1. 🍽️ **Customer**
- Find and book skilled cooks for events or daily cooking
- Set cooking preferences and dietary requirements
- Schedule cooking sessions at your location
- Pay for personalized cooking services

#### 2. 👩‍🍳 **Professional Cook**
- Offer cooking services for various cuisines
- Travel to customer locations with your skills
- Set availability and pricing
- Build reputation through quality service

#### 3. 👨‍💼 **Admin**
- Verify cook credentials and skills
- Manage service quality and customer satisfaction
- Handle bookings and payment disputes
- Maintain platform standards

## 🎉 **Phase 1 Completed Successfully!**

**Status**: ✅ Phase 1 is now complete and stable!

All Phase 1 issues have been resolved and **NEW DUAL SERVICE MODEL** implemented:
- ✅ Fixed MultiProvider runtime error
- ✅ Updated deprecated theme parameters
- ✅ Fixed all `withOpacity` deprecation warnings  
- ✅ Resolved lint and analysis issues
- ✅ Updated test files to match app structure
- ✅ **NEW: Added Service Selection Screen**
- ✅ **NEW: Implemented Dual Service Model (Tiffin Delivery + Cook-on-Call)**
- ✅ **NEW: Context-aware User Type Selection**
- ✅ App builds and runs without errors
- ✅ Complete navigation flow tested and working
- ✅ All screens display correctly with beautiful animations

The app is ready to move to **Phase 2: Authentication & Backend Integration**!

## 🚀 Step-by-Step Development Progress

### ✅ **Step 1: COMPLETED - Project Foundation & Dual Service Model**
- [x] Flutter project setup with proper structure
- [x] Modern UI theme with Google Fonts (Poppins)
- [x] App constants and color scheme
- [x] Data models (User, FoodListing, Order)
- [x] Animated splash screen
- [x] **NEW: Service selection screen (Tiffin Delivery vs Cook-on-Call)**
- [x] **NEW: Context-aware user type selection based on service**
- [x] Authentication screens (Login/Register) with service context
- [x] Beautiful animations and transitions
- [x] Complete navigation flow testing for both services
- [x] All Phase 1 issues resolved and app running smoothly

### 🔄 **Step 2: READY TO START - Authentication & Backend**
- [ ] Firebase integration
- [ ] User registration and login
- [ ] User profiles and verification
- [ ] Location services integration

### 📋 **Step 3: UPCOMING - Core Features**
- [ ] Food listing creation (for cooks)
- [ ] Food browsing and search (for customers)
- [ ] Order placement and management
- [ ] Real-time order tracking

### 🗺️ **Step 4: UPCOMING - Maps & Delivery**
- [ ] Google Maps integration
- [ ] Delivery partner app features
- [ ] Route optimization
- [ ] Real-time location tracking

### 👑 **Step 5: UPCOMING - Admin Panel**
- [ ] Admin dashboard
- [ ] User management
- [ ] Analytics and reporting
- [ ] Quality control features

## 🎨 Current Features (Step 1)

### Beautiful UI Components
- **Splash Screen**: Animated logo with brand colors
- **Service Selection**: Elegant cards for choosing between Tiffin Delivery and Cook-on-Call
- **User Type Selection**: Context-aware role selection based on chosen service
- **Authentication**: Modern login/register forms with service context
- **Theme**: Professional design with green (trust) and orange (warmth) colors

### Service-Specific Features
- **Tiffin Delivery**: Traditional food delivery model with customers, cooks, delivery partners, and admin
- **Cook-on-Call**: On-demand cooking service with customers, professional cooks, and admin
- **Dynamic UI**: User types and descriptions change based on selected service
- **Context Preservation**: Service type maintained throughout the user journey

### Technical Features
- **Responsive Design**: Works on all screen sizes
- **Smooth Animations**: Enhanced user experience with service-specific transitions
- **Type Safety**: Strong typing with Dart
- **Modular Architecture**: Clean, maintainable code structure
- **Dual Service Support**: Single app supporting two distinct business models

## 🛠️ Technology Stack

### Frontend (Mobile App)
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Google Fonts** - Typography (Poppins font family)
- **Provider** - State management

### Backend (Planned)
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - Image storage
- **Google Maps API** - Location services

### Design
- **Material Design 3** - UI components
- **Custom Animations** - Enhanced UX
- **Responsive Layout** - Multi-device support

## 📱 How to Run

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd SwaadSeva

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🎯 Next Steps

1. **Test Current Build**: Verify all UI components work properly
2. **Firebase Setup**: Initialize Firebase project
3. **Authentication**: Implement real login/register functionality
4. **Database Design**: Create data structure in Firestore
5. **Location Services**: Add GPS and maps functionality

## 💡 Key Features Planned

### Tiffin Delivery Service Features
- **4-Hour Window**: Food listings automatically expire after 4 hours
- **7km Radius**: Location-based food discovery
- **Real-time Tracking**: Live order and delivery updates
- **Rating System**: Quality assurance through reviews
- **Multiple Cuisines**: Support for all types of home cooking
- **Flexible Earnings**: Part-time income for home cooks

### Cook-on-Call Service Features
- **Skill-based Matching**: Find cooks based on cuisine expertise
- **Location Services**: Cooks travel to customer locations
- **Custom Menu Planning**: Personalized meal preparation
- **Event Cooking**: Support for parties, functions, and special occasions
- **Hourly/Daily Booking**: Flexible cooking service duration
- **Chef Verification**: Background and skill verification system

## 🤝 Contributing

This project is being built step-by-step. Each step will be thoroughly tested before moving to the next phase.

---

**Made with ❤️ for food lovers everywhere!**

*Bringing the warmth of home-cooked meals to your doorstep, one order at a time.*
