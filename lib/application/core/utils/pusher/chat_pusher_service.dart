import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../data/models/response_model/diwaniya/message_model.dart';

class ChatPusherService {
  final Function(MessageModel message)? onMessageReceived;
  final int? diwaniyaId;
  final int? gameId;

  ChatPusherService({this.onMessageReceived, this.diwaniyaId, this.gameId})
    : assert(diwaniyaId != null || gameId != null, 'Either diwaniyaId or gameId must be provided');

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  static const String _apiKey = '97b961cd738f18df46bc';
  static const String _appSecret = 'e64d5e07e21d142f274e';
  static const String _cluster = 'eu';
  static const String _eventName = 'message.sent';

  String get _channelName {
    if (diwaniyaId != null) {
      return 'private-diwaniya.$diwaniyaId';
    } else if (gameId != null) {
      return 'private-game.$gameId';
    }
    throw Exception('Either diwaniyaId or gameId must be provided');
  }

  bool _isInitialized = false;
  bool _isSubscribed = false;

  void log(String text) {
    debugPrint("ChatPusher LOG: $text");
  }

  Future<void> connect() async {
    if (_isInitialized && _isSubscribed) {
      log('Already connected');
      return;
    }

    try {
      if (!_isInitialized) {
        await pusher.init(
          apiKey: _apiKey,
          cluster: _cluster,
          onConnectionStateChange: onConnectionStateChange,
          onError: onError,
          onSubscriptionSucceeded: onSubscriptionSucceeded,
          onSubscriptionError: onSubscriptionError,
          onDecryptionFailure: onDecryptionFailure,
          onMemberAdded: onMemberAdded,
          onMemberRemoved: onMemberRemoved,
          onSubscriptionCount: onSubscriptionCount,
          onAuthorizer: onAuthorizer,
        );
        _isInitialized = true;
      }

      if (!_isSubscribed) {
        await pusher.subscribe(
          channelName: _channelName,
          onEvent: (event) {
            debugPrint("ChatPusher SUBSCRIBE EVENT: ${event.eventName} - ${event.data}");
            if (event.eventName == _eventName) {
              _handleMessageEvent(event);
            }
          },
        );
        _isSubscribed = true;
      }

      await pusher.connect();
      log('Connected to channel: $_channelName');
    } catch (e) {
      log("ERROR connecting: $e");
      rethrow;
    }
  }

  void _handleMessageEvent(PusherEvent event) {
    try {
      final data = event.data;
      if (data == null) {
        log('Event data is null');
        return;
      }

      // Parse the message data
      Map<String, dynamic> messageData;
      if (data is String) {
        messageData = json.decode(data) as Map<String, dynamic>;
      } else if (data is Map) {
        messageData = Map<String, dynamic>.from(data);
      } else {
        log('Unexpected data type: ${data.runtimeType}');
        return;
      }

      // Try to parse as MessageModel
      try {
        final message = MessageModel.fromJson(messageData);
        log('Message received: ${message.id} - ${message.content}');
        onMessageReceived?.call(message);
      } catch (e) {
        log('Error parsing message: $e');
        // Try to parse if message is nested in a 'message' or 'data' key
        if (messageData.containsKey('message')) {
          final message = MessageModel.fromJson(messageData['message'] as Map<String, dynamic>);
          onMessageReceived?.call(message);
        } else if (messageData.containsKey('data')) {
          final message = MessageModel.fromJson(messageData['data'] as Map<String, dynamic>);
          onMessageReceived?.call(message);
        }
      }
    } catch (e) {
      log('Error handling message event: $e');
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $previousState -> $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("onMemberRemoved: $channelName user: $member");
  }

  void onSubscriptionCount(String channelName, int subscriptionCount) {
    log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
  }

  String _getSignature(String value) {
    var key = utf8.encode(_appSecret);
    var bytes = utf8.encode(value);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);
    log("HMAC signature: $digest");
    return digest.toString();
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    final signature = _getSignature("$socketId:$channelName");
    return {"auth": "$_apiKey:$signature"};
  }

  Future<void> disconnect() async {
    try {
      if (_isSubscribed) {
        await pusher.unsubscribe(channelName: _channelName);
        _isSubscribed = false;
        log('Unsubscribed from channel: $_channelName');
      }
      if (_isInitialized) {
        await pusher.disconnect();
        _isInitialized = false;
        log('Disconnected from Pusher');
      }
    } catch (e) {
      log("ERROR disconnecting: $e");
    }
  }

  void dispose() {
    disconnect();
  }
}
