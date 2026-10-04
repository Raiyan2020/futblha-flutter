import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../auth/bloc/authentication_bloc.dart';
import '../../../../data/datasources/diwaniya_remote_datasource/diwaniya_remote_datasource.dart';
import '../../../../data/models/response_model/diwaniya/diwaniya_type_model.dart';
import '../../../../data/models/response_model/diwaniya/diwaniya_model.dart';
import '../../../../data/models/response_model/diwaniya/diwaniyas_list_response_model.dart';
import '../../../../data/models/response_model/diwaniya/diwaniyas_overview_response_model.dart';
import '../../../../data/models/response_model/diwaniya/diwaniya_members_response_model.dart';
import '../../../../data/models/response_model/diwaniya/message_model.dart';
import '../../../../data/models/response_model/diwaniya/messages_response_model.dart';
import '../../../../data/models/response_model/diwaniya/diwaniya_ranking_response_model.dart';
import '../../../../data/models/response_model/games/game_model.dart';
import '../../../../data/models/response_model/games/game_history_response_model.dart';
import '../../../../data/models/response_model/diwaniya/paginate_model.dart';
import '../../../../data/models/request_model/diwaniya/create_diwaniya_request_model.dart';
import '../../../../data/models/request_model/diwaniya/send_message_request_model.dart';
import '../../../../data/models/request_model/diwaniya/poll_vote_request_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';

part 'diwaniya_event.dart';
part 'diwaniya_state.dart';

@injectable
class DiwaniyaBloc extends Bloc<DiwaniyaEvent, DiwaniyaState> {
  final DiwaniyaRemoteDataSource _remoteDataSource;
  final AuthenticationBloc _authBloc;

  // Data stored in bloc
  List<DiwaniyaTypeModel> diwaniyaTypes = [];
  DiwaniyaModel? myDiwaniya;
  DiwaniyaModel? diwaniyaDetails;
  DiwaniyasListResponseModel? otherDiwaniyas;
  DiwaniyasOverviewResponseModel? diwaniyasOverviewResponse;
  DiwaniyasListResponseModel? diwaniyasOverview; // For backward compatibility
  DiwaniyaMembersResponseModel? diwaniyaMembers;
  DiwaniyaMembersResponseModel? joinRequests;
  MessagesResponseModel? messages;
  bool messagesLoadingMore = false;
  DiwaniyaRankingResponseModel? diwaniyaRanking;
  List<GameModel> diwaniyaGames = [];
  PaginateModel? diwaniyaGamesPagination;
  bool diwaniyaGamesReachedMax = false;

  DiwaniyaBloc(this._remoteDataSource, this._authBloc) : super(DiwaniyaInitial()) {
    on<GetDiwaniyaTypesEvent>(_getDiwaniyaTypes);
    on<GetDiwaniyaEvent>(_getDiwaniya);
    on<CreateDiwaniyaEvent>(_createDiwaniya);
    on<UpdateDiwaniyaEvent>(_updateDiwaniya);
    on<GetOtherDiwaniyasEvent>(_getOtherDiwaniyas);
    on<GetDiwaniyasOverviewEvent>(_getDiwaniyasOverview);
    on<GetDiwaniyaMembersEvent>(_getDiwaniyaMembers);
    on<GetJoinRequestsEvent>(_getJoinRequests);
    on<JoinDiwaniyaEvent>(_joinDiwaniya);
    on<LeaveDiwaniyaEvent>(_leaveDiwaniya);
    on<DeleteDiwaniyaEvent>(_deleteDiwaniya);
    on<ApproveJoinRequestEvent>(_approveJoinRequest);
    on<RemoveMemberEvent>(_removeMember);
    on<SendMessageEvent>(_sendMessage);
    on<GetMessagesEvent>(_getMessages);
    on<VotePollEvent>(_votePoll);
    on<GetDiwaniyaRankingEvent>(_getDiwaniyaRanking);
    on<GetDiwaniyaGamesEvent>(_getDiwaniyaGames);
    on<MessageReceivedEvent>(_messageReceived);
  }

  Future<void> _getDiwaniyaTypes(GetDiwaniyaTypesEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<List<DiwaniyaTypeModel>?> result = await _remoteDataSource
        .getDiwaniyaTypes();
    result.when(
      success: (data) {
        if (data != null) {
          diwaniyaTypes = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getDiwaniya(GetDiwaniyaEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<DiwaniyaModel?> result = await _remoteDataSource.getDiwaniya(
      diwaniyaId: event.diwaniyaId,
    );
    result.when(
      success: (data) {
        if (data != null) {
          diwaniyaDetails = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _createDiwaniya(CreateDiwaniyaEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<DiwaniyaModel?> result = await _remoteDataSource.createDiwaniya(
      request: event.request,
    );
    result.when(
      success: (data) {
        if (data != null) {
          myDiwaniya = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _updateDiwaniya(UpdateDiwaniyaEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<DiwaniyaModel?> result = await _remoteDataSource.updateDiwaniya(
      diwaniyaId: event.diwaniyaId,
      request: event.request,
    );
    result.when(
      success: (data) {
        if (data != null) {
          myDiwaniya = data;
          diwaniyaDetails = data;
          emit(UpdateDiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getOtherDiwaniyas(GetOtherDiwaniyasEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<DiwaniyasListResponseModel?> result = await _remoteDataSource
        .getOtherDiwaniyas();
    result.when(
      success: (data) {
        if (data != null) {
          otherDiwaniyas = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getDiwaniyasOverview(
    GetDiwaniyasOverviewEvent event,
    Emitter<DiwaniyaState> emit,
  ) async {
    if (!event.loadMore) {
      emit(DiwaniyaLoading());
    }
    final ApiResultModel<DiwaniyasOverviewResponseModel?> result = await _remoteDataSource
        .getDiwaniyasOverview(
          type: event.type,
          membersCount: event.membersCount,
          rating: event.rating,
          name: event.name,
          page: event.page,
          per_page: event.perPage,
        );
    result.when(
      success: (data) {
        if (data != null) {
          diwaniyasOverviewResponse = data;
          // Extract myDiwaniya from the response
          myDiwaniya = data.myDiwaniya;
          // Keep auth bloc in sync so join-game can use it for team restriction
          _authBloc.add(UpdateMyDiwaniyaEvent(data.myDiwaniya));

          // Handle pagination: append items if loadMore is true
          if (event.loadMore && otherDiwaniyas != null && data.otherDiwaniyas != null) {
            final existingItems = otherDiwaniyas!.items ?? [];
            final newItems = data.otherDiwaniyas!.items ?? [];
            otherDiwaniyas = DiwaniyasListResponseModel(
              items: [...existingItems, ...newItems],
              paginate: data.otherDiwaniyas!.paginate,
              extra: data.otherDiwaniyas!.extra,
            );
            diwaniyasOverview = otherDiwaniyas;
          } else {
            // Set diwaniyasOverview to otherDiwaniyas for backward compatibility
            diwaniyasOverview = data.otherDiwaniyas;
            otherDiwaniyas = data.otherDiwaniyas;
          }
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getDiwaniyaMembers(
    GetDiwaniyaMembersEvent event,
    Emitter<DiwaniyaState> emit,
  ) async {
    emit(DiwaniyaMembersLoading());
    final ApiResultModel<DiwaniyaMembersResponseModel?> result = await _remoteDataSource
        .getDiwaniyaMembers(diwaniyaId: event.diwaniyaId);
    result.when(
      success: (data) {
        if (data != null) {
          diwaniyaMembers = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getJoinRequests(GetJoinRequestsEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaMembersLoading());
    final ApiResultModel<DiwaniyaMembersResponseModel?> result = await _remoteDataSource
        .getJoinRequests(diwaniyaId: event.diwaniyaId);
    result.when(
      success: (data) {
        if (data != null) {
          joinRequests = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _joinDiwaniya(JoinDiwaniyaEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.joinDiwaniya(
      diwaniyaId: event.diwaniyaId,
    );
    result.when(
      success: (data) {
        emit(JoinDiwaniyaSuccess(message: data ?? ''));
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _leaveDiwaniya(LeaveDiwaniyaEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.leaveDiwaniya(
      diwaniyaId: event.diwaniyaId,
    );
    result.when(
      success: (data) {
        myDiwaniya = null;
        add(GetDiwaniyasOverviewEvent());
        emit(LeaveDiwaniyaSuccess(message: data ?? ''));
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _deleteDiwaniya(DeleteDiwaniyaEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.deleteDiwaniya(
      diwaniyaId: event.diwaniyaId,
    );
    result.when(
      success: (data) {
        myDiwaniya = null;
        add(GetDiwaniyasOverviewEvent());
        emit(DeleteDiwaniyaSuccess(message: data ?? ''));
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _approveJoinRequest(
    ApproveJoinRequestEvent event,
    Emitter<DiwaniyaState> emit,
  ) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.approveJoinRequest(
      diwaniyaId: event.diwaniyaId,
      userId: event.userId,
    );
    result.when(
      success: (data) {
        // Refresh join requests list after approval
        add(GetJoinRequestsEvent(diwaniyaId: event.diwaniyaId));
        emit(ApproveJoinRequestSuccess(message: data ?? LocaleKeys.success));
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _removeMember(RemoveMemberEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.removeMember(
      diwaniyaId: event.diwaniyaId,
      userId: event.userId,
    );
    result.when(
      success: (data) {
        // Refresh members list after removal
        add(GetDiwaniyaMembersEvent(diwaniyaId: event.diwaniyaId));
        emit(DiwaniyaSuccess());
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _sendMessage(SendMessageEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<MessageModel?> result = await _remoteDataSource.sendMessage(
      diwaniyaId: event.diwaniyaId,
      request: event.request,
    );
    result.when(
      success: (data) {
        // Refresh messages after sending
        // Pusher will handle real-time updates, and this ensures consistency
        add(GetMessagesEvent(diwaniyaId: event.diwaniyaId, scrollToBottom: true));
        emit(DiwaniyaSuccess());
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getMessages(GetMessagesEvent event, Emitter<DiwaniyaState> emit) async {
    final isLoadMore = event.page != null && event.page! > 1;
    if (isLoadMore) {
      messagesLoadingMore = true;
    } else {
      emit(DiwaniyaLoading());
    }
    final ApiResultModel<MessagesResponseModel?> result = await _remoteDataSource.getMessages(
      diwaniyaId: event.diwaniyaId,
      page: event.page,
    );
    if (isLoadMore) {
      messagesLoadingMore = false;
    }
    result.when(
      success: (data) {
        if (data != null) {
          if (isLoadMore && messages?.items != null && data.items != null) {
            messages = MessagesResponseModel(
              items: [...messages!.items!, ...data.items!],
              paginate: data.paginate,
              extra: data.extra,
            );
          } else {
            messages = data;
          }
          emit(DiwaniyaSuccess(scrollToBottom: event.scrollToBottom));
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _votePoll(VotePollEvent event, Emitter<DiwaniyaState> emit) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.votePoll(request: event.request);
    result.when(
      success: (data) {
        // Refresh messages after voting to get updated vote counts
        add(GetMessagesEvent(diwaniyaId: event.diwaniyaId));
        emit(DiwaniyaSuccess());
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getDiwaniyaRanking(
    GetDiwaniyaRankingEvent event,
    Emitter<DiwaniyaState> emit,
  ) async {
    emit(DiwaniyaLoading());
    final ApiResultModel<DiwaniyaRankingResponseModel?> result = await _remoteDataSource
        .getDiwaniyaRanking(date: event.date);
    result.when(
      success: (data) {
        if (data != null) {
          diwaniyaRanking = data;
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getDiwaniyaGames(GetDiwaniyaGamesEvent event, Emitter<DiwaniyaState> emit) async {
    if (event.page == null || event.page == 1) {
      diwaniyaGames = [];
      diwaniyaGamesReachedMax = false;
      diwaniyaGamesPagination = null;
    }
    emit(DiwaniyaLoading());
    final ApiResultModel<GameHistoryResponseModel?> result = await _remoteDataSource
        .getDiwaniyaGames(diwaniyaId: event.diwaniyaId, page: event.page);
    result.when(
      success: (data) {
        if (data != null) {
          if (data.items != null && data.items!.isNotEmpty) {
            if (event.page == null || event.page == 1) {
              diwaniyaGames = data.items!;
            } else {
              diwaniyaGames.addAll(data.items!);
            }
            diwaniyaGamesPagination = data.paginate;
            if (data.paginate != null) {
              final currentPage = data.paginate!.currentPage ?? 1;
              final totalPages = data.paginate!.totalPages ?? 1;
              diwaniyaGamesReachedMax = currentPage >= totalPages;
            } else {
              final itemsCount = data.items!.length;
              diwaniyaGamesReachedMax = itemsCount < 10;
            }
          } else {
            diwaniyaGamesReachedMax = true;
          }
          emit(DiwaniyaSuccess());
        } else {
          emit(const DiwaniyaError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(DiwaniyaError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _messageReceived(MessageReceivedEvent event, Emitter<DiwaniyaState> emit) async {
    // Add message to messages list if it doesn't already exist
    // The duplicate check by ID prevents duplicates regardless of whether it comes from API or Pusher
    if (messages?.items != null) {
      // Check if message already exists (avoid duplicates)
      final messageExists = messages!.items!.any((msg) => msg.id == event.message.id);

      if (!messageExists) {
        // Message doesn't exist, add it
        messages!.items!.insert(0, event.message);
        emit(DiwaniyaSuccess());
      }
    } else {
      // Initialize messages list with the new message
      messages = MessagesResponseModel(items: [event.message]);
      emit(DiwaniyaSuccess());
    }
  }
}
