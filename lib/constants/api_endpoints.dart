// Holds all API endpoint paths as constants
class ApiEndpoints {
  static const String register = '/register';
  static const String login = '/login';
  static const String me = '/me';
  static const String loginHistory = '/login_history';
  static const String patients = '/patients';
  static const String scanResults = '/scan_results';
  static const String patient =
      '/patient'; // /patient/{id} şeklinde kullanılacak
  static const String changeCredentials = '/change_credentials';
  static const String uploadProfilePicture = '/upload_profile_picture';
  static const String profilePicture =
      '/profile_picture'; // /profile_picture/{id} şeklinde kullanılacak
  // Dashboard/model service endpoints
  static const String models = '/models';
  static const String detect = '/detect';
  // Diğer endpointler eklenebilir
}
// Not: Parametreli endpointler için string interpolation ile kullanılabilir.
