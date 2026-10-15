import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../widgets/snackbar_utill.dart';
import '../bloc/friendship_bloc.dart';

/// قبول / رفض under a `friend_request` notification. The result comes from
/// the backend; an old request (409) is shown as already handled.
class FriendRequestActions extends StatefulWidget {
  const FriendRequestActions({super.key, required this.requestId, this.senderId});

  final int requestId;
  final int? senderId;

  @override
  State<FriendRequestActions> createState() => _FriendRequestActionsState();
}

class _FriendRequestActionsState extends State<FriendRequestActions> {
  final bloc = locator<FriendshipBloc>();
  // Text shown once the request is handled (accepted / rejected / old).
  String? _doneText;

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void _onState(BuildContext context, FriendshipState state) {
    if (state is FriendshipActionSuccess) {
      setState(() {
        _doneText = state.action == FriendshipAction.accept
            ? LocaleKeys.friend_request_accepted_label.tr()
            : LocaleKeys.friend_request_rejected_label.tr();
      });
      context.showMessage(
        state.action == FriendshipAction.accept
            ? LocaleKeys.friend_request_accepted_success.tr()
            : LocaleKeys.friend_request_rejected_success.tr(),
      );
    } else if (state is FriendshipError && state.action != null) {
      if (state.statusCode == conflictStatusCode) {
        setState(() => _doneText = LocaleKeys.friend_request_already_handled.tr());
      }
      context.showMessage(isError: true, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<FriendshipBloc, FriendshipState>(
      bloc: bloc,
      listener: _onState,
      builder: (context, state) {
        if (_doneText != null) {
          return Text(
            _doneText!,
            style: const TextStyle(
              color: AppColors.lightTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        final busy = state is FriendshipActionInProgress;
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: busy
                    ? null
                    : () => bloc.add(
                        AcceptFriendRequestEvent(
                          requestId: widget.requestId,
                          userId: widget.senderId,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: busy && state.action == FriendshipAction.accept
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryWhite,
                        ),
                      )
                    : Text(
                        LocaleKeys.accept_friend_request.tr(),
                        style: const TextStyle(color: AppColors.primaryWhite),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => bloc.add(
                        RejectFriendRequestEvent(
                          requestId: widget.requestId,
                          userId: widget.senderId,
                        ),
                      ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  side: const BorderSide(color: AppColors.primaryRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: busy && state.action == FriendshipAction.reject
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(LocaleKeys.reject.tr()),
              ),
            ),
          ],
        );
      },
    );
  }
}
