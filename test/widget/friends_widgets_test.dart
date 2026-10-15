import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'package:futblha/data/datasources/friends_remote_datasource/friends_remote_datasource.dart';
import 'package:futblha/data/models/response_model/friends/friendship_status_model.dart';
import 'package:futblha/data/models/response_model/friends/invitable_friend_model.dart';
import 'package:futblha/data/models/response_model/friends/invite_result_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/friends/bloc/friendship_bloc.dart';
import 'package:futblha/presentation/pages/friends/bloc/invite_friends_bloc.dart';
import 'package:futblha/presentation/pages/friends/widgets/friend_request_actions.dart';
import 'package:futblha/presentation/pages/friends/widgets/invite_friends_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EmptyAssetLoader extends AssetLoader {
  const _EmptyAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async => {};
}

class _FakeFriendsDataSource implements FriendsRemoteDataSource {
  ApiResultModel<List<InvitableFriendModel>?> invitable = const ApiResultModel.success(data: []);
  ApiResultModel<FriendshipStatusModel?>? actionReply;
  List<int>? invitedIds;
  int acceptCalls = 0;

  @override
  Future<ApiResultModel<List<InvitableFriendModel>?>> getInvitableFriends({
    required int gameId,
  }) async => invitable;

  @override
  Future<ApiResultModel<List<InviteResultModel>?>> inviteFriends({
    required int gameId,
    required List<int> userIds,
  }) async {
    invitedIds = userIds;
    return ApiResultModel.success(
      data: [for (final id in userIds) InviteResultModel(userId: id, status: 'invited')],
    );
  }

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> acceptFriendRequest({
    required int requestId,
  }) async {
    acceptCalls++;
    return actionReply!;
  }

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> getFriendshipStatus({required int userId}) async =>
      ApiResultModel.success(data: FriendshipStatusModel(friendshipStatus: 'friends'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeFriendsDataSource ds;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    ds = _FakeFriendsDataSource();
    locator.registerSingleton<ResponsiveUiConfig>(ResponsiveUiConfig());
    locator.registerFactory<InviteFriendsBloc>(() => InviteFriendsBloc(ds));
    locator.registerFactory<FriendshipBloc>(() => FriendshipBloc(ds));
  });

  tearDown(() => locator.reset());

  Future<void> pump(WidgetTester tester, Widget child) async {
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
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  locator<ResponsiveUiConfig>().initialize(context);
                  return child;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Let the snackbar's auto-dismiss timer run out.
  Future<void> finish(WidgetTester tester) => tester.pump(const Duration(seconds: 4));

  group('InviteFriendsBottomSheet', () {
    testWidgets('shows each friend as the backend reports it, sends only selected', (tester) async {
      ds.invitable = ApiResultModel.success(
        data: [
          InvitableFriendModel(id: 1, name: 'Ali', inviteStatus: 'can_invite'),
          InvitableFriendModel(id: 2, name: 'Omar', inviteStatus: 'already_member'),
          InvitableFriendModel(
            id: 3,
            name: 'Saad',
            inviteStatus: 'not_eligible',
            reason: 'Not in the Diwaniya',
          ),
        ],
      );
      await pump(tester, const InviteFriendsBottomSheet(gameId: 5));

      expect(find.text('Ali'), findsOneWidget);
      expect(find.text(LocaleKeys.invite_status_already_member), findsOneWidget);
      expect(find.text(LocaleKeys.invite_status_not_eligible), findsOneWidget);
      expect(find.text('Not in the Diwaniya'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget); // only the invitable friend

      final sendButton = find.ancestor(
        of: find.text(LocaleKeys.send_invitations),
        matching: find.byType(ElevatedButton),
      );
      expect(tester.widget<ElevatedButton>(sendButton).onPressed, isNull);

      await tester.tap(find.text('Ali'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(sendButton).onPressed, isNotNull);

      await tester.tap(sendButton);
      await tester.pumpAndSettle();
      expect(ds.invitedIds, [1]);
      await finish(tester);
    });

    testWidgets('empty friends list', (tester) async {
      await pump(tester, const InviteFriendsBottomSheet(gameId: 5));
      expect(find.text(LocaleKeys.no_friends_to_invite), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('load failure offers retry', (tester) async {
      ds.invitable = const ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(message: 'Game is full', statusCode: 422),
      );
      await pump(tester, const InviteFriendsBottomSheet(gameId: 5));
      expect(find.text('Game is full'), findsOneWidget);
      expect(find.text(LocaleKeys.retry), findsOneWidget);
    });
  });

  group('FriendRequestActions', () {
    testWidgets('accepting shows the accepted state from the backend', (tester) async {
      ds.actionReply = ApiResultModel.success(
        data: FriendshipStatusModel(friendshipStatus: 'friends'),
      );
      await pump(tester, const FriendRequestActions(requestId: 15, senderId: 7));

      await tester.tap(find.text(LocaleKeys.accept_friend_request));
      await tester.pumpAndSettle();
      expect(ds.acceptCalls, 1);
      expect(find.text(LocaleKeys.friend_request_accepted_label), findsOneWidget);
      expect(find.text(LocaleKeys.accept_friend_request), findsNothing);
      await finish(tester);
    });

    testWidgets('an old request (409) is shown as already handled', (tester) async {
      ds.actionReply = const ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(message: 'Already handled', statusCode: 409),
      );
      await pump(tester, const FriendRequestActions(requestId: 15, senderId: 7));

      await tester.tap(find.text(LocaleKeys.accept_friend_request));
      await tester.pumpAndSettle();
      expect(find.text(LocaleKeys.friend_request_already_handled), findsOneWidget);
      expect(find.text(LocaleKeys.accept_friend_request), findsNothing);
      await finish(tester);
    });
  });
}
