import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';
import 'paginate_model.dart';

part 'messages_response_model.g.dart';

@JsonSerializable()
class MessagesResponseModel {
  final List<MessageModel>? items;
  final PaginateModel? paginate;
  final dynamic extra;

  MessagesResponseModel({
    this.items,
    this.paginate,
    this.extra,
  });

  factory MessagesResponseModel.fromJson(Map<String, dynamic> json) => _$MessagesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesResponseModelToJson(this);
}

