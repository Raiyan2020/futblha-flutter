import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/data/datasources/friends_remote_datasource/friends_remote_datasource.dart';
import 'package:futblha/data/models/enums/friendship_status.dart';
import 'package:futblha/data/models/response_model/friends/friendship_status_model.dart';
import 'package:futblha/data/models/response_model/friends/invitable_friend_model.dart';
import 'package:futblha/data/models/response_model/friends/invite_result_model.dart';
import 'package:futblha/presentation/pages/friends/bloc/friendship_bloc.dart';
import 'package:futblha/presentation/pages/friends/bloc/invite_friends_bloc.dart';

class _FakeFriendsDataSource implements FriendsRemoteDataSource {
  ApiResultModel<FriendshipStatusModel?> statusReply = ApiResultModel.success(
    data: FriendshipStatusModel(friendshipStatus: 'none'),
  );
  ApiResultModel<FriendshipStatusModel?>? actionReply;
  Completer<ApiResultModel<FriendshipStatusModel?>>? actionGate;
  ApiResultModel<List<InvitableFriendModel>?> invitableReply = const ApiResultModel.success(
    data: [],
  );
  ApiResultModel<List<InviteResultModel>?>? inviteReply;

  int statusCalls = 0, sendCalls = 0, acceptCalls = 0, rejectCalls = 0, inviteCalls = 0;
  List<int>? lastInvitedIds;

  Future<ApiResultModel<FriendshipStatusModel?>> _action() =>
      actionGate?.future ?? Future.value(actionReply);

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> getFriendshipStatus({required int userId}) async {
    statusCalls++;
    return statusReply;
  }

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> sendFriendRequest({required int userId}) {
    sendCalls++;
    return _action();
  }

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> acceptFriendRequest({required int requestId}) {
    acceptCalls++;
    return _action();
  }

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> rejectFriendRequest({required int requestId}) {
    rejectCalls++;
    return _action();
  }

  @override
  Future<ApiResultModel<List<InvitableFriendModel>?>> getInvitableFriends({
    required int gameId,
  }) async => invitableReply;

  @override
  Future<ApiResultModel<List<InviteResultModel>?>> inviteFriends({
    required int gameId,
    required List<int> userIds,
  }) async {
    inviteCalls++;
    lastInvitedIds = userIds;
    return inviteReply!;
  }
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('models', () {
    test('friendship status parses every backend value, unknown stays null', () {
      expect(FriendshipStatus.fromApi('self'), FriendshipStatus.self);
      expect(FriendshipStatus.fromApi('none'), FriendshipStatus.none);
      expect(FriendshipStatus.fromApi('request_sent'), FriendshipStatus.requestSent);
      expect(FriendshipStatus.fromApi('request_received'), FriendshipStatus.requestReceived);
      expect(FriendshipStatus.fromApi('friends'), FriendshipStatus.friends);
      expect(FriendshipStatus.fromApi('blocked'), isNull);
      expect(FriendshipStatus.fromApi(null), isNull);
    });

    test('status and action responses parse', () {
      final status = FriendshipStatusModel.fromJson({
        'friendship_status': 'request_received',
        'friend_request_id': 15,
      });
      expect(status.status, FriendshipStatus.requestReceived);
      expect(status.friendRequestId, 15);

      final action = FriendshipStatusModel.fromActionJson({'id': 16, 'status': 'request_sent'});
      expect(action.status, FriendshipStatus.requestSent);
      expect(action.friendRequestId, 16);

      final friend = InvitableFriendModel.fromJson({
        'id': 3,
        'name': 'Ali',
        'invite_status': 'already_member',
        'reason': 'منضم',
      });
      expect(friend.canInvite, isFalse);
      expect(InvitableFriendModel(inviteStatus: 'can_invite').canInvite, isTrue);

      final result = InviteResultModel.fromJson({'user_id': 3, 'status': 'invited', 'msg': 'ok'});
      expect(result.userId, 3);
      expect(result.status, 'invited');
    });
  });

  group('FriendshipBloc', () {
    late _FakeFriendsDataSource ds;
    late FriendshipBloc bloc;

    setUp(() {
      ds = _FakeFriendsDataSource();
      bloc = FriendshipBloc(ds);
    });
    tearDown(() => bloc.close());

    test('loads the status from the backend', () async {
      ds.statusReply = ApiResultModel.success(
        data: FriendshipStatusModel(friendshipStatus: 'friends'),
      );
      bloc.add(const LoadFriendshipEvent(userId: 7));
      await _settle();
      expect(bloc.status, FriendshipStatus.friends);
      expect(bloc.state, isA<FriendshipLoaded>());
    });

    test('a failed load is reported as loadFailed (retry)', () async {
      ds.statusReply = const ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(message: 'down', statusCode: 500),
      );
      bloc.add(const LoadFriendshipEvent(userId: 7));
      await _settle();
      expect(bloc.state, isA<FriendshipError>());
      expect((bloc.state as FriendshipError).loadFailed, isTrue);
    });

    test('sending updates the status from the response', () async {
      ds.actionReply = ApiResultModel.success(
        data: FriendshipStatusModel(friendshipStatus: 'request_sent', friendRequestId: 20),
      );
      bloc.add(const SendFriendRequestEvent(userId: 7));
      await _settle();
      expect(bloc.status, FriendshipStatus.requestSent);
      expect(bloc.friendRequestId, 20);
      expect(bloc.state, isA<FriendshipActionSuccess>());
    });

    test('repeated taps while sending send one request', () async {
      ds.actionGate = Completer();
      bloc.add(const SendFriendRequestEvent(userId: 7));
      await _settle();
      bloc.add(const SendFriendRequestEvent(userId: 7));
      bloc.add(const SendFriendRequestEvent(userId: 7));
      await _settle();
      expect(ds.sendCalls, 1);
      expect(bloc.isBusy, isTrue);

      ds.actionGate!.complete(
        ApiResultModel.success(data: FriendshipStatusModel(friendshipStatus: 'request_sent')),
      );
      await _settle();
      expect(bloc.isBusy, isFalse);
      expect(ds.sendCalls, 1);
    });

    test('409 shows the error and reloads the real state', () async {
      ds.actionReply = const ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(message: 'already sent', statusCode: 409),
      );
      ds.statusReply = ApiResultModel.success(
        data: FriendshipStatusModel(friendshipStatus: 'request_sent'),
      );
      final states = <FriendshipState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const SendFriendRequestEvent(userId: 7));
      await _settle();
      await sub.cancel();

      expect(states.whereType<FriendshipError>().single.statusCode, 409);
      expect(ds.statusCalls, 1);
      expect(bloc.status, FriendshipStatus.requestSent);
    });

    test('accept and reject call the right endpoints', () async {
      ds.actionReply = ApiResultModel.success(
        data: FriendshipStatusModel(friendshipStatus: 'friends'),
      );
      bloc.add(const AcceptFriendRequestEvent(requestId: 15));
      await _settle();
      expect(ds.acceptCalls, 1);
      expect(bloc.status, FriendshipStatus.friends);

      ds.actionReply = ApiResultModel.success(
        data: FriendshipStatusModel(friendshipStatus: 'none'),
      );
      bloc.add(const RejectFriendRequestEvent(requestId: 16));
      await _settle();
      expect(ds.rejectCalls, 1);
      expect(bloc.status, FriendshipStatus.none);
    });
  });

  group('InviteFriendsBloc', () {
    late _FakeFriendsDataSource ds;
    late InviteFriendsBloc bloc;

    setUp(() {
      ds = _FakeFriendsDataSource();
      bloc = InviteFriendsBloc(ds);
    });
    tearDown(() => bloc.close());

    test('loads invitable friends', () async {
      ds.invitableReply = ApiResultModel.success(
        data: [InvitableFriendModel(id: 1, inviteStatus: 'can_invite')],
      );
      bloc.add(const LoadInvitableFriendsEvent(gameId: 5));
      await _settle();
      expect(bloc.friends, hasLength(1));
      expect(bloc.state, isA<InviteFriendsLoaded>());
    });

    test('sends the selected ids, keeps per-friend results and reloads', () async {
      ds.inviteReply = ApiResultModel.success(
        data: [
          InviteResultModel(userId: 1, status: 'invited'),
          InviteResultModel(userId: 2, status: 'already_invited'),
        ],
      );
      bloc.add(const SendInvitationsEvent(gameId: 5, userIds: [1, 2]));
      await _settle();
      expect(ds.lastInvitedIds, [1, 2]);
      expect(bloc.results[1]?.status, 'invited');
      expect(bloc.results[2]?.status, 'already_invited');
      expect(bloc.state, isA<InviteFriendsLoaded>()); // reloaded after sending
    });

    test('nothing is sent with an empty selection', () async {
      bloc.add(const SendInvitationsEvent(gameId: 5, userIds: []));
      await _settle();
      expect(ds.inviteCalls, 0);
    });

    test('a 422 (game full / closed) is reported', () async {
      ds.inviteReply = const ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(message: 'full', statusCode: 422),
      );
      bloc.add(const SendInvitationsEvent(gameId: 5, userIds: [1]));
      await _settle();
      expect(bloc.state, isA<InviteFriendsError>());
      expect((bloc.state as InviteFriendsError).statusCode, 422);
    });
  });
}
