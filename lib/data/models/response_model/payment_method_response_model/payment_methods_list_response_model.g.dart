// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_methods_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodsListResponseModel _$PaymentMethodsListResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentMethodsListResponseModel(
  data:
      (json['data'] as List<dynamic>?)
          ?.map(
            (e) =>
                PaymentMethodResponseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$PaymentMethodsListResponseModelToJson(
  PaymentMethodsListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
