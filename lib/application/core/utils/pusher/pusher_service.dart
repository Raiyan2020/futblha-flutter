import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  final Function(PusherEvent event)? onEvent;
  final num challengeId;
  PusherService({required this.challengeId, this.onEvent});

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  final _apiKey = TextEditingController(text: "d8a9bdb64c2df1e5e789");
  final _cluster = TextEditingController(text: "eu");
  late final _channelName = TextEditingController(text: "private-group-challenge.$challengeId");
  final _eventName = TextEditingController(text: "update-group-challenge-result");

  void log(String text) {
    debugPrint("LOG: $text");
  }

  void onConnectPressed() async {
    try {
      await pusher.init(
        apiKey: _apiKey.text,
        cluster: _cluster.text,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: (event) {
          debugPrint("EVENT: $event");
          onEvent?.call(event);
        },
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount,
      //  authEndpoint: "https://tahaddy.work/broadcasting/auth",
        // authParams: {},
        onAuthorizer: onAuthorizer,
      );
      await pusher.subscribe(
        channelName: _channelName.text,
        onEvent: (event) {
          debugPrint("EVENT: $event");
          onEvent?.call(event);
        },
      );
      await pusher.connect();
    } catch (e) {
      log("ERROR: $e");
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    log("Me: $me");
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

  String getSignature(String value) {
    var key = utf8.encode('e20f7d1f50b44a37bd86');
    var bytes = utf8.encode(value);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);
    debugPrint("HMAC signature in string is: $digest");
    return digest.toString();
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    return {
      "auth": "d8a9bdb64c2df1e5e789:${getSignature("$socketId:$channelName")}",
    };
  }

  void onTriggerEventPressed() async {
    pusher.trigger(
      PusherEvent(channelName: _channelName.text, eventName: _eventName.text, data: 'data'),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  // late PusherClient pusher;
  // late Channel channel;
  // PusherService() {
  //   pusher = PusherClient(
  //     'd8a9bdb64c2df1e5e789',
  //     PusherOptions(
  //       cluster: 'eu',
  //       auth: PusherAuth(
  //         'https://tahaddy.work/broadcasting/auth',
  //       ),
  //     ),
  //     enableLogging: true,
  //   );
  //
  //   pusher.onConnectionStateChange((state) {
  //     print("previousState: ${state.previousState}, currentState: ${state.currentState}");
  //   });
  //
  //   pusher.onConnectionError((error) {
  //     print("error: ${error.message}");
  //   });
  //
  //   channel = pusher.subscribe('private-group-challenge.{challenge_id}');
  //
  //   channel.bind('update-group-challenge-result', (event) {
  //     print("Event received: ${event.data}");
  //   });
  // }
}
