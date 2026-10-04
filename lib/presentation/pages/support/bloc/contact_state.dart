part of 'contact_bloc.dart';

sealed class ContactState extends Equatable {
  const ContactState();
}

final class ContactInitial extends ContactState {
  @override
  List<Object> get props => [];
}

class ContactLoading extends ContactState {
  @override
  List<Object> get props => [];
}

class ContactSuccess extends ContactState {
  final String message;
  const ContactSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class ContactError extends ContactState {
  final ErrorResultModel errorResultModel;
  const ContactError({required this.errorResultModel});
  @override
  List<Object> get props => [errorResultModel];
}

class SocialLinksLoading extends ContactState {
  @override
  List<Object> get props => [];
}

class SocialLinksSuccess extends ContactState {
  final SocialResponseModel? model;
  const SocialLinksSuccess({required this.model});
  @override
  List<Object> get props => [];
}

class FaqLoading extends ContactState {
  @override
  List<Object> get props => [];
}

class FaqSuccess extends ContactState {
  final List<FaqEntity>? model;
  const FaqSuccess({required this.model});
  @override
  List<Object> get props => [];
}

class FaqError extends ContactState {
  final ErrorResultModel errorResultModel;
  const FaqError({required this.errorResultModel});
  @override
  List<Object> get props => [errorResultModel];
}

class SettingsLoading extends ContactState {
  @override
  List<Object> get props => [];
}

class AppSettingsLoading extends ContactState {
  @override
  List<Object> get props => [];
}

class SettingsSuccess extends ContactState {
  final String? model;
  const SettingsSuccess(this.model);
  @override
  List<Object> get props => [];
}

class AppSettingsSuccess extends ContactState {
  final AppSettingsModel? model;
  const AppSettingsSuccess(this.model);
  @override
  List<Object> get props => [];
}

