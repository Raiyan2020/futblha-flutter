import 'package:json_annotation/json_annotation.dart';
import 'diwaniya_member_model.dart';
import 'paginate_model.dart';

part 'diwaniya_members_response_model.g.dart';

@JsonSerializable()
class DiwaniyaMembersResponseModel {
  final List<DiwaniyaMemberModel>? items;
  final PaginateModel? paginate;
  final dynamic extra;

  DiwaniyaMembersResponseModel({
    this.items,
    this.paginate,
    this.extra,
  });

  factory DiwaniyaMembersResponseModel.fromJson(Map<String, dynamic> json) => _$DiwaniyaMembersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyaMembersResponseModelToJson(this);
}

