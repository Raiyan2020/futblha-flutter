import '../../constants/app_constants.dart';

class EnvironmentConfig {
  static const String BUILD_VARIANT = String.fromEnvironment('BUILD_VARIANT', defaultValue: qaEnvironmentString);
  static const String DEV_VARIANT = String.fromEnvironment('BUILD_VARIANT', defaultValue: devEnvironmentString);
  static const String PROD_VARIANT = String.fromEnvironment('BUILD_VARIANT', defaultValue: prodEnvironmentString);
}
