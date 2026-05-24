import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    controller.loadUser();
  }

  @override
  void dispose() {
    Get.delete<ProfileController>();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await controller.pickImage();
    setState(() {});
  }

  Future<void> _confirmAndSave(BuildContext context) async {
    final theme = Theme.of(context);
    final name = controller.nameController.text.trim();
    final phone = controller.phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama tidak boleh kosong',
        backgroundColor: theme.colorScheme.error,
        colorText: theme.colorScheme.onError,
      );
      return;
    }

    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^08[0-9]{9,11}$');
      if (!phoneRegex.hasMatch(phone)) {
        Get.snackbar(
          'Gagal',
          'Nomor HP tidak valid (contoh: 081234567890)',
          backgroundColor: theme.colorScheme.error,
          colorText: theme.colorScheme.onError,
        );
        return;
      }
    }

    final confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((0.1 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menyimpan perubahan profil?',
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
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final res = await controller.updateProfile(name: name, phone: phone);
      if (res.success) {
        Get.snackbar(
          'Sukses',
          res.message,
          backgroundColor: theme.colorScheme.secondary,
          colorText: theme.colorScheme.onSecondary,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Gagal',
          res.message,
          backgroundColor: theme.colorScheme.error,
          colorText: theme.colorScheme.onError,
        );
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ubah Profil',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() {
                      final img = controller.pickedImage.value;
                      ImageProvider? provider;
                      if (img != null) {
                        if (img is Uint8List) {
                          provider = MemoryImage(img);
                        } else if (img is File) {
                          provider = FileImage(img);
                        }
                      } else if (controller.avatarUrl.value.isNotEmpty) {
                        provider = NetworkImage(controller.avatarUrl.value);
                      }
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary,
                        backgroundImage: provider,
                        child: provider == null
                            ? Text(
                                controller.nameController.text.isNotEmpty
                                    ? controller.nameController.text[0]
                                          .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.cardColor,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInputField(
              context,
              'Nama Lengkap',
              Icons.person_outline,
              controller.nameController,
            ),
            const SizedBox(height: 16),
            _buildInputFieldReadOnly(
              context,
              'Email',
              Icons.email_outlined,
              controller.emailController,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              context,
              'Nomor Telepon',
              Icons.phone_outlined,
              controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _confirmAndSave(context),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(
                          color: theme.colorScheme.onPrimary,
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withAlpha((0.45 * 255).round()),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: theme.textTheme.bodySmall?.color),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldReadOnly(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.dividerColor.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tidak dapat diubah',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withAlpha((0.35 * 255).round()),
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: theme.textTheme.bodySmall?.color),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
        ),
      ],
    );
  }
}
