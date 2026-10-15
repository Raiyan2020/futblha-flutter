import 'dart:io';

class CreateDiwaniyaRequestModel {
  final String name;
  final File? image;
  final String description;
  final String type;
  // Only used when updating: asks the backend to delete the current image.
  final bool removeImage;

  CreateDiwaniyaRequestModel({
    required this.name,
    this.image,
    required this.description,
    required this.type,
    this.removeImage = false,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'type': type,
    };

    if (image != null) {
      data['image'] = image;
    } else if (removeImage) {
      data['remove_image'] = 1;
    }

    return data;
  }
}
