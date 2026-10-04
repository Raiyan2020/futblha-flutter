import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/application/core/di/app_component/app_component.config.dart';

import '../../utils/constants/app_constants.dart';
import '../../utils/helpers/app_flavor_helper/app_flavors_helper.dart';
import '../../utils/helpers/app_flavor_helper/environment_config.dart';

final GetIt locator = GetIt.instance;

@InjectableInit(
  preferRelativeImports: false,
)
Future<void> initAppComponentLocator() async =>
    locator.init(environment: Environment.dev);

@module
abstract class RegisterModule {
  @preResolve
  @singleton
  @Named('baseUrl')
  Future<String> getBaseUrl(AppFlavorsHelper appFlavorsHelper) async {
    // This line should ideally be configured based on build flavors or a global config
    // For now, assuming DEV_VARIANT as per main.dart's initial setup
    appFlavorsHelper.configure(productFlavor: EnvironmentConfig.DEV_VARIANT.toProductFlavor());

    String baseUrl;
    switch (appFlavorsHelper.productFlavor) {
      case ProductFlavor.DEV:
        baseUrl = devBaseUrl;
        break;
      case ProductFlavor.PROD:
        baseUrl = prodBaseUrl;
        break;
      case ProductFlavor.QA:
        baseUrl = qaBaseUrl;
        break;
      case ProductFlavor.UAT:
        baseUrl = uatBaseUrl;
        break;
      default:
        baseUrl = devBaseUrl; // Fallback
    }
    return baseUrl;
  }
}
