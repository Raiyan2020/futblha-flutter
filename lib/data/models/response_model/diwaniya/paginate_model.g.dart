// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginateModel _$PaginateModelFromJson(Map<String, dynamic> json) =>
    PaginateModel(
      total: (json['total'] as num?)?.toInt(),
      count: (json['count'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
      currentPage: (json['current_page'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginateModelToJson(PaginateModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'count': instance.count,
      'per_page': instance.perPage,
      'next_page_url': instance.nextPageUrl,
      'prev_page_url': instance.prevPageUrl,
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
    };
