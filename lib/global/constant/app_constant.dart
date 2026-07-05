class AppConstant {
  AppConstant._();

  static const String appName = 'ResumeKit Pro';
  static const String appTagline = 'Professional resumes & marriage biodata.';
  static const String storagePrefix = 'ResumeKitPro';

  static String? _appVersionFromPackage;

  static void setAppVersionFromPackage(String version, [String? buildNumber]) {
    _appVersionFromPackage = buildNumber != null && buildNumber.isNotEmpty
        ? '$version+$buildNumber'
        : version;
  }

  static String get appVersion => _appVersionFromPackage ?? '1.0.0';
}
