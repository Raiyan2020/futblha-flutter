/// `friendship_status` between the current user and another user.
enum FriendshipStatus {
  self('self'),
  none('none'),
  requestSent('request_sent'),
  requestReceived('request_received'),
  friends('friends');

  const FriendshipStatus(this.apiValue);

  final String apiValue;

  /// Unknown or missing values return null, so the UI shows nothing rather
  /// than guessing.
  static FriendshipStatus? fromApi(String? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}
