import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'chat_detail_screen.dart';
import '../../controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatC = Get.put(ChatController());
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatC.fetchConversations();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        title: Text(
          'Pesan',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
                // ✅ DIAMBIL DARI UPSTREAM: dihapus `const` karena hintStyle pakai variabel `theme`
                // — stashed punya `const InputDecoration` tapi isinya runtime value, itu compile error
                decoration: InputDecoration(
                  hintText: 'Cari obrolan...',
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (chatC.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = chatC.conversations.where((chat) {
                final name = (chat['other_user']?['name'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada obrolan ditemukan.',
                    style: TextStyle(),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final chat = filtered[index];
                  final originalIndex = chatC.conversations.indexOf(chat);

                  String chatName = chat['other_user']?['name'] ?? 'Pengguna';
                  String lastMessage =
                      chat['last_message'] ?? 'Belum ada pesan';

                  return Dismissible(
                    key: Key(chat['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        return Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: theme.colorScheme.error,
                          child: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.onError,
                            size: 28,
                          ),
                        );
                      },
                    ),
                    confirmDismiss: (direction) async {
                      final confirmed = await Get.dialog<bool>(
                        Dialog(
                          backgroundColor: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    // ✅ DIAMBIL DARI UPSTREAM: pakai theme.colorScheme.error
                                    // lebih proper untuk dark mode vs hardcode Colors.red
                                    color: theme.colorScheme.error.withAlpha(
                                      (0.1 * 255).round(),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Hapus Obrolan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Apakah Anda yakin ingin menghapus obrolan ini secara permanen?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: theme.dividerColor,
                                          ),
                                        ),
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.error,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () => Get.back(result: true),
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: theme.colorScheme.onError,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (confirmed != true) return false;

                      final success = await chatC.deleteConversation(
                        chat['id'],
                      );

                      if (success) {
                        chatC.conversations.removeAt(originalIndex);
                        Get.snackbar(
                          'Berhasil',
                          'Obrolan telah dihapus',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                        return true;
                      } else {
                        Get.snackbar(
                          'Gagal',
                          'Gagal menghapus obrolan',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                        return false;
                      }
                    },
                    // ✅ DIAMBIL DARI STASHED: upstream punya chatC.deleteChat(chat.name)
                    // yang akan crash karena chat adalah Map, bukan object dengan .name
                    onDismissed: (_) {},
                    child: InkWell(
                      onTap: () => Get.to(
                        () => const ChatDetailScreen(),
                        arguments: {
                          'conversation_id': chat['id'],
                          'user_one_id': chat['user_one_id'],
                          'other_user': chat['other_user'],
                        },
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primary.withAlpha(
                                (0.2 * 255).round(),
                              ),
                              child: Text(
                                chatName.isNotEmpty
                                    ? chatName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chatName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lastMessage,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
