import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../data/datasources/friends_remote_datasource/friends_remote_datasource.dart';
import '../../../../data/models/enums/friendship_status.dart';
import '../../../../data/models/response_model/friends/friendship_status_model.dart';

part 'friendship_event.dart';
part 'friendship_state.dart';

/// Friendship with one user, always taken from the backend's answer.
@injectable
class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  FriendshipBloc(this._remoteDataSource) : super(FriendshipInitial()) {
    on<LoadFriendshipEvent>(_load);
    on<SendFriendRequestEvent>(_send);
    on<AcceptFriendRequestEvent>(_accept);
    on<RejectFriendRequestEvent>(_reject);
  }

  final FriendsRemoteDataSource _remoteDataSource;

  FriendshipStatus? status;
  int? friendRequestId;
  // Set while a send / accept / reject request is running, so repeated taps
  // can't send it twice.
  bool _busy = false;
  bool get isBusy => _busy;

  Future<void> _load(LoadFriendshipEvent event, Emitter<FriendshipState> emit) async {
    emit(FriendshipLoading());
    final result = await _remoteDataSource.getFriendshipStatus(userId: event.userId);
    result.when(
      success: (data) {
        _apply(data);
        emit(FriendshipLoaded());
      },
      failure: (error) => emit(
        FriendshipError(
          message: error.message ?? errorMessage,
          statusCode: error.statusCode,
          loadFailed: true,
        ),
      ),
    );
  }

  Future<void> _send(SendFriendRequestEvent event, Emitter<FriendshipState> emit) => _runAction(
    emit,
    FriendshipAction.send,
    () => _remoteDataSource.sendFriendRequest(userId: event.userId),
    reloadUserId: event.userId,
  );

  Future<void> _accept(AcceptFriendRequestEvent event, Emitter<FriendshipState> emit) => _runAction(
    emit,
    FriendshipAction.accept,
    () => _remoteDataSource.acceptFriendRequest(requestId: event.requestId),
    reloadUserId: event.userId,
  );

  Future<void> _reject(RejectFriendRequestEvent event, Emitter<FriendshipState> emit) => _runAction(
    emit,
    FriendshipAction.reject,
    () => _remoteDataSource.rejectFriendRequest(requestId: event.requestId),
    reloadUserId: event.userId,
  );

  Future<void> _runAction(
    Emitter<FriendshipState> emit,
    FriendshipAction action,
    Future<ApiResultModel<FriendshipStatusModel?>> Function() call, {
    int? reloadUserId,
  }) async {
    if (_busy) return;
    _busy = true;
    emit(FriendshipActionInProgress(action));
    final result = await call();
    _busy = false;
    result.when(
      success: (data) {
        _apply(data);
        emit(FriendshipActionSuccess(action));
      },
      failure: (error) {
        emit(
          FriendshipError(
            message: error.message ?? errorMessage,
            statusCode: error.statusCode,
            action: action,
          ),
        );
        // 409: already sent / already friends / already handled. Show the
        // real state instead of guessing it.
        if (error.statusCode == conflictStatusCode && reloadUserId != null) {
          add(LoadFriendshipEvent(userId: reloadUserId));
        }
      },
    );
  }

  void _apply(FriendshipStatusModel? data) {
    status = data?.status;
    friendRequestId = data?.friendRequestId;
  }
}
