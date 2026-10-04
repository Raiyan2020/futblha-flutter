import 'dart:io';

class CreateDiwaniyaRequestModel {
  final String name;
  final File? image;
  final String description;
  final String type;

  CreateDiwaniyaRequestModel({
    required this.name,
    this.image,
    required this.description,
    required this.type,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'type': type,
    };
    
    if (image != null) {
      data['image'] = image;
    }
    
    return data;
  }
}

