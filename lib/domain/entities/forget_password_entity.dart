import 'package:equatable/equatable.dart';

class ForgetPasswordEntity extends Equatable {
  const ForgetPasswordEntity({
    this.token,
    this.userId,
    this.expiredOn,
    this.isAuthenticated,
    this.hasDefaultAddress,
    this.message,
    this.isSuccess,
  });

  final String? token;
  final String? userId;
  final String? expiredOn;
  final String? isAuthenticated;
  final String? hasDefaultAddress;
  final String? message;
  final String? isSuccess;

  @override
  List<Object?> get props => <Object?>[
        token,
        userId,
        expiredOn,
        isAuthenticated,
        hasDefaultAddress,
        message,
        isSuccess,
      ];
}
