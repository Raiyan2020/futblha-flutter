import 'package:equatable/equatable.dart';

import '../entitties/based_api_result/api_result_model.dart';

abstract class BaseParamsUseCase<T, Request> {
  Future<ApiResultModel<T>> call(Request params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
