import 'package:futblha/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

class LoginEntity extends Equatable {
  const LoginEntity({
    this.token,
    this.userId,
    this.id,
    this.teamId,
    this.expiredOn,
    this.isAuthenticated,
    this.hasDefaultAddress,
    this.isAccountVerified,
    this.phoneNumber,
    this.message,
    this.isSuccess,
    this.profile,
  });

  final String? token;
  final String? userId;
  final num? teamId;
  final num? id;
  final String? expiredOn;
  final String? phoneNumber;
  final bool? isAuthenticated;
  final bool? hasDefaultAddress;
  final bool? isAccountVerified;
  final String? message;
  final bool? isSuccess;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => <Object?>[
        token,
        userId,
        expiredOn,
        isAuthenticated,
        hasDefaultAddress,
        isAccountVerified,
        phoneNumber,
        message,
        isSuccess,
      ];
}
