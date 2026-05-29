import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../models/kost_model.dart';
import '../../services/kost_service.dart';
import '../payment/checkout_screen.dart';
import '../chat/chat_detail_screen.dart';
import '../report/report_detail_screen.dart';
import '../../controllers/chat_controller.dart';

class DetailScreen extends StatefulWidget {
  final Kost kost;
  const DetailScreen({super.key, required this.kost});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final KostService _kostService = KostService();
  Map<String, dynamic>? _detail;
  bool _isLoading = true;
  bool _isAddingWishlist = false;
  int _currentImageIndex = 0;
  bool _hasActiveContract = false;
  int? _activePropertyId;
  int? _activeContractId;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final data = await _kostService.getPropertyDetail(widget.kost.id);
    final contracts = await _kostService.getContracts();

    bool hasActive = false;
    int? contractId;

    for (final c in contracts) {
      if (c['status'] == 'Aktif') {
        final property = c['property'];
        if (property != null &&
            property['id'].toString() == widget.kost.id.toString()) {
          hasActive = true;
          contractId = c['id'];
          break;
        }
      }
    }

    setState(() {
      _detail = data;
      _isLoading = false;
      _hasActiveContract = hasActive;
      _activePropertyId = widget.kost.id;
      _activeContractId = contractId;
    });
  }

  List<String> get _gallery {
    if (_detail == null) return [widget.kost.imageUrl];
    final images = List<String>.from(_detail!['images'] ?? []);
    return images.isEmpty ? [widget.kost.imageUrl] : images;
  }

  Future<void> _openMaps() async {
    final lat = _detail?['latitude'];
    final lng = _detail?['longitude'];
    final name = Uri.encodeComponent(widget.kost.name);
    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$name');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _addToWishlist() async {
    setState(() => _isAddingWishlist = true);
    final added = await _kostService.toggleWishlist(widget.kost.id);
    if (!mounted) return;
    final theme = Theme.of(context);
    if (added) {
      Get.snackbar(
        'Berhasil',
        'Kost ditambahkan ke wishlist',
        backgroundColor: theme.colorScheme.secondary,
        colorText: theme.colorScheme.onSecondary,
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal menambahkan wishlist',
        backgroundColor: theme.colorScheme.error,
        colorText: theme.colorScheme.onError,
      );
    }
    setState(() => _isAddingWishlist = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kost = widget.kost;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(
                        (0.9 * 255).round(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          onPageChanged: (index) =>
                              setState(() => _currentImageIndex = index),
                          itemCount: _gallery.length,
                          itemBuilder: (context, index) {
                            final imagePath = _gallery[index];
                            return imagePath.startsWith('http')
                                ? Image.network(imagePath, fit: BoxFit.cover)
                                : Image.asset(imagePath, fit: BoxFit.cover);
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _gallery.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 8,
                                width: _currentImageIndex == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kost.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withAlpha(
                                  (0.15 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.warning,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${kost.rating}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${_detail?['review_count'] ?? 0} ulasan)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                kost.location,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp${kost.price}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                ' /bulan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _detail?['description'] ?? kost.description ?? '-',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        Divider(
                          color: Colors.grey.shade100,
                          thickness: 8,
                          height: 48,
                        ),
                        _buildFasilitas(),
                        Divider(
                          color: Colors.grey.shade100,
                          thickness: 8,
                          height: 48,
                        ),
                        _buildPeraturan(),
                        Divider(
                          color: Colors.grey.shade100,
                          thickness: 8,
                          height: 48,
                        ),
                        _buildLokasi(),
                        Divider(
                          color: Colors.grey.shade100,
                          thickness: 8,
                          height: 48,
                        ),
                        _buildOwnerInfo(),
                        Divider(
                          color: Colors.grey.shade100,
                          thickness: 8,
                          height: 48,
                        ),
                        _buildUlasan(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    final detail = _detail;
                    if (detail == null) return;
                    final ownerId = detail['owner']?['id'];
                    if (ownerId == null) {
                      Get.snackbar(
                        'Gagal',
                        'Data pemilik kost tidak ditemukan',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    final chatC = Get.put(ChatController());
                    final conversation =
                        await chatC.createOrGetConversation(ownerId);
                    if (conversation != null) {
                      Get.to(
                        () => const ChatDetailScreen(),
                        arguments: {
                          'conversation_id': conversation['id'],
                          'user_one_id': conversation['user_one_id'],
                          'other_user': conversation['other_user'],
                        },
                      );
                    } else {
                      Get.snackbar(
                        'Gagal',
                        'Gagal membuka obrolan',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _hasActiveContract
                          ? Colors.orange
                          : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _hasActiveContract
                      ? () => Get.to(
                            () => ReportDetailScreen(
                              prefilledPropertyId:
                                  _activePropertyId ?? widget.kost.id,
                              prefilledContractId: _activeContractId,
                            ),
                            transition: Transition.fadeIn,
                          )
                      : (_isAddingWishlist ? null : _addToWishlist),
                  child: _hasActiveContract
                      ? const Icon(
                          Icons.report_problem_outlined,
                          color: Colors.orange,
                        )
                      : _isAddingWishlist
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.bookmark_border,
                              color: AppColors.primary,
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () =>
                        Get.to(() => CheckoutScreen(kost: widget.kost)),
                    child: Text(
                      _hasActiveContract ? 'Perpanjang Sewa' : 'Sewa Sekarang',
                      style: const TextStyle(
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildListItem(
    IconData icon,
    String title, {
    Color iconColor = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFasilitas() {
    final roomFacilities =
        _detail?['room_types'] != null &&
            (_detail!['room_types'] as List).isNotEmpty
        ? List<String>.from(
            (_detail!['room_types'][0]['room_facilities'] ?? []),
          )
        : <String>[];
    final propertyFacilities = List<String>.from(
      _detail?['property_facilities'] ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fasilitas'),
        if (roomFacilities.isNotEmpty) ...[
          const Text(
            'Fasilitas Kamar',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...roomFacilities.map((f) => _buildListItem(_facilityIcon(f), f)),
          const SizedBox(height: 16),
        ],
        if (propertyFacilities.isNotEmpty) ...[
          const Text(
            'Fasilitas Umum',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...propertyFacilities.map(
            (f) => _buildListItem(_facilityIcon(f), f),
          ),
        ],
      ],
    );
  }

  IconData _facilityIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('wifi') || n.contains('wi-fi')) return Icons.wifi;
    if (n.contains('ac')) return Icons.ac_unit;
    if (n.contains('kasur')) return Icons.bed_outlined;
    if (n.contains('lemari')) return Icons.door_sliding_outlined;
    if (n.contains('meja')) return Icons.desk;
    if (n.contains('parkir')) return Icons.local_parking_outlined;
    if (n.contains('dapur')) return Icons.kitchen_outlined;
    if (n.contains('kamar mandi')) return Icons.bathtub_outlined;
    if (n.contains('cctv')) return Icons.videocam_outlined;
    if (n.contains('jemuran')) return Icons.dry_outlined;
    if (n.contains('kipas')) return Icons.air;
    if (n.contains('kursi')) return Icons.chair_outlined;
    if (n.contains('penjaga')) return Icons.security;
    if (n.contains('ruang tamu')) return Icons.living_outlined;
    return Icons.check_circle_outline;
  }

  Widget _buildPeraturan() {
    final rules = _detail?['rules'] ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Peraturan Kost'),
        ...rules
            .toString()
            .split('.')
            .where((s) => s.trim().isNotEmpty)
            .map(
              (rule) => _buildListItem(
                Icons.do_not_disturb_alt_outlined,
                rule.trim(),
                iconColor: Colors.red,
              ),
            ),
      ],
    );
  }

  Widget _buildLokasi() {
    final address = _detail?['address'] ?? widget.kost.address;
    final city = _detail?['city'] ?? widget.kost.city;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lokasi'),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$address, $city',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _openMaps,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withAlpha((0.2 * 255).round()),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 40, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Buka di Google Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo() {
    final owner = _detail?['owner'];
    final name = owner?['name'] ?? '-';
    final phone = owner?['phone'] ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profil Tuan Kost'),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withAlpha(
                (0.1 * 255).round(),
              ),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone.isNotEmpty && phone != '-'
                        ? phone
                        : 'Belum ada nomor HP',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUlasan() {
    final reviews = List<Map<String, dynamic>>.from(_detail?['reviews'] ?? []);
    final reviewCount = _detail?['review_count'] ?? 0;
    final avgRating = widget.kost.rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ulasan Penyewa'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$avgRating',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      ' / 5.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Berdasarkan $reviewCount ulasan',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (reviews.isEmpty)
          const Text(
            'Belum ada ulasan',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...reviews.map(
            (review) => _buildReviewItem(
              review['name'] ?? 'Anonim',
              review['date'] ?? '',
              (review['rating'] ?? 0).toInt(),
              review['comment'] ?? '',
            ),
          ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String date, int rating, String review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withAlpha(
                  (0.1 * 255).round(),
                ),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}