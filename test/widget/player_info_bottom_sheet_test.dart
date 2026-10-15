import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'package:futblha/data/models/response_model/games/game_player_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/games/widgets/player_info_bottom_sheet.dart';

Future<void> _pumpLauncher(WidgetTester tester, void Function(BuildContext) open) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            locator<ResponsiveUiConfig>().initialize(context);
            return TextButton(onPressed: () => open(context), child: const Text('open'));
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => locator.registerSingleton<ResponsiveUiConfig>(ResponsiveUiConfig()));
  tearDownAll(() => locator.reset());

  testWidgets('showUser opens the card for any user (no position row)', (tester) async {
    await _pumpLauncher(
      tester,
      (context) => PlayerInfoBottomSheet.showUser(context, userId: 9, name: 'Member Name'),
    );

    expect(find.text('Member Name'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget); // placeholder, no photo
    expect(find.text(LocaleKeys.playing_position), findsNothing);
    final sheet = tester.widget<PlayerInfoBottomSheet>(find.byType(PlayerInfoBottomSheet));
    expect(sheet.userId, 9);
  });

  testWidgets('game players still show their position (pitch)', (tester) async {
    await _pumpLauncher(
      tester,
      (context) => PlayerInfoBottomSheet.show(
        context,
        GamePlayerModel(id: 3, name: 'Pitch Player', positionText: 'Attacker'),
      ),
    );

    expect(find.text('Pitch Player'), findsOneWidget);
    expect(find.text(LocaleKeys.playing_position), findsOneWidget);
    expect(find.text('Attacker'), findsOneWidget);
    final sheet = tester.widget<PlayerInfoBottomSheet>(find.byType(PlayerInfoBottomSheet));
    expect(sheet.userId, 3);
  });
}
