import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../models/kost_model.dart';
import '../../services/kost_service.dart';
import '../search/search_screen.dart';
import '../detail/detail_screen.dart';

class MyKostScreen extends StatefulWidget {
  const MyKostScreen({super.key});

  @override
  State<MyKostScreen> createState() => _MyKostScreenState();
}

class _MyKostScreenState extends State<MyKostScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Aktif', 'Selesai'];
  final KostService _kostService = KostService();

  List<Map<String, dynamic>> _contracts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    setState(() => _isLoading = true);
    final data = await _kostService.getContracts();
    setState(() {
      _contracts = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'Semua') return _contracts;
    return _contracts.where((c) => c['status'] == _selectedFilter).toList();
  }

  Kost _contractToKost(Map<String, dynamic> contract) {
    final p = contract['property'];
    return Kost(
      id: p['id'],
      name: p['name'] ?? '',
      address: p['address'] ?? '',
      city: p['city'] ?? '',
      imageUrl: p['image_url'] ?? '',
      price: contract['price'] ?? 0,
      type: p['type'] ?? '-',
      rating: (p['rating'] ?? 0).toDouble(),
      description: p['description'],
      latitude: (p['latitude'] ?? 0).toDouble(),
      longitude: (p['longitude'] ?? 0).toDouble(),
      rentalType: p['rental_type'] ?? 'monthly',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        title: Text(
          'Kost Saya',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.iconTheme.color ?? theme.textTheme.bodyLarge?.color,
            ),
            onPressed: _fetchContracts,
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : theme.textTheme.bodyLarge?.color,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : theme.dividerColor,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_kost_illustration.png',
                            width: 260,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Kamu belum punya kos, temukan kos mu sekarang',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Get.to(() => SearchScreen()),
                              child: Text(
                                'Cari Kos Sekarang',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchContracts,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final contract = _filtered[index];
                        final kost = _contractToKost(contract);
                        final statusText = contract['status'] as String;
                        final statusColor = statusText == 'Aktif'
                            ? Theme.of(context).colorScheme.secondary
                            : (theme.textTheme.bodySmall?.color ?? Colors.grey);
                        final int contractId = contract['id'] ?? 0;
                        final bool hasReviewed =
                            contract['has_review'] ?? false;

                        return GestureDetector(
                          onTap: () => Get.to(() => DetailScreen(kost: kost)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withAlpha(
                                    (0.02 * 255).round(),
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kost.imageUrl.startsWith('http')
                                      ? Image.network(
                                          kost.imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, _) =>
                                              Container(
                                                width: 100,
                                                height: 100,
                                                color: theme.dividerColor
                                                    .withAlpha(
                                                      (0.2 * 255).round(),
                                                    ),
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                        )
                                      : Image.asset(
                                          'assets/images/banner2.png',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withAlpha(
                                                (0.1 * 255).round(),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              hasReviewed
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 22,
                                              color: AppColors.warning,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: hasReviewed
                                                ? null
                                                : () => _showUlasanDialog(
                                                    contractId,
                                                  ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        kost.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        contract['room_type'] ?? '',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 11,
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${contract['start_date']} - ${contract['end_date']}',
                                            style: TextStyle(
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rp${kost.price}/bulan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showUlasanDialog(int contractId) {
    int currentRating = 0;
    final TextEditingController commentController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Get.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            final theme = Theme.of(context);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beri Ulasan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () =>
                            setStateDialog(() => currentRating = index + 1),
                        icon: Icon(
                          index < currentRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.warning,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalaman Anda...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
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
                          onPressed: () => Get.back(),
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
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (currentRating == 0) {
                              Get.snackbar(
                                'Peringatan',
                                'Silakan pilih rating terlebih dahulu',
                                backgroundColor: theme.colorScheme.secondary,
                                colorText: theme.colorScheme.onSecondary,
                              );
                              return;
                            }

                            Get.back();

                            final result = await _kostService.submitReview(
                              contractId: contractId,
                              rating: currentRating,
                              comment: commentController.text,
                            );

                            if (result['success'] == true) {
                              Get.snackbar(
                                'Sukses',
                                'Terima kasih atas ulasan Anda!',
                                backgroundColor: theme.colorScheme.secondary,
                                colorText: theme.colorScheme.onSecondary,
                              );
                              _fetchContracts();
                            } else {
                              Get.snackbar(
                                'Gagal',
                                result['message'] ?? 'Gagal mengirim ulasan',
                                backgroundColor: theme.colorScheme.error,
                                colorText: theme.colorScheme.onError,
                              );
                            }
                          },
                          child: Text(
                            'Kirim',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
