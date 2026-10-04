part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletSuccess extends WalletState {}

class WalletError extends WalletState {
  final String message;
  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}

