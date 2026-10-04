import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

class FileConverter implements JsonConverter<File, String> {
  const FileConverter();

  @override
  File fromJson(String json) => File(json);

  @override
  String toJson(File file) => file.path;
}

class FileListConverter implements JsonConverter<List<File>, List<String>> {
  const FileListConverter();

  @override
  List<File> fromJson(List<String> json) => json.map((path) => File(path)).toList();

  @override
  List<String> toJson(List<File> files) => files.map((file) => file.path).toList();
}
