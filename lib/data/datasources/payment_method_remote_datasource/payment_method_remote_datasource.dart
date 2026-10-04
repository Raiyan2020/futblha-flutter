import 'package:futblha/data/models/response_model/payment_method_response_model/payment_methods_list_response_model.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';

abstract class PaymentMethodRemoteDataSource {
  Future<ApiResultModel<PaymentMethodsListResponseModel?>> getPaymentMethods();
}
