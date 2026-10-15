import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/config/design_system/app_theme_colors.dart';
import '../../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../../data/models/enums/friendship_status.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../widgets/snackbar_utill.dart';
import '../bloc/friendship_bloc.dart';

/// Add-friend control for a user's profile card. Loads the friendship status
/// from the backend and shows: add friend, request sent, accept / reject an
/// incoming request, or friends. Hidden on the current user's own card.
class FriendshipActionButton extends StatefulWidget {
  const FriendshipActionButton({super.key, required this.userId});

  final int userId;

  /// Whether [userId] is the logged-in user (no friend actions on yourself).
  static bool isCurrentUser(int userId) => CacheManager.instance.getUserId() == userId.toString();

  @override
  State<FriendshipActionButton> createState() => _FriendshipActionButtonState();
}

class _FriendshipActionButtonState extends State<FriendshipActionButton> {
  final bloc = locator<FriendshipBloc>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => bloc.add(LoadFriendshipEvent(userId: widget.userId));

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void _onState(BuildContext context, FriendshipState state) {
    if (state is FriendshipActionSuccess) {
      context.showMessage(switch (state.action) {
        FriendshipAction.send => LocaleKeys.friend_request_sent_success.tr(),
        FriendshipAction.accept => LocaleKeys.friend_request_accepted_success.tr(),
        FriendshipAction.reject => LocaleKeys.friend_request_rejected_success.tr(),
      });
    } else if (state is FriendshipError && !state.loadFailed) {
      context.showMessage(isError: true, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<FriendshipBloc, FriendshipState>(
      bloc: bloc,
      listener: _onState,
      builder: (context, state) {
        if (state is FriendshipInitial || state is FriendshipLoading) {
          return const _Spinner();
        }
        if (state is FriendshipError && state.loadFailed) {
          return _RoundIcon(
            icon: Icons.refresh,
            tooltip: LocaleKeys.friendship_load_failed.tr(),
            color: AppColors.primaryRed,
            onTap: _load,
          );
        }
        final busy = state is FriendshipActionInProgress;
        switch (bloc.status) {
          case FriendshipStatus.none:
            return busy
                ? const _Spinner()
                : _RoundIcon(
                    icon: Icons.person_add_alt_1,
                    tooltip: LocaleKeys.add_friend.tr(),
                    color: context.brandOnSurface,
                    onTap: () => bloc.add(SendFriendRequestEvent(userId: widget.userId)),
                  );
          case FriendshipStatus.requestSent:
            return _Label(
              icon: Icons.schedule,
              text: LocaleKeys.friend_request_sent.tr(),
              color: AppColors.lightTextColor,
            );
          case FriendshipStatus.requestReceived:
            final requestId = bloc.friendRequestId;
            if (requestId == null) return const SizedBox.shrink();
            if (busy) return const _Spinner();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundIcon(
                  icon: Icons.check,
                  tooltip: LocaleKeys.accept_friend_request.tr(),
                  color: AppColors.primaryColor,
                  onTap: () => bloc.add(
                    AcceptFriendRequestEvent(requestId: requestId, userId: widget.userId),
                  ),
                ),
                const SizedBox(width: 8),
                _RoundIcon(
                  icon: Icons.close,
                  tooltip: LocaleKeys.reject.tr(),
                  color: AppColors.primaryRed,
                  onTap: () => bloc.add(
                    RejectFriendRequestEvent(requestId: requestId, userId: widget.userId),
                  ),
                ),
              ],
            );
          case FriendshipStatus.friends:
            return _Label(
              icon: Icons.people,
              text: LocaleKeys.friends.tr(),
              color: context.brandOnSurface,
            );
          case FriendshipStatus.self:
          case null:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 40,
      child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, color: color, size: 22)),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
