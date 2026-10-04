import 'package:json_annotation/json_annotation.dart';
import '../../../../application/core/utils/helpers/cache/cache_manager.dart';
import 'message_user_model.dart';
import 'poll_option_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int? id;
  final String? type; // text, image, file, poll
  final String? content;
  final MessageUserModel? user;
  @JsonKey(name: 'sender_id')
  final int? senderId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<PollOptionModel>? options;

  bool get sentByMe => senderId == int.parse(CacheManager.instance.getUserId());

  MessageModel({
    this.id,
    this.type,
    this.content,
    this.user,
    this.senderId,
    this.createdAt,
    this.options,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
