class ApiConstants {
  // Automatically select the correct URL based on the platform
  static String get baseUrl {
    return 'http://192.168.8.110:5151/api/';
  }

  static const String doctors = '/Doctors';
  static const String patients = '/Patients';
  static const String prescriptions = '/Prescriptions';
}
