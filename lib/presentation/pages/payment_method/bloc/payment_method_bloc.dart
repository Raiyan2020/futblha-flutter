import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/payment_method_remote_datasource/payment_method_remote_datasource.dart';
import 'package:futblha/domain/entities/payment_method_entity.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/models/response_model/payment_method_response_model/payment_methods_list_response_model.dart';

part 'payment_method_event.dart';
part 'payment_method_state.dart';

@injectable
class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final PaymentMethodRemoteDataSource _paymentMethodRemoteDataSource;

  PaymentMethodBloc(this._paymentMethodRemoteDataSource) : super(PaymentMethodInitial()) {
    on<GetPaymentMethodsEvent>((event, emit) async {
      emit(PaymentMethodLoading());
      final ApiResultModel<PaymentMethodsListResponseModel?> result =
          await _paymentMethodRemoteDataSource.getPaymentMethods();
      result.when(
        success: (paymentMethodsListResponseModel) {
          if (paymentMethodsListResponseModel != null &&
              paymentMethodsListResponseModel.data.isNotEmpty) {
            final paymentMethods = paymentMethodsListResponseModel.data
                .map(
                  (model) =>
                      PaymentMethodEntity(key: model.key, name: model.name),
                )
                .toList();
            emit(PaymentMethodLoaded(paymentMethods));
          } else {
            emit(
              const PaymentMethodError('Failed to load payment methods: Data is null or empty.'),
            );
          }
        },
        failure: (errorResultEntity) {
          emit(PaymentMethodError(errorResultEntity.message ?? 'An unknown error occurred.'));
        },
      );
    });
  }
}
