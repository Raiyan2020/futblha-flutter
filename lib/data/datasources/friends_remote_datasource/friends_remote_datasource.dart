import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/response_model/friends/friendship_status_model.dart';
import '../../models/response_model/friends/invitable_friend_model.dart';
import '../../models/response_model/friends/invite_result_model.dart';

/// Friends and match invitations. Follows the proposed contract in
/// BACKEND_TASKS_FRIENDS_AND_MATCH_INVITES.md (F1b, F2–F4, M1, M2).
abstract class FriendsRemoteDataSource {
  Future<ApiResultModel<FriendshipStatusModel?>> getFriendshipStatus({required int userId});

  Future<ApiResultModel<FriendshipStatusModel?>> sendFriendRequest({required int userId});

  Future<ApiResultModel<FriendshipStatusModel?>> acceptFriendRequest({required int requestId});

  Future<ApiResultModel<FriendshipStatusModel?>> rejectFriendRequest({required int requestId});

  Future<ApiResultModel<List<InvitableFriendModel>?>> getInvitableFriends({required int gameId});

  Future<ApiResultModel<List<InviteResultModel>?>> inviteFriends({
    required int gameId,
    required List<int> userIds,
  });
}
