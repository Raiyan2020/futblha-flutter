import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../../application/core/utils/pusher/chat_pusher_service.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/app_size_boxes.dart';
import '../../widgets/snackbar_utill.dart';
import '../diwaniyat/bloc/diwaniya_bloc.dart';
import '../games/bloc/games_bloc.dart';
import '../../../data/models/request_model/diwaniya/send_message_request_model.dart';
import '../../../data/models/request_model/diwaniya/poll_vote_request_model.dart';
import '../../../data/models/response_model/diwaniya/message_model.dart';
import '../../../data/models/response_model/login_remote_response_model/login_response_model.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final int? gameId; // Optional: if provided, use game chat flow
  final DiwaniyaBloc? diwaniyaBloc;
  const ChatPage({super.key, this.gameId, this.diwaniyaBloc});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final diwaniyaBloc = widget.diwaniyaBloc ?? locator<DiwaniyaBloc>();
  final gamesBloc = locator<GamesBloc>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatPusherService? _pusherService;

  @override
  void initState() {
    super.initState();
    _resetUnreadCount();
    _loadMessages();
    _initializePusher();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (!pos.hasPixels || !pos.hasContentDimensions) return;
    const threshold = 200.0;
    if (pos.pixels < pos.maxScrollExtent - threshold) return;

    if (widget.gameId != null) {
      final paginate = gamesBloc.gameMessages?.paginate;
      final currentPage = paginate?.currentPage ?? 1;
      final totalPages = paginate?.totalPages ?? 1;
      if (currentPage >= totalPages || gamesBloc.gameMessagesLoadingMore) return;
      gamesBloc.add(
        GetGameMessagesEvent(gameId: widget.gameId!, scrollToBottom: false, page: currentPage + 1),
      );
      return;
    }

    final paginate = diwaniyaBloc.messages?.paginate;
    final currentPage = paginate?.currentPage ?? 1;
    final totalPages = paginate?.totalPages ?? 1;
    if (currentPage >= totalPages || diwaniyaBloc.messagesLoadingMore) return;
    final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
    if (diwaniya?.id != null) {
      diwaniyaBloc.add(
        GetMessagesEvent(diwaniyaId: diwaniya!.id!, scrollToBottom: false, page: currentPage + 1),
      );
    }
  }

  void _resetUnreadCount() {
    // Only reset for diwaniya chat, not game chat
    if (widget.gameId == null) {
      final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
      if (diwaniya != null) {
        diwaniya.unreadMessagesCount = 0;
      }
    }
  }

  @override
  void dispose() {
    _pusherService?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializePusher() {
    try {
      int? diwaniyaId;
      int? gameId;

      if (widget.gameId != null) {
        gameId = widget.gameId;
      } else {
        final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
        diwaniyaId = diwaniya?.id;
      }

      if (diwaniyaId != null || gameId != null) {
        _pusherService = ChatPusherService(
          diwaniyaId: diwaniyaId,
          gameId: gameId,
          onMessageReceived: (MessageModel message) {
            // Dispatch event to the appropriate bloc
            if (widget.gameId != null) {
              gamesBloc.add(GameMessageReceivedEvent(message: message));
            } else {
              diwaniyaBloc.add(MessageReceivedEvent(message: message));
            }
          },
        );
        _pusherService?.connect().catchError((error) {
          debugPrint('Pusher connection error: $error');
        });
      }
    } catch (e) {
      debugPrint('Error initializing Pusher: $e');
    }
  }

  void _loadMessages() {
    if (widget.gameId != null) {
      gamesBloc.add(GetGameMessagesEvent(gameId: widget.gameId!, scrollToBottom: true));
    } else {
      final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
      if (diwaniya?.id != null) {
        diwaniyaBloc.add(GetMessagesEvent(diwaniyaId: diwaniya!.id!, scrollToBottom: true));
      }
    }
  }

  List<ChatMessage> _convertMessages() {
    final messages = widget.gameId != null
        ? gamesBloc.gameMessages?.items
        : diwaniyaBloc.messages?.items;

    if (messages == null) return [];

    return messages.map((msg) {
      final isPoll = msg.type?.toLowerCase() == 'poll';
      final timestamp = _parseDateTime(msg.createdAt ?? '');

      return ChatMessage(
        senderName: msg.user?.name ?? LocaleKeys.unknown.tr(),
        message: msg.content ?? '',
        timestamp: timestamp,
        isMine: msg.sentByMe,
        type: isPoll
            ? MessageType.poll
            : msg.type?.toLowerCase() == 'image'
            ? MessageType.image
            : msg.type?.toLowerCase() == 'file'
            ? MessageType.file
            : MessageType.text,
        avatarPath: msg.user?.image,
        pollOptions: isPoll && msg.options != null
            ? msg.options!
                  .map(
                    (opt) => PollOption(
                      label: opt.optionText ?? '',
                      votes: opt.votesCount ?? 0,
                      id: opt.id,
                      voters: opt.voters,
                    ),
                  )
                  .toList()
            : null,
      );
    }).toList();
  }

  DateTime _parseDateTime(String dateTimeStr) {
    try {
      // Format: "2025-12-04 00:48"
      final parts = dateTimeStr.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        if (dateParts.length == 3 && timeParts.length == 2) {
          return DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }
    } catch (e) {
      // If parsing fails, return current time
    }
    return DateTime.now();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final request = SendMessageRequestModel(type: 'text', content: _messageController.text.trim());

    if (widget.gameId != null) {
      gamesBloc.add(SendGameMessageEvent(gameId: widget.gameId!, request: request));
    } else {
      final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
      if (diwaniya?.id == null) return;
      diwaniyaBloc.add(SendMessageEvent(diwaniyaId: diwaniya!.id!, request: request));
    }

    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final request = SendMessageRequestModel(
          type: 'image',
          file: File(result.files.single.path!),
        );

        if (widget.gameId != null) {
          gamesBloc.add(SendGameMessageEvent(gameId: widget.gameId!, request: request));
        } else {
          final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
          if (diwaniya?.id == null) return;
          diwaniyaBloc.add(SendMessageEvent(diwaniyaId: diwaniya!.id!, request: request));
        }
      }
    } catch (e) {
      if (mounted) {
        context.showMessage(isError: true, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);

      if (result != null && result.files.single.path != null) {
        final request = SendMessageRequestModel(
          type: 'file',
          file: File(result.files.single.path!),
        );

        if (widget.gameId != null) {
          gamesBloc.add(SendGameMessageEvent(gameId: widget.gameId!, request: request));
        } else {
          final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
          if (diwaniya?.id == null) return;
          diwaniyaBloc.add(SendMessageEvent(diwaniyaId: diwaniya!.id!, request: request));
        }
      }
    } catch (e) {
      if (mounted) {
        context.showMessage(isError: true, 'Failed to pick file: $e');
      }
    }
  }

  Future<void> _showPollDialog() async {
    final pollQuestionController = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();
    final List<TextEditingController> optionControllers = [option1Controller, option2Controller];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(LocaleKeys.create_poll.tr()),
          constraints: BoxConstraints(minWidth: 400.w),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: pollQuestionController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.poll_question.tr(),
                    hintText: 'e.g., Who will attend the match?',
                    border: OutlineInputBorder(),
                  ),
                ),
                16.heightBox(),
                Text(LocaleKeys.options.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
                8.heightBox(),
                ...optionControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: '${LocaleKeys.option.tr()} ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }).toList(),
                if (optionControllers.length < 4)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        optionControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: Text(LocaleKeys.add_option.tr()),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                if (pollQuestionController.text.trim().isNotEmpty &&
                    optionControllers.any((c) => c.text.trim().isNotEmpty)) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(
                LocaleKeys.create.tr(),
                style: const TextStyle(color: AppColors.primaryWhite),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final question = pollQuestionController.text.trim();
      final options = optionControllers
          .map((c) => c.text.trim())
          .where((opt) => opt.isNotEmpty)
          .toList();

      if (question.isNotEmpty && options.length >= 2) {
        final request = SendMessageRequestModel(
          type: 'poll',
          content: question,
          pollOptions: options,
        );

        if (widget.gameId != null) {
          gamesBloc.add(SendGameMessageEvent(gameId: widget.gameId!, request: request));
        } else {
          final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
          if (diwaniya?.id == null) return;
          diwaniyaBloc.add(SendMessageEvent(diwaniyaId: diwaniya!.id!, request: request));
        }
      } else {
        if (mounted) {
          context.showMessage(isError: true, 'Please provide a question and at least 2 options');
        }
      }
    }

    // // Dispose controllers
    // pollQuestionController.dispose();
    // for (var controller in optionControllers) {
    //   controller.dispose();
    // }
  }

  void _votePoll(int optionId) {
    final request = PollVoteRequestModel(chatPollOptionId: optionId);
    if (widget.gameId != null) {
      gamesBloc.add(VoteGamePollEvent(gameId: widget.gameId!, request: request));
    } else {
      final diwaniya = diwaniyaBloc.myDiwaniya ?? diwaniyaBloc.diwaniyaDetails;
      if (diwaniya?.id == null) return;
      diwaniyaBloc.add(VotePollEvent(diwaniyaId: diwaniya!.id!, request: request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.gameId != null
        ? CustomBlocConsumer<GamesBloc, GamesState>(
            bloc: gamesBloc,
            listener: (context, state) {
              if (state is GamesError) {
                context.showMessage(isError: true, state.message);
              } else if (state is GamesSuccess) {
                // Scroll to bottom after new message
                if (state.scrollToBottom) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              }
            },
            builder: (context, state) {
              final messages = _convertMessages();
              final isLoading = state is GamesLoading && gamesBloc.gameMessages == null;

              return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  title: Text(LocaleKeys.game_chat.tr()),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: isLoading
                          ? const LoadingWidget()
                          : messages.isEmpty
                          ? Center(
                              child: Text(
                                LocaleKeys.no_messages_yet.tr(),
                                style: const TextStyle(
                                  color: AppColors.lightTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              reverse: true,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                              itemBuilder: (context, index) {
                                final isLoadMoreIndicator =
                                    index == messages.length && gamesBloc.gameMessagesLoadingMore;
                                if (isLoadMoreIndicator) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                return _buildMessageBubble(messages[index]);
                              },
                              separatorBuilder: (_, __) => 12.heightBox(),
                              itemCount: gamesBloc.gameMessagesLoadingMore
                                  ? messages.length + 1
                                  : messages.length,
                            ),
                    ),
                    _buildComposer(state),
                  ],
                ),
              );
            },
          )
        : CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
            bloc: diwaniyaBloc,
            listener: (context, state) {
              if (state is DiwaniyaError) {
                context.showMessage(isError: true, state.message);
              } else if (state is DiwaniyaSuccess) {
                // Scroll to bottom after new message
                if (state.scrollToBottom) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              }
            },
            builder: (context, state) {
              final messages = _convertMessages();

              return Scaffold(
                appBar: AppBar(elevation: 0, centerTitle: true, title: Text(LocaleKeys.chat.tr())),
                body: Column(
                  children: [
                    Expanded(
                      child: state is DiwaniyaLoading && diwaniyaBloc.messages == null
                          ? const LoadingWidget()
                          : messages.isEmpty
                          ? Center(
                              child: Text(
                                LocaleKeys.no_messages_yet.tr(),
                                style: const TextStyle(
                                  color: AppColors.lightTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              reverse: true,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                              itemBuilder: (context, index) {
                                final isLoadMoreIndicator =
                                    index == messages.length && diwaniyaBloc.messagesLoadingMore;
                                if (isLoadMoreIndicator) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                return _buildMessageBubble(messages[index]);
                              },
                              separatorBuilder: (_, __) => 12.heightBox(),
                              itemCount: diwaniyaBloc.messagesLoadingMore
                                  ? messages.length + 1
                                  : messages.length,
                            ),
                    ),
                    _buildComposer(state),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bubbleAlignment = message.isMine ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = message.isMine ? AppColors.primaryColor : AppColors.secondaryColor;
    final textColor = message.isMine ? AppColors.primaryWhite : AppColors.primaryBlack;
    final metadata = '${_formatDate(message.timestamp)} - ${_formatTime(message.timestamp)}';

    return Column(
      crossAxisAlignment: message.isMine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: message.isMine ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!message.isMine && message.avatarPath != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.senderName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  4.heightBox(),
                  Text(
                    metadata,
                    style: const TextStyle(
                      color: AppColors.lightTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              8.widthBox(),
              _buildAvatar(message.avatarPath!),
            ] else
              Text(
                'You\n$metadata',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        8.heightBox(),
        Align(
          alignment: bubbleAlignment,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(message.isMine ? 0 : 18),
                topRight: Radius.circular(message.isMine ? 18 : 0),
                bottomLeft: const Radius.circular(18),
                bottomRight: const Radius.circular(18),
              ),
            ),
            child: message.type == MessageType.poll
                ? _buildPollContent(message, textColor)
                : (message.type == MessageType.image || message.type == MessageType.file) &&
                      message.message.isNotEmpty &&
                      message.message.startsWith('http')
                ? Image.network(
                    message.message,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        LocaleKeys.failed_to_load_image.tr(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  )
                : Text(
                    message.message,
                    style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPollContent(ChatMessage message, Color textColor) {
    final totalVotes = message.pollOptions?.fold<int>(0, (sum, option) => sum + option.votes) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.message,
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        12.heightBox(),
        if (message.pollOptions != null)
          ...message.pollOptions!.map(
            (option) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GestureDetector(
                onTap: option.id != null ? () => _votePoll(option.id!) : null,
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: AppColors.primaryWhite,
                      size: 18,
                    ),
                    8.widthBox(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option.label,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              8.widthBox(),
                              _buildVoterAvatars(option, textColor, message),
                            ],
                          ),
                          4.heightBox(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: totalVotes == 0 ? 0 : option.votes / totalVotes,
                              minHeight: 4,
                              backgroundColor: AppColors.primaryWhite.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoterAvatars(PollOption option, Color textColor, ChatMessage message) {
    final voters = option.voters ?? [];
    final voteCount = option.votes;

    if (voters.isEmpty) {
      return Text(
        '$voteCount',
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      );
    }

    // Show up to 4 avatars in a stacked row, then +N for remaining (works for LTR & RTL)
    const maxVisibleAvatars = 4;
    const avatarSize = 24.0;
    const overlap = 8.0;
    final visibleVoters = voters.take(maxVisibleAvatars).toList();
    final remainingCount = voters.length > maxVisibleAvatars
        ? voters.length - maxVisibleAvatars
        : 0;
    final hasMoreVoters = remainingCount > 0;
    final isRTL = context.locale.languageCode == 'ar';
    // Total width for stacked avatars: first full width + (n-1) * (size - overlap)
    final stackWidth = avatarSize + (visibleVoters.length - 1) * (avatarSize - overlap);
    final step = avatarSize - overlap;

    return GestureDetector(
      onTap: voters.isNotEmpty ? () => _showPollVotesSheet(message, option) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: stackWidth,
            height: avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: visibleVoters.asMap().entries.map((entry) {
                final index = entry.key;
                final voter = entry.value;
                final left = isRTL
                    ? stackWidth - avatarSize - (index * step)
                    : (index * step).toDouble();
                return Positioned(left: left, top: 0, child: _buildVoterAvatar(voter, avatarSize));
              }).toList(),
            ),
          ),
          if (hasMoreVoters) ...[
            4.widthBox(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$remainingCount',
                style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          4.widthBox(),
          Text(
            '$voteCount',
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildVoterAvatar(UserModel voter, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryWhite, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: voter.image != null && voter.image!.startsWith('http')
            ? Image.network(
                voter.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(size),
              )
            : Image.asset(
                AppAssets.ic_profile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(size),
              ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      color: AppColors.primaryLiteGrey,
      child: Icon(Icons.person, color: AppColors.primaryColor, size: size * 0.65),
    );
  }

  void _showPollVotesSheet(ChatMessage message, PollOption selectedOption) {
    // Get all options with their voters for the full poll
    final allOptions = message.pollOptions ?? [];
    final totalVotes = allOptions.fold<int>(0, (sum, option) => sum + option.votes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLiteGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.transparent),
                    onPressed: () {},
                  ),
                  Text(
                    LocaleKeys.poll_votes.tr(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Poll question
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  8.heightBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      message.message,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Vote summary
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Text(
                      '$totalVotes ${totalVotes == 1 ? LocaleKeys.vote.tr() : LocaleKeys.votes.tr()}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            8.heightBox(),
            // Options with voters
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                itemCount: allOptions.length,
                itemBuilder: (context, index) {
                  final option = allOptions[index];
                  final voters = option.voters ?? [];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Option header
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${option.votes} ${option.votes == 1 ? LocaleKeys.vote.tr() : LocaleKeys.votes.tr()}',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        8.heightBox(),
                        // Voters list
                        if (voters.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 12.w),
                            child: Text('No votes yet', style: TextStyle(fontSize: 12)),
                          )
                        else
                          ...voters.map((voter) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderGrey),
                              ),
                              margin: EdgeInsets.only(bottom: 5.h),
                              padding: EdgeInsets.only(
                                top: 8.h,
                                bottom: 8.h,
                                left: 12.w,
                                right: 12.w,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: ClipOval(
                                      child: voter.image != null && voter.image!.startsWith('http')
                                          ? Image.network(
                                              voter.image!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: AppColors.primaryLiteGrey,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: AppColors.primaryColor,
                                                    size: 20,
                                                  ),
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              AppAssets.ic_profile,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: AppColors.primaryLiteGrey,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: AppColors.primaryColor,
                                                    size: 20,
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  12.widthBox(),
                                  Expanded(
                                    child: Text(
                                      voter.name ?? LocaleKeys.unknown.tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(dynamic state) {
    final isLoading = widget.gameId != null ? state is GamesLoading : state is DiwaniyaLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
      child: Row(
        children: [
          // Attachment button
          PopupMenuButton<String>(
            icon: const Icon(Icons.attach_file, color: AppColors.primaryColor),
            onSelected: (value) {
              if (value == 'image') {
                _pickAndSendImage();
              } else if (value == 'file') {
                _pickAndSendFile();
              } else if (value == 'poll') {
                _showPollDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'image',
                child: Row(
                  children: [
                    const Icon(Icons.image, color: AppColors.primaryColor),
                    SizedBox(width: 8.w),
                    Text(LocaleKeys.image.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'file',
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: AppColors.primaryColor),
                    SizedBox(width: 8.w),
                    Text(LocaleKeys.file.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'poll',
                child: Row(
                  children: [
                    const Icon(Icons.poll, color: AppColors.primaryColor),
                    SizedBox(width: 8.w),
                    Text(LocaleKeys.poll.tr()),
                  ],
                ),
              ),
            ],
          ),
          8.widthBox(),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isLoading,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) => setState(() {}), // Update send button state
              decoration: InputDecoration(
                hintText: LocaleKeys.write_your_message.tr(),
                border: InputBorder.none,
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
          12.widthBox(),
          GestureDetector(
            onTap: isLoading || _messageController.text.trim().isEmpty ? null : _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLoading || _messageController.text.trim().isEmpty
                    ? AppColors.primaryLiteGrey
                    : AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.send_rounded,
                color: isLoading || _messageController.text.trim().isEmpty
                    ? AppColors.lightTextColor
                    : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imagePath) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: imagePath != null && imagePath.startsWith('http')
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLiteGrey,
                    child: const Icon(Icons.person, color: AppColors.primaryColor),
                  );
                },
              )
            : Image.asset(
                AppAssets.ic_profile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLiteGrey,
                    child: const Icon(Icons.person, color: AppColors.primaryColor),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${_monthAbbreviation(dateTime.month)} ${dateTime.year}';

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  String _monthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

enum MessageType { text, poll, image, file }

class ChatMessage {
  ChatMessage({
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMine,
    required this.type,
    this.pollOptions,
    this.avatarPath,
  });

  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMine;
  final MessageType type;
  final List<PollOption>? pollOptions;
  final String? avatarPath;
}

class PollOption {
  PollOption({required this.label, required this.votes, this.id, this.voters});

  final String label;
  final int votes;
  final int? id;
  final List<UserModel>? voters;
}
