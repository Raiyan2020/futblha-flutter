import 'package:futblha/data/models/response_model/faq_response_model/faqs_list_response_model.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';

abstract class FaqRemoteDataSource {
  Future<ApiResultModel<FaqsListResponseModel?>>  getFaqs();
}
