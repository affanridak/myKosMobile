import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../services/kost_service.dart';
import '../main_layout.dart';
import 'payment_method_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int rentalRequestId;

  const OrderDetailScreen({super.key, required this.rentalRequestId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final KostService _kostService = KostService();
  Map<String, dynamic>? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final data =
        await _kostService.getRentalRequestDetail(widget.rentalRequestId);
    setState(() {
      _detail = data;
      _isLoading = false;
    });
  }

  Color _getColor(String colorStr) {
    switch (colorStr) {
      case 'green':  return Colors.green;
      case 'orange': return Colors.orange;
      case 'red':    return Colors.red;
      default:       return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ?? theme.cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Get.back(),
          ),
          title: Text('Detail Pengajuan',
              style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_detail == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Data tidak ditemukan'),
              ElevatedButton(
                  onPressed: () => Get.back(), child: const Text('Kembali')),
            ],
          ),
        ),
      );
    }

    final property = _detail!['property'] ?? {};
    final roomType = _detail!['room_type'] ?? {};
    final status = _detail!['status'] ?? 'pending';
    final statusLabel = _detail!['status_label'] ?? '-';
    final statusColor = _getColor(_detail!['status_color'] ?? 'grey');
    final totalPrice =
        (roomType['price'] ?? 0) * (_detail!['duration_value'] ?? 1);
    final isApproved = status == 'approved';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text('Detail Pengajuan',
            style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: _fetchDetail,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha((0.1 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.check_circle
                          : status == 'rejected'
                              ? Icons.cancel
                              : Icons.access_time,
                      color: statusColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusLabel,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _detail!['created_at'] ?? '-',
                    style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info Kost
            Text('Informasi Kost',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: property['image_url'] != null &&
                            property['image_url'].toString().startsWith('http')
                        ? Image.network(property['image_url'],
                            width: 80, height: 80, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: theme.dividerColor,
                                child: const Icon(Icons.home)))
                        : Container(
                            width: 80,
                            height: 80,
                            color: theme.dividerColor,
                            child: const Icon(Icons.home)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property['name'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          '${property['address'] ?? ''}, ${property['city'] ?? ''}',
                          style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(roomType['name'] ?? '-',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail Pengajuan
            Text('Detail Pengajuan',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildRow(context, 'Tanggal Masuk',
                      _detail!['start_date'] ?? '-'),
                  const Divider(height: 20),
                  _buildRow(
                      context,
                      'Lama Sewa',
                      '${_detail!['duration_value']} ${_detail!['duration_type'] == 'monthly' ? 'Bulan' : 'Hari'}'),
                  if (_detail!['note'] != null &&
                      _detail!['note'].toString().isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildRow(context, 'Catatan', _detail!['note']),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rincian Pembayaran
            Text('Rincian Pembayaran',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildRow(
                      context,
                      'Harga per ${_detail!['duration_type'] == 'monthly' ? 'Bulan' : 'Hari'}',
                      'Rp${roomType['price'] ?? 0}'),
                  const Divider(height: 20),
                  _buildRow(
                      context,
                      'Durasi',
                      '× ${_detail!['duration_value']}'),
                  const Divider(height: 20),
                  _buildRow(context, 'Total', 'Rp$totalPrice',
                      isTotal: true),
                ],
              ),
            ),

            // Info jika pending
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Pengajuan kamu sedang menunggu persetujuan pemilik kost. Kamu akan mendapat notifikasi saat disetujui.',
                        style:
                            TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Info jika rejected
            if (status == 'rejected') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined,
                        color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pengajuan kamu ditolak oleh pemilik kost. Kamu bisa mencari kost lain.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha((0.12 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: isApproved
              // Jika approved → tampilkan tombol bayar
              ? SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Get.to(() => PaymentMethodScreen(
                          totalAmount: totalPrice,
                        )),
                    child: const Text('Lanjut Bayar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              // Jika pending/rejected → tombol ke beranda
              : SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Get.offAll(() => MainLayout()),
                    child: const Text('Ke Beranda',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isTotal
                    ? theme.textTheme.bodyLarge?.color
                    : theme.textTheme.bodySmall?.color,
                fontWeight:
                    isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14)),
        Text(value,
            style: TextStyle(
                color: isTotal
                    ? AppColors.primary
                    : theme.textTheme.bodyLarge?.color,
                fontWeight:
                    isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isTotal ? 16 : 14)),
      ],
    );
  }
}