class Constants {
  // API
  static const String apiUrl = 'http://192.168.255.206:8000/api';
  //static const String apiUrl = 'http://10.0.2.2:8000/api'; // Pour l'émulateur Android
  // static const String apiUrl = 'http://localhost:8000/api'; // Pour iOS
  
  // Images
  static const String placeholderImageUrl = 'assets/images/placeholder.jpg';
  static const String logoUrl = 'assets/images/logo.png';
  
  // Préférences
  static const String themePreference = 'theme_preference';
  static const String tokenPreference = 'token_preference';
  static const String userPreference = 'user_preference';
  
  // Navigation
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String eventsRoute = '/events';
  static const String eventDetailsRoute = '/event_details';
  static const String createEventRoute = '/create_event';
  
  // Dates
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}