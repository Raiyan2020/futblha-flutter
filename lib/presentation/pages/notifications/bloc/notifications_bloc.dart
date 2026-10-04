import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/notifications_remote_datasource/notifications_remote_datasource.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../data/models/request_model/notifications/notifications_request_model.dart';
import '../../../../data/models/response_model/notifications/notifications_response_model.dart';


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
  }

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
        unreadCount = 0;
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
        unreadCount = 0;
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

  Future<void> _getUnreadCount(GetUnreadCountEvent event, Emitter<NotificationsState> emit) async {
    emit(GetUnreadCountLoading());
    final ApiResultModel<int?> apiResult = await _remoteDataSource.getUnReadCount();
    apiResult.when(
      success: (int? data) {
        unreadCount = data ?? 0;
        emit(GetUnreadCountSuccess());
      },
      failure: (ErrorResultModel error) => emit(NotificationsErrorState(error.message ?? 'error')),
    );
  }
}