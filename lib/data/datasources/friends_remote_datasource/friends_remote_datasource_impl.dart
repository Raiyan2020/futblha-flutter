import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/constants/app_constants.dart';
import '../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/response_model/friends/friendship_status_model.dart';
import '../../models/response_model/friends/invitable_friend_model.dart';
import '../../models/response_model/friends/invite_result_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import '../../network/dio_strategy_helper/dio_request_strategy.dart';
import 'friends_remote_datasource.dart';

@Injectable(as: FriendsRemoteDataSource)
class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  FriendsRemoteDataSourceImpl(this._apiCallHelper);

  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> getFriendshipStatus({required int userId}) =>
      _request(
        uri: '$Users/$userId/friendship',
        strategy: locator<GetRequestStrategy>(),
        parse: (data) => FriendshipStatusModel.fromJson(Map<String, dynamic>.from(data)),
      );

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> sendFriendRequest({required int userId}) =>
      _request(
        uri: FriendRequests,
        strategy: locator<PostRequestStrategy>(),
        formData: FormData.fromMap({'user_id': userId.toString()}),
        parse: (data) => FriendshipStatusModel.fromActionJson(Map<String, dynamic>.from(data)),
      );

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> acceptFriendRequest({required int requestId}) =>
      _request(
        uri: '$FriendRequests/$requestId/accept',
        strategy: locator<PostRequestStrategy>(),
        parse: (data) => FriendshipStatusModel.fromActionJson(Map<String, dynamic>.from(data)),
      );

  @override
  Future<ApiResultModel<FriendshipStatusModel?>> rejectFriendRequest({required int requestId}) =>
      _request(
        uri: '$FriendRequests/$requestId/reject',
        strategy: locator<PostRequestStrategy>(),
        parse: (data) => FriendshipStatusModel.fromActionJson(Map<String, dynamic>.from(data)),
      );

  @override
  Future<ApiResultModel<List<InvitableFriendModel>?>> getInvitableFriends({required int gameId}) =>
      _request(
        uri: '$Games/$gameId/invitable-friends',
        strategy: locator<GetRequestStrategy>(),
        parse: (data) => (data as List)
            .map((e) => InvitableFriendModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  @override
  Future<ApiResultModel<List<InviteResultModel>?>> inviteFriends({
    required int gameId,
    required List<int> userIds,
  }) => _request(
    uri: '$Games/$gameId/invite-friends',
    strategy: locator<PostRequestStrategy>(),
    formData: FormData.fromMap({
      for (var i = 0; i < userIds.length; i++) 'user_ids[$i]': userIds[i].toString(),
    }),
    parse: (data) => (data as List)
        .map((e) => InviteResultModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  /// Calls [uri] and parses `response.data['data']` with [parse].
  Future<ApiResultModel<T?>> _request<T>({
    required String uri,
    required DioRequestStrategy strategy,
    required T Function(dynamic data) parse,
    FormData? formData,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: strategy,
        uri: uri,
        formData: formData,
      );
      return result.when(
        success: (Response response) {
          final data = response.data is Map ? response.data['data'] : null;
          if (data == null) return ApiResultModel<T?>.success(data: null);
          return ApiResultModel<T?>.success(data: parse(data));
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<T?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }
}
