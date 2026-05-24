import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Kebijakan Privasi',
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
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
              height: 1.6,
              fontFamily: theme.textTheme.bodyMedium?.fontFamily,
            ),
            children: [
              TextSpan(
                text: 'Terakhir diperbarui: 28 April 2026\n\n',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              TextSpan(
                text:
                    'Selamat datang di MyKost. Kami menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan menjaga informasi Anda saat Anda menggunakan aplikasi mobile kami.\n\n',
              ),
              TextSpan(
                text: '1. Informasi yang Kami Kumpulkan\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Kami dapat mengumpulkan informasi tentang Anda dalam berbagai cara. Informasi yang dapat kami kumpulkan melalui Aplikasi meliputi data pribadi (nama, email, no. telp) dan data derivatif (log aktivitas).\n\n',
              ),
              TextSpan(
                text: '2. Penggunaan Informasi Anda\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Memiliki informasi yang akurat tentang Anda memungkinkan kami untuk memberikan Anda pengalaman yang lancar, efisien, dan disesuaikan. Secara khusus, kami dapat menggunakan informasi yang dikumpulkan tentang Anda melalui Aplikasi untuk:\n'
                    '   • Membuat dan mengelola akun Anda.\n'
                    '   • Memproses pembayaran dan pengembalian dana Anda.\n'
                    '   • Mengirimi Anda email mengenai akun atau pesanan Anda.\n'
                    '   • Meningkatkan efisiensi dan pengoperasian Aplikasi.\n'
                    '   • Memantau dan menganalisis penggunaan dan tren untuk meningkatkan pengalaman Anda dengan Aplikasi.\n\n',
              ),
              TextSpan(
                text: '3. Keamanan Informasi Anda\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Kami menggunakan langkah-langkah keamanan administratif, teknis, dan fisik untuk membantu melindungi informasi pribadi Anda. Meskipun kami telah mengambil langkah-langkah yang wajar untuk mengamankan informasi pribadi yang Anda berikan kepada kami, perlu diketahui bahwa tidak ada langkah-langkah keamanan yang sempurna atau tidak dapat ditembus.\n\n',
              ),
              TextSpan(
                text: '4. Hubungi Kami\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Jika Anda memiliki pertanyaan atau komentar tentang Kebijakan Privasi ini, silakan hubungi kami di support@mykost.com',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
