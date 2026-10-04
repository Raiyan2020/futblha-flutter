import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/response_model/wallet/add_balance_response_model.dart';
import '../../models/response_model/wallet/transactions_response_model.dart';
import '../../models/request_model/wallet/add_balance_request_model.dart';

abstract class WalletRemoteDataSource {
  Future<ApiResultModel<AddBalanceResponseModel?>> addBalance({
    required AddBalanceRequestModel request,
  });

  Future<ApiResultModel<TransactionsResponseModel?>> getTransactions();
}

