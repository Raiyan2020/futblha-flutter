import 'package:equatable/equatable.dart';

class RegisterEntity extends Equatable {
  const RegisterEntity({
    this.otpCode,
    this.customerId,
    this.userId
  });
  final String? otpCode;
  final int? customerId;
  final String? userId;

  @override
  List<Object?> get props => <Object?>[
    otpCode,
    customerId,
    userId
      ];
}
