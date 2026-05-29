import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/device_access_controller.dart';
import '../../theme/app_colors.dart';

class DeviceAccessScreen extends StatelessWidget {
  const DeviceAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceAccessController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Kelola Akses Perangkat',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.devices.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada perangkat aktif ditemukan.',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withAlpha(153),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.devices.length,
          itemBuilder: (context, index) {
            final device = controller.devices[index];
            final isCurrent = device['is_current'] == true;

            return Card(
              color: theme.cardColor,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: isCurrent
                      ? Colors.green.withAlpha(38)
                      : Colors.blue.withAlpha(38),
                  child: Icon(
                    isCurrent ? Icons.phonelink_ring : Icons.devices,
                    color: isCurrent ? Colors.green : Colors.blue,
                  ),
                ),
                title: Text(
                  device['name'] ?? 'Perangkat Tidak Dikenal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      isCurrent
                          ? 'Perangkat ini'
                          : 'Terakhir aktif: ${device['last_used_at'] ?? 'Tidak diketahui'}',
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.green
                            : theme.textTheme.bodyMedium?.color?.withAlpha(153),
                        fontSize: 12,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Login sejak: ${device['created_at']}',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(
                          153,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: isCurrent
                    ? const SizedBox()
                    : IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () {
                          _confirmRevoke(context, controller, device['id']);
                        },
                      ),
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmRevoke(
    BuildContext context,
    DeviceAccessController controller,
    int tokenId,
  ) {
    final theme = Theme.of(context);
    Get.defaultDialog(
      title: 'Cabut Akses',
      middleText:
          'Apakah Anda yakin ingin mencabut akses (logout) dari perangkat ini?',
      textConfirm: 'Cabut',
      textCancel: 'Batal',
      confirmTextColor: theme.colorScheme.onError,
      buttonColor: theme.colorScheme.error,
      cancelTextColor: theme.textTheme.bodyMedium?.color,
      onConfirm: () {
        Get.back(); // close confirmation dialog
        controller.revokeDevice(tokenId);
      },
    );
  }
}
