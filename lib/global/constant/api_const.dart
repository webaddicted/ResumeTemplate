class ApiConstant {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int timeout = 30;

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';
  static const String userProfile = 'user/profile';

  static const String somethingWentWrong =
      'Something went wrong. Please try again later.';
  static const String noInternetConnection = 'No Internet Connection';
}
