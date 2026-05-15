/// All static UI strings for RENTO app.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'RENTO';
  static const String appTagline = 'Rent anything, anywhere';

  // Auth
  static const String enterPhone = 'Enter your phone number';
  static const String otpSubtitle = "We'll send an OTP to verify your number";
  static const String sendOtp = 'Send OTP';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  static const String enterOtp = 'Enter 6-digit OTP';
  static const String otpSentTo = 'OTP sent to ';
  static const String didntReceive = "Didn't receive OTP?";
  static const String phoneHint = '+91 Enter phone number';
  static const String continueBtn = 'Continue';
  static const String signOut = 'Sign Out';

  // Home
  static const String featuredItems = 'Featured Items';
  static const String searchHint = 'Search products...';
  static const String allCategory = 'All';

  // Categories
  static const List<String> categories = [
    'All',
    'Electronics',
    'Vehicles',
    'Clothing',
    'Furniture',
    'Sports',
    'Books',
    'Tools',
    'Appliances',
    'Others',
  ];

  // Product
  static const String addProduct = 'Add Product';
  static const String listProduct = 'List Product';
  static const String uploadImages = 'Upload Images';
  static const String titleLabel = 'Title';
  static const String descriptionLabel = 'Description';
  static const String priceLabel = 'Price per day (₹)';
  static const String depositLabel = 'Security deposit (₹)';
  static const String categoryLabel = 'Category';
  static const String titleHint = 'e.g. Sony 4K Camera';
  static const String descHint = 'Describe your item...';
  static const String noProductsFound = 'No products found';

  // Booking
  static const String bookNow = 'Book Now';
  static const String bookingDetails = 'Booking Details';
  static const String selectDates = 'Select dates';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String duration = 'Duration';
  static const String days = 'days';
  static const String rentalAmount = 'Rental Amount';
  static const String securityDeposit = 'Security Deposit';
  static const String totalAmount = 'Total Amount';
  static const String pricePerDay = 'Price per day';
  static const String cancelBooking = 'Cancel Booking';
  static const String noBookingsYet = 'No bookings yet';
  static const String generateOtp = 'Generate OTP';
  static const String requestBooking = 'Request Booking';

  // Payment
  static const String proceedToPayment = 'Proceed to Payment';
  static const String paymentSummary = 'Payment Summary';
  static const String orderSummary = 'Order Summary';
  static const String paymentSuccessful = 'Payment Successful! 🎉';
  static const String paymentFailed = 'Payment Failed';
  static const String payNow = 'Pay Now';

  // Orders
  static const String myRentals = 'My Rentals';
  static const String myListings = 'My Listings';
  static const String asRenter = 'As Renter';
  static const String asOwner = 'As Owner';
  static const String viewDetails = 'View Details';
  static const String returnItem = 'Return Item';
  static const String confirmReturn = 'Confirm Return';

  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String kycVerification = 'KYC Verification';
  static const String submitIdProof = 'Submit ID Proof';
  static const String logout = 'Logout';
  static const String settings = 'Settings';
  static const String myProductsLabel = 'My Products';
  static const String activeRentalsLabel = 'Active Rentals';

  // Booking statuses
  static const String statusRequested = 'Awaiting Approval';
  static const String statusApproved = 'Approved';
  static const String statusBookingCreated = 'Pending Payment';
  static const String statusPaymentDone = 'Payment Done';
  static const String statusReadyForPickup = 'Ready for Pickup';
  static const String statusActiveRental = 'Active Rental';
  static const String statusReturnPending = 'Return Pending';
  static const String statusReturned = 'Returned';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
  static const String statusRejected = 'Rejected';
  static const String statusExpired = 'Expired';

  // KYC statuses
  static const String kycNotSubmitted = 'Not Submitted';
  static const String kycPending = 'Pending';
  static const String kycVerified = 'Verified';
  static const String kycRejected = 'Rejected';

  // Rating
  static const String rateExperience = 'Rate Experience';
  static const String writeReview = 'Write a review...';
  static const String submitRating = 'Submit Rating';

  // Errors & States
  static const String loading = 'Loading...';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  static const String noInternetConnection = 'No internet connection';
}
