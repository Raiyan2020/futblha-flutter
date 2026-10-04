class PollVoteRequestModel {
  final int chatPollOptionId;

  PollVoteRequestModel({required this.chatPollOptionId});

  Map<String, dynamic> toFormData() {
    return {
      'chat_poll_option_id': chatPollOptionId.toString(),
    };
  }
}

