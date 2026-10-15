import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'package:futblha/data/datasources/games_remote_datasource/games_remote_datasource.dart';
import 'package:futblha/data/datasources/playgrounds_remote_datasource/playgrounds_remote_datasource.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/games/create_game_page.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';

class _FakeGamesDataSource implements GamesRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaygroundsDataSource implements PlaygroundsRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Without EasyLocalization loaded, `.tr()` returns the key, so the tests look
// for the LocaleKeys themselves.
Future<void> _pumpPage(WidgetTester tester, GameType type) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          locator<ResponsiveUiConfig>().initialize(context);
          return CreateGamePage(gameType: type);
        },
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    locator.registerSingleton<ResponsiveUiConfig>(ResponsiveUiConfig());
    locator.registerFactory<GamesBloc>(() => GamesBloc(_FakeGamesDataSource()));
    locator.registerFactory<PlaygroundsBloc>(() => PlaygroundsBloc(_FakePlaygroundsDataSource()));
  });

  tearDownAll(() => locator.reset());

  for (final type in [GameType.publicGame, GameType.myDiwaniyaOnly]) {
    testWidgets('${type.name} shows both payment timing options', (tester) async {
      await _pumpPage(tester, type);

      expect(find.text(LocaleKeys.payment_method), findsOneWidget);
      expect(find.text(LocaleKeys.pay_immediately), findsOneWidget);
      expect(find.text(LocaleKeys.pay_after_players_complete), findsOneWidget);
      // Nothing is preselected, so no explanation yet.
      expect(find.text(LocaleKeys.pay_immediately_description), findsNothing);
      expect(find.text(LocaleKeys.pay_after_players_complete_description), findsNothing);
    });
  }

  testWidgets('selecting and changing the payment timing updates the explanation', (tester) async {
    await _pumpPage(tester, GameType.publicGame);

    await tester.ensureVisible(find.text(LocaleKeys.pay_immediately));
    await tester.tap(find.text(LocaleKeys.pay_immediately));
    await tester.pump();
    expect(find.text(LocaleKeys.pay_immediately_description), findsOneWidget);
    expect(find.text(LocaleKeys.pay_after_players_complete_description), findsNothing);

    await tester.tap(find.text(LocaleKeys.pay_after_players_complete));
    await tester.pump();
    expect(find.text(LocaleKeys.pay_after_players_complete_description), findsOneWidget);
    expect(find.text(LocaleKeys.pay_immediately_description), findsNothing);
  });

  testWidgets('private game keeps its existing flow (no payment timing)', (tester) async {
    await _pumpPage(tester, GameType.privateGame);
    expect(find.text(LocaleKeys.pay_immediately), findsNothing);
    expect(find.text(LocaleKeys.pay_after_players_complete), findsNothing);
  });
}
