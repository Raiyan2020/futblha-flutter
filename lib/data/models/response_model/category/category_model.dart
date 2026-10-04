import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class CategoryModel extends Equatable {
  num? id;
  String? name;
  num? questions_count;
  num? correct_answers;
  num? questions_answered;
  String? image;

  CategoryModel(
      {this.id, this.name, this.questions_count, this.correct_answers, this.questions_answered, this.image});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}
