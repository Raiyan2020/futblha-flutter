part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
}

class ChangePassVisibilityEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthenticationEvent {
 final LoginRequestModel entity;
  const LoginEvent( this.entity);
  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthenticationEvent {
  const RegisterEvent(this.entity);
  final LoginRequestModel entity;
  @override
  List<Object?> get props => [];
}

class VerifyOtpEvent extends AuthenticationEvent {
  const VerifyOtpEvent({required this.requestModel});
  final VerifyOtpRequestModel requestModel;
  @override
  List<Object?> get props => [requestModel];
}

class ResendOtpEvent extends AuthenticationEvent {
  const ResendOtpEvent({required this.requestModel});
  final LoginRequestModel requestModel;
  @override
  List<Object?> get props => [requestModel];
}

class GetProfileEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

class UpdateProfileEvent extends AuthenticationEvent {
  const UpdateProfileEvent({
    required this.requestModel,
    this.image,
    this.positions,
    this.birthdate,
  });
  final LoginRequestModel? requestModel;
  final File? image;
  final List<String>? positions;
  final String? birthdate;
  @override
  List<Object?> get props => [requestModel, image, positions, birthdate];
}

class UpdateUserSettingsEvent extends AuthenticationEvent {
  const UpdateUserSettingsEvent({required this.requestModel});
  final UpdateUserSettingsRequestModel requestModel;
  @override
  List<Object?> get props => [requestModel];
}

class LogoutEvent extends AuthenticationEvent {
  const LogoutEvent({required this.apiRequest, this.model});
  final LogoutRequestModel? model;
  final bool apiRequest;
  @override
  List<Object?> get props => [model];
}

class CompleteProfileEvent extends AuthenticationEvent {
  const CompleteProfileEvent({this.image, this.positions});
  final File? image;
  final List<String>? positions;
  @override
  List<Object?> get props => [image, positions];
}

class DeleteAccountEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

class GuestLoginEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

/// Updates stored "my diwaniya" from diwaniyas-overview API (e.g. when DiwaniyaBloc fetches overview).
class UpdateMyDiwaniyaEvent extends AuthenticationEvent {
  const UpdateMyDiwaniyaEvent(this.myDiwaniya);
  final dynamic myDiwaniya; // DiwaniyaModel?
  @override
  List<Object?> get props => [myDiwaniya];
}