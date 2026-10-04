import 'package:json_annotation/json_annotation.dart';
import 'diwaniya_model.dart';
import 'diwaniyas_list_response_model.dart';

part 'diwaniyas_overview_response_model.g.dart';

@JsonSerializable()
class DiwaniyasOverviewResponseModel {
  @JsonKey(name: 'my_diwaniya')
  final DiwaniyaModel? myDiwaniya;
  @JsonKey(name: 'other_diwaniyas')
  final DiwaniyasListResponseModel? otherDiwaniyas;

  DiwaniyasOverviewResponseModel({this.myDiwaniya, this.otherDiwaniyas});

  factory DiwaniyasOverviewResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DiwaniyasOverviewResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyasOverviewResponseModelToJson(this);
}
