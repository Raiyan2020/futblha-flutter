import 'package:auto_route/annotations.dart';
import 'package:futblha/presentation/pages/notifications/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../data/models/request_model/notifications/notifications_request_model.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/custom_empty_widget.dart';
import '../../widgets/custom_loading_widget.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/custom_toolbar.dart';
import '../../widgets/pagination_list.dart';
import '../../widgets/scaffold_pading.dart';
import 'bloc/notifications_bloc.dart';

@RoutePage()
class NotificationsPage extends StatelessWidget {
  NotificationsPage({super.key});
  final NotificationsBloc bloc = locator<NotificationsBloc>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: const CustomAppBar(
        title: LocaleKeys.notifications,
      ),
      body: CustomBlocConsumer<NotificationsBloc, NotificationsState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is ClearNotificationsSuccess) {
            context.showMessage(LocaleKeys.process_completed_successfully);
          }
          // if (state is NotificationsErrorState) {
          //   context.showMessage(state.message, isError: true);
          // }
        },
        onInitState: (bloc) async {
          bloc.add(GetNotificationsEvent(model: NotificationsRequestModel()));
        },
        builder: (context, state) {
          if (state is GetNotificationsLoading) {
            return const LoadingWidget();
          }
          return bloc.notifications.isEmpty
              ? const EmptyWidget()
              : PaginationList(
                  itemCount: bloc.notifications.length,
                  animateItems: true,
                  padding: symmetricPadding(10, 10),
                  reachedMax: bloc.reachMaX,
                  onReachBottom: () => bloc.add(const GetNotificationsEvent(more: true)),
                  itemBuilder: (BuildContext context, int index) {
                    final notification = bloc.notifications[index];
                    return Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.9,
                      child: NotificationCard(model: notification),
                    );
                  },
                );
        },
      ),
    );
  }
}
