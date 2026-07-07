abstract final class AppStrings {
  static const String appName = 'RSC Rider';

  // Auth
  static const String login = 'Log In';
  static const String logout = 'Log Out';
  static const String email = 'Email';
  static const String identifierLabel = 'Email or Phone';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot password?';
  static const String loggingIn = 'Logging in…';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String notARiderAccount =
      'This is a rider-only app. Please use the RSC customer app to order food.';
  static const String logOutConfirmMessage =
      'Are you sure you want to log out?';

  // Dashboard
  static const String goOnline = 'Go Online';
  static const String goOffline = 'Go Offline';
  static const String youAreOnline = "You're Online";
  static const String youAreOffline = "You're Offline";
  static const String todayEarnings = "Today's Earnings";
  static const String weekEarnings = 'This Week';
  static const String totalDeliveries = 'Total Deliveries';
  static const String todayDeliveries = 'Today';
  static const String availability = 'Availability';
  static const String onlineSubtitle = 'You are online and visible to kitchens';
  static const String offlineSubtitle =
      'You are offline. Go online to receive orders';
  static const String todayEarningsLabel = 'TODAY';
  static const String weekEarningsLabel = 'THIS WEEK';
  static const String deliveries = 'deliveries';
  static const String viewIncomingOrders = 'View Incoming Orders →';
  static const String goOnlineToStart = 'Go Online to Start';
  static const String youAreOfflineMap = 'You are offline';
  static const String toggleToGoOnline = 'Toggle availability to go online';
  static const String centerOnMe = 'Center on me';
  static const String goodMorning = 'Good morning';
  static const String broadcastingLocation = '● Broadcasting location';
  static const String locationAccessNeeded = '⚠ Location access needed';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';

  // Dispatch
  static const String newDelivery = 'New Delivery Request';
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String autoRejectIn = 'Auto-reject in';
  static const String distance = 'Distance';
  static const String estimatedPay = 'Estimated Pay';
  static const String estimatedTime = 'Est. Time';

  // Delivery
  static const String activeDelivery = 'Active Delivery';
  static const String arrivedAtPickup = 'Arrived at Pickup';
  static const String pickedUp = 'Picked Up';
  static const String arrivedAtDropoff = 'Arrived at Dropoff';
  static const String confirmDelivery = 'Confirm Delivery';
  static const String deliveryComplete = 'Delivery Complete!';
  static const String callCustomer = 'Call Customer';
  static const String navigate = 'Navigate';
  static const String confirmDeliveryPrompt =
      'Confirm that you have delivered this order to the customer.';
  static const String completeDelivery = 'Complete Delivery';
  static const String completeADelivery = '📦 Complete a Delivery';
  static const String checkingForOrders = 'Checking for orders...';
  static const String customerDeliveryCode = 'CUSTOMER DELIVERY CODE';
  static const String verifying = 'Verifying...';
  static const String backToDashboard = 'Back to Dashboard';
  static const String codeMustBeSixDigits = 'Delivery code must be 6 digits';
  static const String invalidDeliveryCode =
      'Invalid delivery code. Please check the code with the customer.';
  static const String orderNotAssigned = 'This order is not assigned to you.';
  static const String orderNotFound =
      'Order not found. Please check the order ID.';

  // Assigned orders
  static const String assignedOrders = 'assigned order(s)';
  static const String startDelivery = 'Start Delivery 🛵';
  static const String rejectOrder = 'Reject Order';
  static const String whyRejecting = 'Why are you rejecting this order?';
  static const String confirmRejection = 'Confirm Rejection';
  static const String suggestedReasonBikeIssue = 'Bike issue';
  static const String suggestedReasonTooFar = 'Too far';
  static const String suggestedReasonEmergency = 'Personal emergency';
  static const String suggestedReasonTraffic = 'Traffic conditions';
  static const String suggestedReasonAddress = 'Unable to locate address';
  static const String suggestedReasonOther = 'Other';
  static const String describeYourReason = 'Describe your reason...';
  static const String orTypeYourReason = 'OR TYPE YOUR REASON';
  static const String pickupFrom = 'PICKUP FROM';
  static const String deliverTo = 'DELIVER TO';
  static const String iVeArrived = "I've Arrived 📦";
  static const String almostDone = '📦 Almost done!';
  static const String askCustomerCode =
      'Ask the customer for their 6-digit delivery code to complete this '
      'delivery.';
  static const String noAssignedOrders = 'No assigned orders at the moment';
  static const String stayOnDelivery = 'Stay';
  static const String goBack = 'Go Back';
  static const String leaveDeliveryWarning =
      'Are you sure? The delivery will still be assigned to you.';
  static const String pickupCode = 'Code: ';
  static const String orderLabel = 'ORDER';
  static const String addressLabel = 'ADDRESS';
  static const String earningsLabel = 'EARNINGS';

  // Delivery status labels
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  // History
  static const String deliveryHistory = 'Delivery History';
  static const String noDeliveriesYet = 'No deliveries yet';
  static const String noDeliveriesSubtitle =
      'Your completed deliveries will appear here.';
  static const String completeFirstDelivery =
      'Complete your first delivery to see your history here';
  static const String totalEarnings = 'TOTAL EARNINGS';
  static const String thisSession = 'THIS SESSION';

  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String documents = 'Documents';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String vehicleType = 'Vehicle Type';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String accountInformation = 'ACCOUNT INFORMATION';
  static const String security = 'SECURITY';
  static const String saveChanges = 'Save Changes';
  static const String changePassword = 'Change Password';
  static const String updatePassword = 'Update Password';
  static const String profileUpdated = '✓ Profile updated';
  static const String passwordUpdated = '✓ Password updated';
  static const String currentPassword = 'CURRENT PASSWORD';
  static const String newPassword = 'NEW PASSWORD';
  static const String confirmNewPassword = 'CONFIRM NEW PASSWORD';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String passwordTooShort = 'Min 6 characters';
  static const String newPasswordSameAsCurrent =
      'Must be different from current';
  static const String takePhoto = '📷 Take Photo';
  static const String chooseFromGallery = '🖼️ Choose from Gallery';

  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications';
  static const String markAllRead = 'Mark all read';
  static const String noNotificationsYet = 'No notifications yet';
  static const String orderUpdatesHere = 'Order updates will appear here';
  static const String yesterday = 'Yesterday';

  // Common
  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Please try again.';
  static const String noInternetConnection = 'No internet connection';
  static const String noInternetSubtitle =
      'Check your connection and try again.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String close = 'Close';
  static const String comingSoon = 'Coming soon';
}
