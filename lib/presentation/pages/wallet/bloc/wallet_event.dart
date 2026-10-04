part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class GetTransactionsEvent extends WalletEvent {}

class AddBalanceEvent extends WalletEvent {
  final AddBalanceRequestModel request;
  
  const AddBalanceEvent({required this.request});
  
  @override
  List<Object?> get props => [request];
}

