import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../../data/models/response_model/diwaniya/diwaniya_member_model.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/app_size_boxes.dart';
import '../../widgets/snackbar_utill.dart';
import 'bloc/diwaniya_bloc.dart';

@RoutePage()
class JoinRequestsPage extends StatefulWidget {
  const JoinRequestsPage({super.key, required this.diwaniyaBloc});
  final DiwaniyaBloc diwaniyaBloc;

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  late final bloc = widget.diwaniyaBloc;

  @override
  void initState() {
    super.initState();
    _loadJoinRequests();
  }

  void _loadJoinRequests() {
    final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
    if (diwaniya?.id != null) {
      bloc.add(GetJoinRequestsEvent(diwaniyaId: diwaniya!.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        } else if (state is ApproveJoinRequestSuccess) {
          context.showMessage(state.message);
          // Refresh after approval
          _loadJoinRequests();
        }
      },
      builder: (context, state) {
        final joinRequests = bloc.joinRequests?.items ?? [];

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.join_requests.tr())),
          body: state is DiwaniyaMembersLoading
              ? const Center(child: CircularProgressIndicator())
              : joinRequests.isNotEmpty
              ? ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                  itemBuilder: (context, index) => _JoinRequestTile(
                    member: joinRequests[index],
                    queueNumber: index + 1,
                    bloc: bloc,
                  ),
                  separatorBuilder: (_, _) => 12.heightBox(),
                  itemCount: joinRequests.length,
                )
              : Center(
                  child: Text(
                    LocaleKeys.no_join_requests_found.tr(),
                    style: const TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                  ),
                ),
        );
      },
    );
  }
}

class _JoinRequestTile extends StatelessWidget {
  const _JoinRequestTile({required this.member, required this.queueNumber, required this.bloc});
  final DiwaniyaBloc bloc;

  final DiwaniyaMemberModel member;
  final int queueNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '#$queueNumber',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.widthBox(),
          _buildAvatar(),
          12.widthBox(),
          Expanded(
            child: Text(
              member.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildActionIcon(
            icon: Icons.close,
            color: AppColors.primaryRed,
            onTap: () {
              final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
              if (diwaniya?.id != null && member.id != null) {
                bloc.add(RemoveMemberEvent(diwaniyaId: diwaniya!.id!, userId: member.id!));
              }
            },
          ),
          8.widthBox(),
          _buildActionIcon(
            icon: Icons.check,
            color: AppColors.primaryColor,
            onTap: () {
              // Approve join request
              final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
              if (diwaniya?.id != null && member.id != null) {
                bloc.add(ApproveJoinRequestEvent(diwaniyaId: diwaniya!.id!, userId: member.id!));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: member.image != null
            ? Image.network(
                member.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLiteGrey,
                    child: const Icon(Icons.person, color: AppColors.primaryColor),
                  );
                },
              )
            : Image.asset(
                AppAssets.ic_profile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLiteGrey,
                    child: const Icon(Icons.person, color: AppColors.primaryColor),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
          color: color.withValues(alpha: 0.08),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
