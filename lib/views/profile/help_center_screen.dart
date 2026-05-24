import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
          'Pusat Bantuan',
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
          Container(
            padding: const EdgeInsets.all(24),
            color: theme.scaffoldBackgroundColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withAlpha((0.35 * 255).round()),
                ),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                decoration: InputDecoration(
                  hintText: 'Cari topik bantuan...',
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Pertanyaan Populer (FAQ)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFaqItem(
                  context,
                  'Bagaimana cara menyewa kos?',
                  'Anda dapat mencari kos yang diinginkan, masuk ke halaman detail, lalu klik tombol "Hubungi Pemilik" atau "Sewa Sekarang" untuk melanjutkan ke proses pembayaran.',
                ),
                _buildFaqItem(
                  context,
                  'Apakah bisa membatalkan pesanan?',
                  'Pembatalan pesanan dapat dilakukan maksimal 1x24 jam setelah pembayaran berhasil, sesuai dengan kebijakan masing-masing pemilik kos.',
                ),
                _buildFaqItem(
                  context,
                  'Metode pembayaran apa saja yang tersedia?',
                  'Kami menerima pembayaran melalui Transfer Bank (Virtual Account) dan beberapa layanan E-Wallet seperti GoPay, OVO, dan Dana.',
                ),
                _buildFaqItem(
                  context,
                  'Bagaimana jika pemilik kos tidak membalas chat?',
                  'Jika pemilik kos tidak merespons dalam 1x24 jam, Anda dapat menekan tombol "Laporkan Kendala" atau menghubungi layanan Customer Service kami.',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha((0.14 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primary.withAlpha((0.5 * 255).round()),
                ),
                backgroundColor: AppColors.primary.withAlpha(
                  (0.05 * 255).round(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.support_agent, color: AppColors.primary),
              label: Text(
                'Hubungi Customer Service',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withAlpha((0.35 * 255).round()),
        ),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: theme.textTheme.bodySmall?.color,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
