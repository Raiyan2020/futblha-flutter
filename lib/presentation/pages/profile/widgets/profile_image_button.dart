import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/app_assets.dart';
import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../auth/bloc/authentication_bloc.dart';

class ProfileImageButton extends StatefulWidget {
  const ProfileImageButton({super.key, this.size = 100, this.clickable = true});
  final double size;
  final bool clickable;

  @override
  State<ProfileImageButton> createState() => _ProfileImageButtonState();
}

class _ProfileImageButtonState extends State<ProfileImageButton> {
  final authenticationBloc = locator<AuthenticationBloc>();

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<AuthenticationBloc, AuthenticationState>(
      bloc: authenticationBloc,
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () => widget.clickable ? context.router.push(const ProfileRoute()) : null,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(1),
            height: widget.size,
            width: widget.size,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              border: Border.all(color: state is AuthLoading ? AppColors.primaryWhite : Colors.green, width: 0),
              color: AppColors.primaryWhite,
              shape: BoxShape.circle,
            ),
            child: authenticationBloc.user?.image != null
                ? ClipOval(
                    child: Image.network(
                      authenticationBloc.user!.image!,
                      height: widget.size,
                      width: widget.size,
                      fit: BoxFit.cover,
                      // ic_profile is a PNG, so it must not go through SvgPicture.
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppAssets.ic_profile,
                        height: widget.size,
                        width: widget.size,
                      ),
                    ),
                  )
                : Image.asset(AppAssets.ic_profile, height: widget.size, width: widget.size),
          ),
        );
      },
    );
  }
}
