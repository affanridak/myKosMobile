import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../services/kost_service.dart';
import '../payment/order_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
  final KostService _kostService = KostService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua', 'Menunggu', 'Disetujui', 'Ditolak'
  ];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    final data = await _kostService.getRentalRequests();
    setState(() {
      _requests = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'Semua') return _requests;
    return _requests
        .where((r) => r['status_label'] == _selectedFilter)
        .toList();
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
          'Riwayat Pengajuan',
          style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color,
                            fontSize: 12,
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
                            if (selected) {
                              setState(() => _selectedFilter = f);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 80,
                                  color: theme.dividerColor),
                              const SizedBox(height: 16),
                              Text('Belum ada pengajuan',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge
                                          ?.color)),
                              const SizedBox(height: 8),
                              Text(
                                'Pengajuan sewa kost akan muncul di sini',
                                style: TextStyle(
                                    color:
                                        theme.textTheme.bodySmall?.color),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchRequests,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final r = _filtered[index];
                              final color =
                                  _getColor(r['status_color'] ?? 'grey');
                              final property = r['property'] ?? {};
                              final roomType = r['room_type'] ?? {};

                              return GestureDetector(
                                onTap: () => Get.to(
                                  () => OrderDetailScreen(
                                    rentalRequestId: r['id'],
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                        color: theme.dividerColor
                                            .withAlpha(
                                                (0.35 * 255).round())),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(r['created_at'] ?? '-',
                                              style: TextStyle(
                                                  color: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                                  fontSize: 12)),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: color.withAlpha(
                                                  (0.1 * 255).round()),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              r['status_label'] ?? '-',
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: property['image_url'] !=
                                                        null &&
                                                    property['image_url']
                                                        .toString()
                                                        .startsWith('http')
                                                ? Image.network(
                                                    property['image_url'],
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_,
                                                            __,
                                                            ___) =>
                                                        Container(
                                                      width: 56,
                                                      height: 56,
                                                      color: theme
                                                          .dividerColor,
                                                      child: const Icon(
                                                          Icons
                                                              .home_work_outlined,
                                                          color: AppColors
                                                              .primary),
                                                    ))
                                                : Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration:
                                                        BoxDecoration(
                                                      color: AppColors
                                                          .primary
                                                          .withAlpha(
                                                              (0.1 * 255)
                                                                  .round()),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                    ),
                                                    child: const Icon(
                                                        Icons
                                                            .home_work_outlined,
                                                        color: AppColors
                                                            .primary),
                                                  ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  property['name'] ?? '-',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  roomType['name'] ?? '-',
                                                  style: TextStyle(
                                                      color: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${r['duration_value']} ${r['duration_type'] == 'monthly' ? 'Bulan' : 'Hari'} • mulai ${r['start_date']}',
                                                  style: TextStyle(
                                                      color: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                                      fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total',
                                              style: TextStyle(
                                                  color: theme.textTheme
                                                      .bodySmall?.color,
                                                  fontSize: 12)),
                                          Text(
                                            'Rp${(roomType['price'] ?? 0) * (r['duration_value'] ?? 1)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.primary),
                                          ),
                                        ],
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
}