import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/faq_remote_datasource/faq_remote_datasource.dart';
import 'package:futblha/domain/entities/faq_entity.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/models/response_model/faq_response_model/faqs_list_response_model.dart';

part 'faq_event.dart';
part 'faq_state.dart';

@injectable
class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final FaqRemoteDataSource _faqRemoteDataSource;

  FaqBloc(this._faqRemoteDataSource) : super(FaqInitial()) {
    on<GetFaqsEvent>((event, emit) async {
      emit(FaqLoading());
      final ApiResultModel<FaqsListResponseModel?> result = await _faqRemoteDataSource.getFaqs();
      result.when(
        success: (faqsListResponseModel) {
          if (faqsListResponseModel != null && faqsListResponseModel.data.isNotEmpty) {
            final faqs = faqsListResponseModel.data.map((model) => FaqEntity(
              id: model.id,
              question: model.question,
              answer: model.answer,
              status: model.status,
            )).toList();
            emit(FaqLoaded(faqs));
          } else {
            emit(const FaqError('Failed to load FAQs: Data is null or empty.'));
          }
        },
        failure: (errorResultEntity) {
          emit(FaqError(errorResultEntity.message ?? 'An unknown error occurred.'));
        },
      );
    });
  }
}
