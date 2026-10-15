import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/cache/cache_manager.dart';
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'package:futblha/data/datasources/friends_remote_datasource/friends_remote_datasource.dart';
import 'package:futblha/data/models/response_model/friends/friendship_status_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/presentation/pages/friends/bloc/friendship_bloc.dart';
import 'package:futblha/presentation/pages/friends/widgets/friendship_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Answers the friendship status with [status]; actions aren't used here.
class _FakeFriendsDataSource implements FriendsRemoteDataSource {
  _FakeFriendsDataSource(this.status);
  final String status;

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> getFriendshipStatus({required int userId}) async =>
      ApiResultModel.success(data: FriendshipStatusModel(friendshipStatus: status));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  var friendshipStatus = 'none';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Logged-in user is 1.
    SharedPreferences.setMockInitialValues({CacheManager.keyUserId: '1'});
    // CacheManager.init also starts Hive, which asks path_provider for a folder.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory.systemTemp.path,
    );
    await CacheManager.instance.init();
    locator.registerSingleton<ResponsiveUiConfig>(ResponsiveUiConfig());
    locator.registerFactory<FriendshipBloc>(
      () => FriendshipBloc(_FakeFriendsDataSource(friendshipStatus)),
    );
  });
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

  testWidgets('another user\'s card shows the add-friend action', (tester) async {
    friendshipStatus = 'none';
    await _pumpLauncher(tester, (context) => PlayerInfoBottomSheet.showUser(context, userId: 9));
    expect(find.byType(FriendshipActionButton), findsOneWidget);
    expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
  });

  testWidgets('own card has no friend action', (tester) async {
    await _pumpLauncher(tester, (context) => PlayerInfoBottomSheet.showUser(context, userId: 1));
    expect(find.byType(FriendshipActionButton), findsNothing);
  });

  testWidgets('friends are shown as friends, not as add friend', (tester) async {
    friendshipStatus = 'friends';
    await _pumpLauncher(tester, (context) => PlayerInfoBottomSheet.showUser(context, userId: 9));
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.person_add_alt_1), findsNothing);
  });
}
