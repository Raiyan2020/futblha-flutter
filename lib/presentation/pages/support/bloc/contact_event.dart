part of 'contact_bloc.dart';

sealed class ContactEvent extends Equatable {
  const ContactEvent();
}

class ContactSendEvent extends ContactEvent {
  final ContactModel model;

  const ContactSendEvent(this.model);

  @override
  List<Object> get props => [model];
}

class GetSocialLinksEvent extends ContactEvent {
  const GetSocialLinksEvent();

  @override
  List<Object> get props => [];
}

class GetFaqEvent extends ContactEvent {
  @override
  List<Object> get props => [];
}

// class GetSettingsEvent extends ContactEvent {
//   final String keyName; // terms, about, phone,email,privacy
//   const GetSettingsEvent(this.keyName);
//
//   @override
//   List<Object> get props => [keyName];
// }
