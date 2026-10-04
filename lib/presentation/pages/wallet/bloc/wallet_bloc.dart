import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/datasources/wallet_remote_datasource/wallet_remote_datasource.dart';
import '../../../../data/models/response_model/wallet/transaction_model.dart';
import '../../../../data/models/response_model/wallet/add_balance_response_model.dart';
import '../../../../data/models/response_model/wallet/transactions_response_model.dart';
import '../../../../data/models/request_model/wallet/add_balance_request_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRemoteDataSource _remoteDataSource;

  // Data stored in bloc
  List<TransactionModel> transactions = [];
  dynamic balance;
  AddBalanceResponseModel? addBalanceResponse;

  WalletBloc(this._remoteDataSource) : super(WalletInitial()) {
    on<GetTransactionsEvent>(_getTransactions);
    on<AddBalanceEvent>(_addBalance);
  }

  Future<void> _getTransactions(GetTransactionsEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final ApiResultModel<TransactionsResponseModel?> result = await _remoteDataSource.getTransactions();
    result.when(
      success: (data) {
        if (data != null) {
          transactions = data.data ?? [];
          balance = data.balance;
          emit(WalletSuccess());
        } else {
          emit(const WalletError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(WalletError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _addBalance(AddBalanceEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final ApiResultModel<AddBalanceResponseModel?> result = await _remoteDataSource.addBalance(
      request: event.request,
    );
    result.when(
      success: (data) {
        if (data != null) {
          addBalanceResponse = data;
          emit(WalletSuccess());
        } else {
          emit(const WalletError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(WalletError(message: error.message ?? errorMessage));
      },
    );
  }
}

