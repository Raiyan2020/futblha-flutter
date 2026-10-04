import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/notifications_remote_datasource/notifications_remote_datasource.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../../data/models/request_model/notifications/notifications_request_model.dart';
import '../../../../data/models/response_model/notifications/notifications_response_model.dart';
import '../../../../data/models/response_model/notifications/unread_count_model.dart';


part 'notifications_event.dart';
part 'notifications_state.dart';

@Singleton()
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRemoteDataSource _remoteDataSource;
  NotificationsBloc(this._remoteDataSource) : super(NotificationsInitial()) {
    on<NotificationsEvent>((event, emit) {});
    on<GetNotificationsEvent>(_getNotifications);
    on<MarkAllAsReadEvent>(_markAllAsRead);
    on<ClearNotificationsEvent>(_clearNotifications);
    on<GetUnreadCountEvent>(_getUnreadCount);
    on<MarkNotificationReadEvent>(_markNotificationRead);
  }

  // Guests have no token; a 401 from these calls would trigger a logout.
  bool get _isLoggedIn => CacheManager.instance.getAuthToken().isNotEmpty && !CacheManager.instance.isGuestMode();

  List<NotificationModel> notifications = [];
  bool reachMaX = true;
  int page = 1;

  Future<void> _getNotifications(GetNotificationsEvent event, Emitter<NotificationsState> emit) async {
    if (event.more) {
      page++;
    } else {
      page = 1;
    //  add(MarkAllAsReadEvent());
      emit(GetNotificationsLoading());
    }
    final ApiResultModel<NotificationsResponseModel?> apiResult = await _remoteDataSource.getNotifications(
    model:  NotificationsRequestModel(pageNumber: page, pageSize: 20),
    );
    apiResult.when(
      success: (NotificationsResponseModel? data) {
        if (event.more) {
          notifications.addAll(data?.data ?? []); // Changed from result to data
        } else {
          notifications = data?.data ?? []; // Changed from result to data
        }
        if (data?.pagination?.total != null) { // Changed from totalCount to pagination?.total
          reachMaX = data?.pagination?.total == notifications.length; // Changed from totalCount to pagination?.total
        }
        emit(GetNotificationsSuccess());
      },
      failure: (ErrorResultModel error) => emit(NotificationsErrorState(error.message ?? 'error')),
    );
  }

  Future<void> _markAllAsRead(MarkAllAsReadEvent event, Emitter<NotificationsState> emit) async {
    emit(ReadNotificationsLoading());

    final ApiResultModel<String?> apiResult = await _remoteDataSource.markAllNotificationsRead();

    apiResult.when(
      success: (String? data) {
        for (final notification in notifications) {
          notification.isRead = 1;
        }
        add(GetUnreadCountEvent());
        emit(ReadNotificationsSuccess());
      },
      failure: (ErrorResultModel error) => emit(NotificationsErrorState(error.message ?? 'error')),
    );
  }

  Future<void> _clearNotifications(ClearNotificationsEvent event, Emitter<NotificationsState> emit) async {
    emit(ClearNotificationsLoading());
    final ApiResultModel<String?> apiResult = await _remoteDataSource.clearNotifications();
    apiResult.when(
      success: (String? data) {
        add(const GetNotificationsEvent());
        emit(ClearNotificationsSuccess());
      },
      failure: (ErrorResultModel error) => emit(NotificationsErrorState(error.message ?? 'error')),
    );
  }

  int unreadCount = 0;
  int pendingInvitationsCount = 0;

  Future<void> _getUnreadCount(GetUnreadCountEvent event, Emitter<NotificationsState> emit) async {
    if (!_isLoggedIn) {
      unreadCount = 0;
      pendingInvitationsCount = 0;
      emit(GetUnreadCountSuccess());
      return;
    }
    emit(GetUnreadCountLoading());
    final ApiResultModel<UnreadCountModel?> apiResult = await _remoteDataSource.getUnReadCount();
    apiResult.when(
      success: (UnreadCountModel? data) {
        unreadCount = data?.unreadCount ?? 0;
        pendingInvitationsCount = data?.pendingInvitationsCount ?? 0;
        emit(GetUnreadCountSuccess());
      },
      failure: (ErrorResultModel error) => emit(NotificationsErrorState(error.message ?? 'error')),
    );
  }

  Future<void> _markNotificationRead(MarkNotificationReadEvent event, Emitter<NotificationsState> emit) async {
    if (!_isLoggedIn) return;
    // Update the list immediately so the card loses its unread style on tap.
    for (final notification in notifications.where((n) => n.id == event.id)) {
      notification.isRead = 1;
    }
    emit(ReadNotificationsSuccess());
    final ApiResultModel<String?> apiResult = await _remoteDataSource.markNotificationRead(id: event.id);
    apiResult.when(
      success: (String? data) => add(GetUnreadCountEvent()),
      failure: (ErrorResultModel error) => emit(NotificationsErrorState(error.message ?? 'error')),
    );
  }
}
