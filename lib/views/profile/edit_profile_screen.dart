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

  Future<void> _confirmAndSave() async {
    final name = controller.nameController.text.trim();
    final phone = controller.phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^08[0-9]{9,11}$');
      if (!phoneRegex.hasMatch(phone)) {
        Get.snackbar(
          'Gagal',
          'Nomor HP tidak valid (contoh: 081234567890)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    final confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.white,
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
              const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin menyimpan perubahan profil?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Batal'),
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Gagal',
          res.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Ubah Profil',
          style: TextStyle(
            color: Colors.black,
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
                        if (img is Uint8List)
                          provider = MemoryImage(img);
                        else if (img is File)
                          provider = FileImage(img);
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
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
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
              'Nama Lengkap',
              Icons.person_outline,
              controller.nameController,
            ),
            const SizedBox(height: 16),
            _buildInputFieldReadOnly(
              'Email',
              Icons.email_outlined,
              controller.emailController,
            ),
            const SizedBox(height: 16),
            _buildInputField(
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
                      : _confirmAndSave,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
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
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade600),
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
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tidak dapat diubah',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}
