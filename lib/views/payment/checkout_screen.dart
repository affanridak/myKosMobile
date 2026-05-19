import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/kost_model.dart';
import '../../services/kost_service.dart';
import '../../controllers/checkout_controller.dart';

class CheckoutScreen extends StatelessWidget {
  final Kost kost;
  final CheckoutController controller = Get.put(CheckoutController());

  CheckoutScreen({super.key, required this.kost}) {
    controller.duration.value = 1;
    controller.selectedDate.value = DateTime.now();
    controller.durationType.value = kost.rentalType; 
    controller.selectedRoomTypeId.value = kost.id;
  }

  Future<void> _submitRentalRequest() async {
    if (controller.selectedRoomTypeId.value == 0) {
      Get.snackbar('Gagal', 'Tipe kamar tidak ditemukan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    controller.isLoading.value = true;

    final result = await KostService().submitRentalRequest(
      roomTypeId: controller.selectedRoomTypeId.value,
      startDate: DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
      durationValue: controller.duration.value,
      durationType: controller.durationType.value,
    );

    controller.isLoading.value = false;

    if (result['success']) {
      Get.back(result: true);
      Get.snackbar(
        'Berhasil! 🎉',
        'Pengajuan sewa berhasil, menunggu persetujuan pemilik kost.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar('Gagal', result['message'] ?? 'Terjadi kesalahan',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Ringkasan Pesanan',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Kost',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kost.imageUrl.startsWith('http')
                        ? Image.network(kost.imageUrl,
                            width: 80, height: 80, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.home),
                                ))
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.home)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(kost.type,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        Text(kost.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(kost.location,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Detail Sewa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Obx(() => GestureDetector(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue
                                .withAlpha((0.1 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_month_outlined,
                              color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal Masuk',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(controller.selectedDate.value),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Text('Ubah',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 12),
            Obx(() {
              List<Map<String, String>> availableTypes = [];
              if (kost.rentalType == 'daily') {
                availableTypes = [{'value': 'daily', 'label': 'Harian'}];
              } else if (kost.rentalType == 'monthly') {
                availableTypes = [{'value': 'monthly', 'label': 'Bulanan'}];
              } else {
                availableTypes = [
                  {'value': 'monthly', 'label': 'Bulanan'},
                  {'value': 'daily', 'label': 'Harian'},
                ];
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha((0.1 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text('Tipe Sewa',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const Spacer(),
                    ...availableTypes.map((type) {
                      final isSelected = controller.durationType.value == type['value'];
                      return GestureDetector(
                        onTap: () => controller.setDurationType(type['value']!),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            type['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha((0.1 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Text('Lama Sewa',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          color: AppColors.textSecondary,
                          onPressed: controller.decrement,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        Obx(() => Text(
                              '${controller.duration.value} ${controller.durationType.value == 'monthly' ? 'Bln' : 'Hari'}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          color: AppColors.primary,
                          onPressed: controller.increment,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Rincian Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Obx(() {
                final int total = kost.price * controller.duration.value;
                final String label = controller.durationType.value == 'monthly'
                    ? '${controller.duration.value} Bulan'
                    : '${controller.duration.value} Hari';
                return Column(
                  children: [
                    _buildReceiptRow('Harga Sewa ($label)', 'Rp$total'),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    _buildReceiptRow('Total Pembayaran', 'Rp$total', isTotal: true),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final int finalTotal = kost.price * controller.duration.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Tagihan',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text('Rp$finalTotal',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                  ],
                );
              }),
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isLoading.value ? Colors.grey : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: controller.isLoading.value ? null : _submitRentalRequest,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Ajukan Sewa',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14)),
        Text(amount,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isTotal ? 16 : 14)),
      ],
    );
  }
}