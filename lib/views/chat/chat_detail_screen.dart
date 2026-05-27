import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../controllers/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatController chatC = Get.find<ChatController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _pollingTimer;

  late int conversationId;
  late int userOneId;
  Map<String, dynamic> otherUser = {'name': 'Pengguna', 'id': 0, 'role': ''};

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    conversationId = args is Map ? (args['conversation_id'] ?? 1) : (args ?? 1);
    userOneId = args is Map ? (args['user_one_id'] ?? 0) : 0;
    otherUser = args is Map
        ? (args['other_user'] ?? {'name': 'Pengguna', 'id': 0, 'role': ''})
        : {'name': 'Pengguna', 'id': 0, 'role': ''};

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await chatC.fetchMessages(conversationId);
      _scrollToBottom();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final prevCount = chatC.currentMessages.length;
      await chatC.fetchMessages(conversationId);
      if (chatC.currentMessages.length != prevCount) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color ?? theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  AppColors.primary.withAlpha((0.2 * 255).round()),
              child: Text(
                (otherUser['name'] as String).isNotEmpty
                    ? (otherUser['name'] as String)[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser['name'] ?? 'Pengguna',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  otherUser['role'] == 'owner' ? 'Pemilik Kost' : 'Pengguna',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatC.currentMessages.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada pesan. Mulai obrolan sekarang!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: chatC.currentMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatC.currentMessages[index];

                  final senderId = msg['sender_id'];
                  bool isMe = senderId == userOneId ||
                      senderId.toString() == userOneId.toString();

                  String text = msg['message'] ?? '';
                  String timeStr = '';
                  if (msg['created_at'] != null) {
                    try {
                      DateTime dt =
                          DateTime.parse(msg['created_at']).toLocal();
                      timeStr =
                          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                    } catch (e) {
                      timeStr = '';
                    }
                  }
                  return _buildChatBubble(context, text, isMe, timeStr);
                },
              );
            }),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    String text,
    bool isMe,
    String time,
  ) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: isMe
              ? []
              : [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha((0.05 * 255).round()),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyLarge?.color,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.textTheme.bodySmall?.color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          // ✅ DARI UPSTREAM: theme-aware shadow, lebih proper dari Colors.black12
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.12 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: theme.colorScheme.onPrimary,
                  size: 18,
                ),
                onPressed: () async {
                  final text = messageController.text.trim();
                  if (text.isNotEmpty) {
                    messageController.clear();
                    await chatC.sendMessage(conversationId, text);
                    _scrollToBottom();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}