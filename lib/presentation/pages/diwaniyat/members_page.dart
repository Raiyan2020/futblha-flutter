import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class MembersPage extends StatefulWidget {
  const MembersPage({super.key, required this.bloc});
  final DiwaniyaBloc bloc;

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late final bloc = widget.bloc;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
    if (diwaniya?.id != null) {
      bloc.add(GetDiwaniyaMembersEvent(diwaniyaId: diwaniya!.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.members.tr())),
          body: state is DiwaniyaMembersLoading && bloc.diwaniyaMembers == null
              ? const Center(child: CircularProgressIndicator())
              : bloc.diwaniyaMembers?.items != null && bloc.diwaniyaMembers!.items!.isNotEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      children: [
                        ...bloc.diwaniyaMembers!.items!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final member = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildMemberCard(member, index),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    LocaleKeys.no_members_found.tr(),
                    style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMemberCard(member, int index) {
    final isAdmin = member.role?.toLowerCase() == 'admin';
    final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
    final isCurrentUserAdmin = diwaniya?.userPermission?.isAdmin ?? false;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Row(
        children: [
          // Number label
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${index + 1}',
              style: TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          12.widthBox(),
          // Profile picture
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLiteGrey),
            child: ClipOval(
              child: member.image != null
                  ? Image.network(
                      member.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, color: AppColors.primaryColor, size: 30);
                      },
                    )
                  : Image.asset(
                      AppAssets.ic_profile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, color: AppColors.primaryColor, size: 30);
                      },
                    ),
            ),
          ),
          12.widthBox(),
          // Member name
          Expanded(
            child: Text(
              member.name ?? '',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Admin tag or Remove button
          if (isAdmin)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                LocaleKeys.admin.tr(),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (isCurrentUserAdmin && member.id != null)
            GestureDetector(
              onTap: () {
                final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
                if (diwaniya?.id != null) {
                  bloc.add(RemoveMemberEvent(diwaniyaId: diwaniya!.id!, userId: member.id!));
                }
              },
              child: Icon(Icons.close, color: AppColors.primaryRed, size: 24),
            ),
        ],
      ),
    );
  }
}
