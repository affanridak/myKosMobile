import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Data mock notifikasi
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Pembayaran Berhasil! 🎉',
      'desc':
          'Pembayaran untuk Kost Nyaman Setiabudi bulan ini telah dikonfirmasi.',
      'time': 'Baru saja',
      'type': 'success',
      'isRead': false,
    },
    {
      'title': 'Pesan Baru dari Pemilik',
      'desc': 'Pemilik Kost Putri Mandiri membalas pesan Anda.',
      'time': '2 jam yang lalu',
      'type': 'chat',
      'isRead': false,
    },
    {
      'title': 'Jatuh Tempo Pembayaran',
      'desc':
          'Sewa kamar Anda akan berakhir dalam 3 hari. Segera lakukan perpanjangan.',
      'time': '1 hari yang lalu',
      'type': 'warning',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: AppColors.primary),
            onPressed: () {
              setState(() {
                for (var notif in notifications) {
                  notif['isRead'] = true;
                }
              });
              final theme = Theme.of(context);
              Get.snackbar(
                'Berhasil',
                'Semua notifikasi telah ditandai sebagai dibaca',
                backgroundColor: theme.colorScheme.secondary,
                colorText: theme.colorScheme.onSecondary,
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Dismissible(
            key: Key('${notif['title']}_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: theme.colorScheme.error,
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onError,
                size: 28,
              ),
            ),
            confirmDismiss: (direction) async {
              return await Get.dialog<bool>(
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
                          'Hapus Notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Apakah Anda yakin ingin menghapus notifikasi ini?',
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: theme.dividerColor),
                                ),
                                onPressed: () => Get.back(result: false),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
            },
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
              final theme = Theme.of(context);
              Get.snackbar(
                'Berhasil',
                'Notifikasi telah dihapus',
                backgroundColor: theme.colorScheme.secondary,
                colorText: theme.colorScheme.onSecondary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            child: _buildNotificationItem(notif),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (notif['type']) {
      case 'success':
        icon = Icons.check_circle_outline;
        iconColor = Theme.of(context).colorScheme.secondary;
        bgColor = Theme.of(
          context,
        ).colorScheme.secondary.withAlpha((0.1 * 255).round());
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.warning;
        bgColor = AppColors.warning.withAlpha((0.1 * 255).round());
        break;
      case 'chat':
        icon = Icons.chat_bubble_outline;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withAlpha((0.1 * 255).round());
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = Theme.of(context).iconTheme.color ?? Colors.grey;
        bgColor = (Theme.of(context).iconTheme.color ?? Colors.grey).withAlpha(
          (0.1 * 255).round(),
        );
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif['isRead']
            ? theme.cardColor
            : AppColors.primary.withAlpha((0.03 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: notif['isRead']
            ? Border.all(color: theme.dividerColor)
            : Border.all(
                color: AppColors.primary.withAlpha((0.3 * 255).round()),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Text(
                      notif['time'],
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif['desc'],
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
