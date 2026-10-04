import 'dart:io';

class SendMessageRequestModel {
  final String type; // text, image, file, poll
  final String? content; // For text/poll, this is the text. For image/file, this is the file path
  final File? file; // For image/file uploads
  final List<String>? pollOptions; // For poll type: array of option texts

  SendMessageRequestModel({
    required this.type,
    this.content,
    this.file,
    this.pollOptions,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {'type': type};

    if (type == 'poll') {
      // Poll message
      if (content != null) {
        formData['content'] = content!;
      }
      if (pollOptions != null) {
        for (int i = 0; i < pollOptions!.length; i++) {
          formData['options[$i][option_text]'] = pollOptions![i];
        }
      }
    } else if (type == 'text') {
      // Text message
      if (content != null) {
        formData['content'] = content!;
      }
    } else if (type == 'image' || type == 'file') {
      // Image or file upload
      // File will be handled separately in FormData
    }

    return formData;
  }
}

