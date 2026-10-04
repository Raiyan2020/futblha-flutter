import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'successful_status_request_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class SuccessfulStatusRequestModel {
  num? TaskId;
  num? MainTaskId;
  String? Notes;
  @JsonKey(fromJson: _fileFromJson, toJson: _fileToJson)
  final File? SignatureForm;

  @JsonKey(fromJson: _fileListFromJson, toJson: _fileListToJson)
  final List<File>? GallaryFiles;
  double? Longitude;
  double? Latitude;
  String? Reason;

  SuccessfulStatusRequestModel({
    this.TaskId,
    this.MainTaskId,
    this.Notes,
    this.SignatureForm,
    this.GallaryFiles,
    this.Latitude,
    this.Longitude,
    this.Reason,
  });

  factory SuccessfulStatusRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SuccessfulStatusRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessfulStatusRequestModelToJson(this);

  Future<FormData> toFormData() async {
    List<MultipartFile>? galleryFilesMultipart;
    if (GallaryFiles != null) {
      galleryFilesMultipart = await Future.wait(
        GallaryFiles!.map((file) async => await MultipartFile.fromFile(file.path)).toList(),
      );
    }

    MultipartFile? signatureMultipart;
    if (SignatureForm != null) {
      signatureMultipart = await MultipartFile.fromFile(SignatureForm!.path);
    }

    return FormData.fromMap({
      'TaskId': TaskId,
      'MainTaskId': MainTaskId,
      'Notes': Notes,
      'SignatureForm': signatureMultipart,
      'GallaryFiles': galleryFilesMultipart,
      'Longitude': Longitude,
      'Latitude': Latitude,
      'Reason': Reason,
    });
  }

  static Future<File> writeUint8ListToFile(Uint8List data, String filename) async {
    final format = getImageFormat(data);
    if (format == null) {
      debugPrint('Unsupported image format');
      throw Exception('Unsupported image format');
    }
    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    // Create a file in the temporary directory with the correct extension
    final file = File('${directory.path}/$filename.$format');
    // Write the bytes to the file
    await file.writeAsBytes(data);
    return file;
  }
}

File? _fileFromJson(String? base64Data) {
  if (base64Data == null) return null;
  final bytes = base64Decode(base64Data);
  final tempDir = Directory.systemTemp;
  final tempFile = File('${tempDir.path}/tempFile');
  tempFile.writeAsBytesSync(bytes);
  return tempFile;
}

String? _fileToJson(File? file) {
  if (file == null) return null;
  final bytes = file.readAsBytesSync();
  return base64Encode(bytes);
}

List<File>? _fileListFromJson(List<dynamic>? base64DataList) {
  if (base64DataList == null) return null;
  return base64DataList.map((base64Data) {
    final bytes = base64Decode(base64Data);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/tempFile_${DateTime.now().millisecondsSinceEpoch}');
    tempFile.writeAsBytesSync(bytes);
    return tempFile;
  }).toList();
}

List<String>? _fileListToJson(List<File>? files) {
  if (files == null) return null;
  return files.map((file) {
    final bytes = file.readAsBytesSync();
    return base64Encode(bytes);
  }).toList() as List<String>?;
}

String? getImageFormat(Uint8List bytes) {
  // Check for JPEG
  if (bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return 'jpeg';
  }

  // Check for PNG
  if (bytes.length > 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
    return 'png';
  }

  // Check for GIF
  if (bytes.length > 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
    return 'gif';
  }

  // Check for BMP
  if (bytes.length > 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
    return 'bmp';
  }

  // Check for WEBP
  if (bytes.length > 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'webp';
  }

  return null;
}

bool isImage(Uint8List bytes) {
  // Check for JPEG
  if (bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return true;
  }

  // Check for PNG
  if (bytes.length > 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
    return true;
  }

  // Check for GIF
  if (bytes.length > 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
    return true;
  }

  // Check for BMP
  if (bytes.length > 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
    return true;
  }

  // Check for WEBP
  if (bytes.length > 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return true;
  }

  return false;
}
