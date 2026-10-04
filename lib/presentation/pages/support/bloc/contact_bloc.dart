import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/contact_remote_datasource/contact_remote_datasource.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../data/models/request_model/contact/contact_model.dart';
import '../../../../data/models/request_model/social/social_response_model.dart';
import '../../../../domain/entities/faq_entity.dart';
import '../../../../domain/models/app_settings/app_settings_model.dart';
import '../../../../generated/locale_keys.g.dart';

part 'contact_event.dart';
part 'contact_state.dart';

@injectable
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRemoteDataSource _remoteDataSource;
  ContactBloc(this._remoteDataSource) : super(ContactInitial()) {
    on<ContactEvent>((event, emit) {});

    on<ContactSendEvent>(_contactSend);
    on<GetSocialLinksEvent>(_getSocialLinks);
  }

  Future<void> _contactSend(ContactSendEvent event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.contact(event.model);
    result.when(
      success: (String? model) {
        emit(ContactSuccess(message: model ?? LocaleKeys.success));
      },
      failure: (ErrorResultModel errorResultModel) {
        emit(ContactError(errorResultModel: errorResultModel));
      },
    );
  }

  SocialResponseModel? socialLinks;

  Future<void> _getSocialLinks(GetSocialLinksEvent event, Emitter<ContactState> emit) async {
    emit(SocialLinksLoading());
    final result = await _remoteDataSource.getSocialLinks();
    result.when(
      success: (SocialResponseModel? model) {
        socialLinks = model;
        emit(SocialLinksSuccess(model: model));
      },
      failure: (ErrorResultModel errorResultModel) {
        emit(ContactError(errorResultModel: errorResultModel));
      },
    );
  }
}
