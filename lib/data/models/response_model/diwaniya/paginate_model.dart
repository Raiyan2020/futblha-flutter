import 'package:json_annotation/json_annotation.dart';

part 'paginate_model.g.dart';

@JsonSerializable()
class PaginateModel {
  final int? total;
  final int? count;
  @JsonKey(name: 'per_page')
  final int? perPage;
  @JsonKey(name: 'next_page_url')
  final String? nextPageUrl;
  @JsonKey(name: 'prev_page_url')
  final String? prevPageUrl;
  @JsonKey(name: 'current_page')
  final int? currentPage;
  @JsonKey(name: 'total_pages')
  final int? totalPages;

  PaginateModel({
    this.total,
    this.count,
    this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
    this.currentPage,
    this.totalPages,
  });

  factory PaginateModel.fromJson(Map<String, dynamic> json) => _$PaginateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginateModelToJson(this);
}

