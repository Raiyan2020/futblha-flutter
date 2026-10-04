// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:futblha/application/core/di/app_component/app_component.dart'
    as _i582;
import 'package:futblha/application/core/di/app_component/dio_module.dart'
    as _i381;
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart'
    as _i90;
import 'package:futblha/application/core/utils/helpers/app_configurations_helper/app_configurations_helper.dart'
    as _i602;
import 'package:futblha/application/core/utils/helpers/app_flavor_helper/app_flavors_helper.dart'
    as _i389;
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart'
    as _i789;
import 'package:futblha/data/datasources/auth_remote_datasource/auth_remote_datasource.dart'
    as _i814;
import 'package:futblha/data/datasources/auth_remote_datasource/auth_remote_datasource_impl.dart'
    as _i546;
import 'package:futblha/data/datasources/contact_remote_datasource/contact_remote_datasource.dart'
    as _i215;
import 'package:futblha/data/datasources/contact_remote_datasource/contact_remote_datasource_impl.dart'
    as _i656;
import 'package:futblha/data/datasources/diwaniya_remote_datasource/diwaniya_remote_datasource.dart'
    as _i480;
import 'package:futblha/data/datasources/diwaniya_remote_datasource/diwaniya_remote_datasource_impl.dart'
    as _i403;
import 'package:futblha/data/datasources/faq_remote_datasource/faq_remote_datasource.dart'
    as _i1022;
import 'package:futblha/data/datasources/faq_remote_datasource/faq_remote_datasource_impl.dart'
    as _i968;
import 'package:futblha/data/datasources/games_remote_datasource/games_remote_datasource.dart'
    as _i1062;
import 'package:futblha/data/datasources/games_remote_datasource/games_remote_datasource_impl.dart'
    as _i227;
import 'package:futblha/data/datasources/general_remote_datasource/general_remote_datasource.dart'
    as _i389;
import 'package:futblha/data/datasources/general_remote_datasource/general_remote_datasource_impl.dart'
    as _i893;
import 'package:futblha/data/datasources/notifications_remote_datasource/notifications_remote_datasource.dart'
    as _i642;
import 'package:futblha/data/datasources/notifications_remote_datasource/notifications_remote_datasource_impl.dart'
    as _i997;
import 'package:futblha/data/datasources/payment_method_remote_datasource/payment_method_remote_datasource.dart'
    as _i803;
import 'package:futblha/data/datasources/payment_method_remote_datasource/payment_method_remote_datasource_impl.dart'
    as _i824;
import 'package:futblha/data/datasources/playgrounds_remote_datasource/playgrounds_remote_datasource.dart'
    as _i675;
import 'package:futblha/data/datasources/playgrounds_remote_datasource/playgrounds_remote_datasource_impl.dart'
    as _i609;
import 'package:futblha/data/datasources/settings_remote_datasource/settings_remote_datasource.dart'
    as _i223;
import 'package:futblha/data/datasources/settings_remote_datasource/settings_remote_datasource_impl.dart'
    as _i810;
import 'package:futblha/data/datasources/tasks_local_datasource/tasks_local_datasource.dart'
    as _i125;
import 'package:futblha/data/datasources/tasks_local_datasource/tasks_local_datasource_impl.dart'
    as _i962;
import 'package:futblha/data/datasources/wallet_remote_datasource/wallet_remote_datasource.dart'
    as _i41;
import 'package:futblha/data/datasources/wallet_remote_datasource/wallet_remote_datasource_impl.dart'
    as _i1010;
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/delete_request_strategy.dart'
    as _i741;
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart'
    as _i710;
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart'
    as _i208;
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/put_request_strategy.dart'
    as _i296;
import 'package:futblha/data/network/dio_strategy_helper/dio_request_context.dart'
    as _i791;
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart'
    as _i30;
import 'package:futblha/presentation/pages/bookings/bloc/bookings_bloc.dart'
    as _i464;
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart'
    as _i372;
import 'package:futblha/presentation/pages/faq/bloc/faq_bloc.dart' as _i1030;
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart' as _i468;
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart'
    as _i1024;
import 'package:futblha/presentation/pages/notifications/bloc/notifications_bloc.dart'
    as _i1069;
import 'package:futblha/presentation/pages/payment_method/bloc/payment_method_bloc.dart'
    as _i595;
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart'
    as _i497;
import 'package:futblha/presentation/pages/settings/bloc/settings_bloc.dart'
    as _i1007;
import 'package:futblha/presentation/pages/support/bloc/contact_bloc.dart'
    as _i597;
import 'package:futblha/presentation/pages/wallet/bloc/wallet_bloc.dart'
    as _i1016;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final registerModule = _$RegisterModule();
    gh.factory<_i791.DioRequestContext>(() => _i791.DioRequestContext());
    gh.singleton<_i361.Dio>(() => dioModule.dio);
    gh.singleton<_i90.AppRouter>(() => _i90.AppRouter());
    gh.singleton<_i602.AppConfigurations>(() => _i602.AppConfigurations());
    gh.singleton<_i389.AppFlavorsHelper>(() => _i389.AppFlavorsHelper());
    gh.singleton<_i789.ResponsiveUiConfig>(() => _i789.ResponsiveUiConfig());
    gh.factory<_i125.TasksLocalDataSource>(
      () => _i962.TasksLocalDataSourceImpl(),
    );
    gh.singleton<_i361.Interceptor>(
      () => dioModule.loggerInterceptor,
      instanceName: 'LoggerInterceptor',
    );
    gh.lazySingleton<_i741.DeleteRequestStrategy>(
      () => _i741.DeleteRequestStrategy(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i710.GetRequestStrategy>(
      () => _i710.GetRequestStrategy(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i208.PostRequestStrategy>(
      () => _i208.PostRequestStrategy(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i296.PutRequestStrategy>(
      () => _i296.PutRequestStrategy(gh<_i361.Dio>()),
    );
    await gh.singletonAsync<String>(
      () => registerModule.getBaseUrl(gh<_i389.AppFlavorsHelper>()),
      instanceName: 'baseUrl',
      preResolve: true,
    );
    gh.factory<_i1062.GamesRemoteDataSource>(
      () => _i227.GamesRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i215.ContactRemoteDataSource>(
      () => _i656.ContactRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i1022.FaqRemoteDataSource>(
      () => _i968.FaqRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i480.DiwaniyaRemoteDataSource>(
      () => _i403.DiwaniyaRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i642.NotificationsRemoteDataSource>(
      () => _i997.NotificationsRemoteDataSourceImpl(
        gh<_i791.DioRequestContext>(),
      ),
    );
    gh.factory<_i814.AuthRemoteDataSource>(
      () => _i546.AuthRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.singleton<_i30.AuthenticationBloc>(
      () => _i30.AuthenticationBloc(gh<_i814.AuthRemoteDataSource>()),
    );
    gh.factory<_i223.SettingsRemoteDataSource>(
      () => _i810.SettingsRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i389.GeneralRemoteDataSource>(
      () => _i893.GeneralRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i803.PaymentMethodRemoteDataSource>(
      () => _i824.PaymentMethodRemoteDataSourceImpl(
        gh<_i791.DioRequestContext>(),
      ),
    );
    gh.factory<_i41.WalletRemoteDataSource>(
      () => _i1010.WalletRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i675.PlaygroundsRemoteDataSource>(
      () =>
          _i609.PlaygroundsRemoteDataSourceImpl(gh<_i791.DioRequestContext>()),
    );
    gh.factory<_i468.GamesBloc>(
      () => _i468.GamesBloc(gh<_i1062.GamesRemoteDataSource>()),
    );
    gh.factory<_i1016.WalletBloc>(
      () => _i1016.WalletBloc(gh<_i41.WalletRemoteDataSource>()),
    );
    gh.factory<_i597.ContactBloc>(
      () => _i597.ContactBloc(gh<_i215.ContactRemoteDataSource>()),
    );
    gh.singleton<_i1007.SettingsBloc>(
      () => _i1007.SettingsBloc(gh<_i223.SettingsRemoteDataSource>()),
    );
    gh.factory<_i1030.FaqBloc>(
      () => _i1030.FaqBloc(gh<_i1022.FaqRemoteDataSource>()),
    );
    gh.singleton<_i1069.NotificationsBloc>(
      () => _i1069.NotificationsBloc(gh<_i642.NotificationsRemoteDataSource>()),
    );
    gh.factory<_i464.BookingsBloc>(
      () => _i464.BookingsBloc(gh<_i675.PlaygroundsRemoteDataSource>()),
    );
    gh.factory<_i497.PlaygroundsBloc>(
      () => _i497.PlaygroundsBloc(gh<_i675.PlaygroundsRemoteDataSource>()),
    );
    gh.factory<_i595.PaymentMethodBloc>(
      () => _i595.PaymentMethodBloc(gh<_i803.PaymentMethodRemoteDataSource>()),
    );
    gh.factory<_i372.DiwaniyaBloc>(
      () => _i372.DiwaniyaBloc(
        gh<_i480.DiwaniyaRemoteDataSource>(),
        gh<_i30.AuthenticationBloc>(),
      ),
    );
    gh.factory<_i1024.GeneralBloc>(
      () => _i1024.GeneralBloc(gh<_i389.GeneralRemoteDataSource>()),
    );
    return this;
  }
}

class _$DioModule extends _i381.DioModule {}

class _$RegisterModule extends _i582.RegisterModule {}
