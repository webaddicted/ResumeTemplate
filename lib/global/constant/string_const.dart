import 'package:template/global/constant/app_constant.dart';

class StringConst {
  static String get appName => AppConstant.appName;

  static const String ok = 'OK';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String yes = 'Yes';

  static const String somethingWentWrong =
      'Something went wrong. Please try again later.';
  static const String noInternetConnection = 'No Internet Connection';
  static const String noDataFound = 'No Data Found';
  static const String loading = 'Loading...';

  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String otpRequired = 'OTP is required';

  // Auth labels
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String loginLabel = 'Login';
  static const String register = 'Register';
  static const String createAccount = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String orContinueWith = 'Or continue with';
  static const String enterPassword = 'Enter your password';
  static const String confirmPassword = 'Confirm Password';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  static const String enterOtp = 'Enter OTP';
  static const String termsAgree = 'I agree to the Terms & Conditions';
  static const String getStarted = 'Get Started';

  // Onboarding (3 slides)
  static const String onboardingTitle1 = 'Welcome';
  static const String onboardingDesc1 = 'Discover everything your app has to offer.';
  static const String onboardingTitle2 = 'Stay Connected';
  static const String onboardingDesc2 = 'Get updates and notifications that matter to you.';
  static const String onboardingTitle3 = 'Get Started Today';
  static const String onboardingDesc3 = 'Create an account and start your journey.';

  // Profile
  static const String profileTitle = 'Profile';
  static const String editProfileTitle = 'Edit Profile';
  static const String fullName = 'Full Name';
  static const String enterName = 'Enter your name';
  static const String enterEmail = 'Enter your email';
  static const String enterPhone = 'Enter your phone';
  static const String phone = 'Phone Number';
  static const String gender = 'Gender';
  static const String dateOfBirth = 'Date of Birth';
  static const String save = 'Save';
  static const String shareApp = 'Share App';
  static const String logout = 'Logout';
  static const String logoutConfirmTitle = 'Logout?';
  static const String logoutConfirmMessage = 'Are you sure you want to logout?';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String notificationsTitle = 'Notifications';
  static const String language = 'Language';
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String termsTitle = 'Terms & Conditions';
  static const String rateApp = 'Rate App';
  static const String appVersion = 'App Version';

  // Help / About
  static const String helpSupportTitle = 'Help & Support';
  static const String aboutUsTitle = 'About Us';
}
