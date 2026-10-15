import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../data/datasources/friends_remote_datasource/friends_remote_datasource.dart';
import '../../../../data/models/response_model/friends/invitable_friend_model.dart';
import '../../../../data/models/response_model/friends/invite_result_model.dart';

part 'invite_friends_event.dart';
part 'invite_friends_state.dart';

/// Friends that can be invited to a game, and sending the invitations.
@injectable
class InviteFriendsBloc extends Bloc<InviteFriendsEvent, InviteFriendsState> {
  InviteFriendsBloc(this._remoteDataSource) : super(InviteFriendsInitial()) {
    on<LoadInvitableFriendsEvent>(_load);
    on<SendInvitationsEvent>(_send);
  }

  final FriendsRemoteDataSource _remoteDataSource;

  List<InvitableFriendModel> friends = [];
  // Last per-friend results from the backend, by user id.
  Map<int, InviteResultModel> results = {};
  bool _sending = false;
  bool get isSending => _sending;

  Future<void> _load(LoadInvitableFriendsEvent event, Emitter<InviteFriendsState> emit) async {
    emit(InviteFriendsLoading());
    final result = await _remoteDataSource.getInvitableFriends(gameId: event.gameId);
    result.when(
      success: (data) {
        friends = data ?? [];
        emit(InviteFriendsLoaded());
      },
      failure: (error) => emit(
        InviteFriendsError(
          message: error.message ?? errorMessage,
          statusCode: error.statusCode,
          loadFailed: true,
        ),
      ),
    );
  }

  Future<void> _send(SendInvitationsEvent event, Emitter<InviteFriendsState> emit) async {
    if (_sending || event.userIds.isEmpty) return;
    _sending = true;
    emit(InviteFriendsSending());
    final result = await _remoteDataSource.inviteFriends(
      gameId: event.gameId,
      userIds: event.userIds,
    );
    _sending = false;
    result.when(
      success: (data) {
        results = {
          for (final r in data ?? const <InviteResultModel>[])
            if (r.userId != null) r.userId!: r,
        };
        emit(InviteFriendsSent());
        // Show each friend's state as the backend now has it.
        add(LoadInvitableFriendsEvent(gameId: event.gameId));
      },
      failure: (error) => emit(
        InviteFriendsError(message: error.message ?? errorMessage, statusCode: error.statusCode),
      ),
    );
  }
}
