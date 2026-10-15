import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/config/design_system/app_theme_colors.dart';
import '../../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../../../data/models/response_model/friends/invitable_friend_model.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../widgets/snackbar_utill.dart';
import '../bloc/invite_friends_bloc.dart';

/// دعوة الأصدقاء: the user's friends for this game, as the backend reports
/// them (can invite / in the game / already invited / not eligible).
/// Invited friends still join the game themselves; nothing is joined here.
class InviteFriendsBottomSheet extends StatefulWidget {
  const InviteFriendsBottomSheet({super.key, required this.gameId});

  final int gameId;

  static Future<void> show(BuildContext context, int gameId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InviteFriendsBottomSheet(gameId: gameId),
    );
  }

  /// Label for a friend who can't be selected, from `invite_status`.
  static String? statusLabelKey(String? inviteStatus) => switch (inviteStatus) {
    'already_member' => LocaleKeys.invite_status_already_member,
    'already_invited' => LocaleKeys.invite_status_already_invited,
    'invited' => LocaleKeys.invite_status_invited,
    'not_eligible' => LocaleKeys.invite_status_not_eligible,
    _ => null,
  };

  @override
  State<InviteFriendsBottomSheet> createState() => _InviteFriendsBottomSheetState();
}

class _InviteFriendsBottomSheetState extends State<InviteFriendsBottomSheet> {
  final bloc = locator<InviteFriendsBloc>();
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => bloc.add(LoadInvitableFriendsEvent(gameId: widget.gameId));

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void _onState(BuildContext context, InviteFriendsState state) {
    if (state is InviteFriendsSent) {
      setState(_selected.clear);
      context.showMessage(LocaleKeys.invitations_sent.tr());
    } else if (state is InviteFriendsError && !state.loadFailed) {
      // 403 not allowed / 422 game full or closed: the backend's message.
      context.showMessage(isError: true, state.message);
    } else if (state is InviteFriendsLoaded) {
      // Drop selections that can no longer be invited.
      final invitable = bloc.friends.where((f) => f.canInvite).map((f) => f.id).toSet();
      setState(() => _selected.removeWhere((id) => !invitable.contains(id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: CustomBlocConsumer<InviteFriendsBloc, InviteFriendsState>(
          bloc: bloc,
          listener: _onState,
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.mutedBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    LocaleKeys.invite_friends.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Flexible(child: _buildBody(state)),
                if (bloc.friends.any((f) => f.canInvite))
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selected.isEmpty || bloc.isSending
                            ? null
                            : () => bloc.add(
                                SendInvitationsEvent(
                                  gameId: widget.gameId,
                                  userIds: _selected.toList(),
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state is InviteFriendsSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryWhite,
                                ),
                              )
                            : Text(
                                LocaleKeys.send_invitations.tr(
                                  namedArgs: {'count': '${_selected.length}'},
                                ),
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(InviteFriendsState state) {
    if (state is InviteFriendsInitial || (state is InviteFriendsLoading && bloc.friends.isEmpty)) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state is InviteFriendsError && state.loadFailed) {
      return _Message(
        text: state.message.isNotEmpty ? state.message : LocaleKeys.failed_to_load_friends.tr(),
        onRetry: _load,
      );
    }
    if (bloc.friends.isEmpty) {
      return _Message(text: LocaleKeys.no_friends_to_invite.tr());
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: bloc.friends.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => _buildFriend(bloc.friends[index]),
    );
  }

  Widget _buildFriend(InvitableFriendModel friend) {
    final id = friend.id;
    final selectable = friend.canInvite && id != null && !bloc.isSending;
    final selected = id != null && _selected.contains(id);
    final labelKey = InviteFriendsBottomSheet.statusLabelKey(friend.inviteStatus);

    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: selectable
            ? () => setState(() => selected ? _selected.remove(id) : _selected.add(id))
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.mutedBackground,
                backgroundImage: friend.image != null && friend.image!.isNotEmpty
                    ? NetworkImage(friend.image!)
                    : null,
                onBackgroundImageError: friend.image != null && friend.image!.isNotEmpty
                    ? (_, _) {}
                    : null,
                child: friend.image == null || friend.image!.isEmpty
                    ? Icon(Icons.person, color: context.brandOnSurface)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!friend.canInvite && (friend.reason?.isNotEmpty ?? false))
                      Text(
                        friend.reason!,
                        style: const TextStyle(color: AppColors.lightTextColor, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (friend.canInvite)
                Checkbox(
                  value: selected,
                  activeColor: AppColors.primaryColor,
                  onChanged: selectable
                      ? (_) => setState(() => selected ? _selected.remove(id) : _selected.add(id))
                      : null,
                )
              else if (labelKey != null)
                Text(
                  labelKey.tr(),
                  style: TextStyle(
                    color: friend.inviteStatus == 'not_eligible'
                        ? AppColors.lightTextColor
                        : context.brandOnSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.lightTextColor, fontSize: 14),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: context.brandOnSurface),
              child: Text(LocaleKeys.retry.tr()),
            ),
        ],
      ),
    );
  }
}
