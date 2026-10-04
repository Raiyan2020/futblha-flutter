import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/response_model/diwaniya/diwaniya_type_model.dart';
import '../../models/response_model/diwaniya/diwaniya_model.dart';
import '../../models/response_model/diwaniya/diwaniyas_list_response_model.dart';
import '../../models/response_model/diwaniya/diwaniyas_overview_response_model.dart';
import '../../models/response_model/diwaniya/diwaniya_members_response_model.dart';
import '../../models/response_model/diwaniya/message_model.dart';
import '../../models/response_model/diwaniya/messages_response_model.dart';
import '../../models/response_model/diwaniya/diwaniya_ranking_response_model.dart';
import '../../models/request_model/diwaniya/create_diwaniya_request_model.dart';
import '../../models/request_model/diwaniya/send_message_request_model.dart';
import '../../models/request_model/diwaniya/poll_vote_request_model.dart';
import '../../models/response_model/games/game_history_response_model.dart';

abstract class DiwaniyaRemoteDataSource {
  Future<ApiResultModel<List<DiwaniyaTypeModel>?>> getDiwaniyaTypes();

  Future<ApiResultModel<DiwaniyaModel?>> createDiwaniya({
    required CreateDiwaniyaRequestModel request,
  });

  Future<ApiResultModel<DiwaniyaModel?>> getDiwaniya({required int diwaniyaId});

  Future<ApiResultModel<DiwaniyaModel?>> updateDiwaniya({
    required int diwaniyaId,
    required CreateDiwaniyaRequestModel request,
  });

  Future<ApiResultModel<DiwaniyasListResponseModel?>> getOtherDiwaniyas();

  Future<ApiResultModel<DiwaniyasOverviewResponseModel?>> getDiwaniyasOverview({
    String? type,
    int? membersCount,
    int? rating, // 1 to 5
    String? name,
    int? page,
    int? per_page,
  });

  Future<ApiResultModel<DiwaniyaMembersResponseModel?>> getDiwaniyaMembers({
    required int diwaniyaId,
  });

  Future<ApiResultModel<DiwaniyaMembersResponseModel?>> getJoinRequests({required int diwaniyaId});

  Future<ApiResultModel<String?>> joinDiwaniya({required int diwaniyaId});

  Future<ApiResultModel<String?>> approveJoinRequest({
    required int diwaniyaId,
    required int userId,
  });

  Future<ApiResultModel<String?>> removeMember({required int diwaniyaId, required int userId});

  Future<ApiResultModel<String?>> leaveDiwaniya({required int diwaniyaId});

  Future<ApiResultModel<String?>> deleteDiwaniya({required int diwaniyaId});

  Future<ApiResultModel<MessageModel?>> sendMessage({
    required int diwaniyaId,
    required SendMessageRequestModel request,
  });

  Future<ApiResultModel<MessagesResponseModel?>> getMessages({
    required int diwaniyaId,
    int? page,
  });

  Future<ApiResultModel<String?>> votePoll({required PollVoteRequestModel request});

  Future<ApiResultModel<DiwaniyaRankingResponseModel?>> getDiwaniyaRanking({
    String? date, // "year" or "month"
  });

  Future<ApiResultModel<GameHistoryResponseModel?>> getDiwaniyaGames({
    required int diwaniyaId,
    int? page,
  });
}
