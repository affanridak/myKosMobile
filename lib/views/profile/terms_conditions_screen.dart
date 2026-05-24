import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Syarat & Ketentuan',
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
                    'Selamat datang di MyKost. Dengan mengunduh, mengakses, atau menggunakan aplikasi MyKost, Anda setuju untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak setuju dengan semua syarat dan ketentuan ini, maka Anda dilarang menggunakan aplikasi ini.\n\n',
              ),
              TextSpan(
                text: '1. Penggunaan Layanan\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Aplikasi MyKost disediakan untuk membantu Anda mencari, memesan, dan mengelola penyewaan kost. Anda setuju untuk menggunakan layanan ini hanya untuk tujuan yang sah dan sesuai dengan hukum yang berlaku.\n\n',
              ),
              TextSpan(
                text: '2. Akun Pengguna\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Untuk menggunakan beberapa fitur Aplikasi, Anda mungkin diminta untuk mendaftarkan akun. Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk kata sandi, dan untuk semua aktivitas yang terjadi di bawah akun Anda.\n\n',
              ),
              TextSpan(
                text: '3. Pembayaran dan Transaksi\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Semua pembayaran yang dilakukan melalui Aplikasi harus menggunakan metode pembayaran yang sah dan disetujui. Harga sewa dapat berubah sewaktu-waktu sesuai kebijakan pemilik kost. Pembatalan dan pengembalian dana tunduk pada kebijakan masing-masing pemilik kost.\n\n',
              ),
              TextSpan(
                text: '4. Perubahan Syarat\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    'Kami berhak mengubah atau memodifikasi Syarat dan Ketentuan ini kapan saja. Perubahan akan berlaku segera setelah diposting di Aplikasi. Penggunaan Anda yang berkelanjutan atas Aplikasi setelah perubahan tersebut merupakan penerimaan Anda terhadap syarat baru.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
