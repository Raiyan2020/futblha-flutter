import 'package:flutter/cupertino.dart';
import '../../application/core/basecomponents/base_view_model_view.dart';
import '../../application/core/di/app_component/app_component.dart';
import '../pages/auth/bloc/authentication_bloc.dart';

class PasswordEyeButton extends StatelessWidget {
  PasswordEyeButton({super.key});

  final AuthenticationBloc bloc = locator<AuthenticationBloc>();

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<AuthenticationBloc, AuthenticationState>(
      bloc: bloc,
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () => bloc.add(ChangePassVisibilityEvent()),
          child: Icon(bloc.suffix, size: 20),
        );
      },
    );
  }
}
