import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'package:futblha/data/datasources/games_remote_datasource/games_remote_datasource.dart';
import 'package:futblha/data/datasources/notifications_remote_datasource/notifications_remote_datasource.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/data/models/response_model/diwaniya/user_permission_model.dart';
import 'package:futblha/data/models/response_model/games/game_invitations_response_model.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/games/games_invitations_page.dart';
import 'package:futblha/presentation/pages/notifications/bloc/notifications_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No translations: `.tr()` returns the key, but the app's snackbar (which
/// reads the EasyLocalization locale) can build.
class _EmptyAssetLoader extends AssetLoader {
  const _EmptyAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async => {};
}

/// Holds accept / reject responses until the test releases them.
class _FakeGamesDataSource implements GamesRemoteDataSource {
  int acceptCalls = 0;
  int rejectCalls = 0;
  // Created per call (inside the test's fake-async zone) so completing it
  // actually reaches the bloc.
  late Completer<ApiResultModel<String?>> reply;

  @override
  Future<ApiResultModel<GameInvitationsResponseModel?>> getGameInvitations() async =>
      ApiResultModel.success(
        data: GameInvitationsResponseModel(
          receivingGames: [
            GameModel(
              id: 7,
              type: 'private',
              gameStatus: 'pending',
              creatorDiwaniya: DiwaniyaModel(name: 'A'),
              opponentDiwaniya: DiwaniyaModel(
                name: 'B',
                userPermission: UserPermissionModel(isAdmin: true),
              ),
            ),
          ],
          sendingGames: const [],
        ),
      );

  @override
  Future<ApiResultModel<String?>> acceptGame({required int gameId}) {
    acceptCalls++;
    reply = Completer();
    return reply.future;
  }

  @override
  Future<ApiResultModel<String?>> rejectGame({required int gameId}) {
    rejectCalls++;
    reply = Completer();
    return reply.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationsDataSource implements NotificationsRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuietNotificationsBloc extends NotificationsBloc {
  _QuietNotificationsBloc() : super(_FakeNotificationsDataSource());

  @override
  void add(NotificationsEvent event) {}
}

void main() {
  late _FakeGamesDataSource dataSource;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    dataSource = _FakeGamesDataSource();
    locator.registerSingleton<ResponsiveUiConfig>(ResponsiveUiConfig());
    locator.registerFactory<GamesBloc>(() => GamesBloc(dataSource));
    locator.registerSingleton<NotificationsBloc>(_QuietNotificationsBloc());
  });

  tearDown(() => locator.reset());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'unused',
        assetLoader: const _EmptyAssetLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Builder(
              builder: (context) {
                locator<ResponsiveUiConfig>().initialize(context);
                return const GamesInvitationsPage();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ElevatedButton acceptButton(WidgetTester tester) => tester.widget<ElevatedButton>(
    find.ancestor(of: find.text(LocaleKeys.accept), matching: find.byType(ElevatedButton)),
  );

  OutlinedButton rejectButton(WidgetTester tester) => tester.widget<OutlinedButton>(
    find.ancestor(of: find.text(LocaleKeys.reject), matching: find.byType(OutlinedButton)),
  );

  testWidgets('accepting disables both buttons until the reply arrives', (tester) async {
    await pumpPage(tester);
    expect(acceptButton(tester).onPressed, isNotNull);

    await tester.tap(find.text(LocaleKeys.accept));
    await tester.pump();

    // Both buttons are disabled at once, so a second tap (or a reject) can't
    // send another reply while the first one is in flight.
    expect(dataSource.acceptCalls, 1);
    expect(acceptButton(tester).onPressed, isNull);
    expect(rejectButton(tester).onPressed, isNull);
    expect(dataSource.rejectCalls, 0);

    dataSource.reply.complete(const ApiResultModel.success(data: 'ok'));
    await tester.pumpAndSettle();
    expect(dataSource.acceptCalls, 1);
    // Let the success message's auto-dismiss timer run out.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('buttons are enabled again after a failed reply', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(LocaleKeys.reject));
    await tester.pump();
    expect(acceptButton(tester).onPressed, isNull);

    dataSource.reply.complete(
      const ApiResultModel.failure(errorResultEntity: ErrorResultModel(message: 'boom')),
    );
    await tester.pumpAndSettle();

    expect(dataSource.rejectCalls, 1);
    expect(acceptButton(tester).onPressed, isNotNull);
    expect(rejectButton(tester).onPressed, isNotNull);
    // Let the error message's auto-dismiss timer run out.
    await tester.pump(const Duration(seconds: 4));
  });
}
