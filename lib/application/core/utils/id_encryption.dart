import 'dart:convert';

import 'package:flutter/foundation.dart';

class IdEncryption {
  static const int _salt = 12345;
  static const int _multiplier = 17;

  static String encrypt(int id) {
    final transformedId = (id * _multiplier) + _salt;
    return base64.encode(utf8.encode(transformedId.toString()));
  }

  static int decrypt(String encryptedId) {
    try {
      final decodedString = utf8.decode(base64.decode(encryptedId));
      final transformedId = int.parse(decodedString);
      // Using integer division
      return (transformedId - _salt) ~/ _multiplier;
    } catch (e) {
      debugPrint('Error decrypting ID: $e');
      throw FormatException('Invalid encrypted ID: $encryptedId');
    }
  }
}

