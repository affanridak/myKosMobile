import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../models/kost_model.dart';
import '../../services/kost_service.dart';
import '../detail/detail_screen.dart';
import '../payment/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final KostService _kostService = KostService();
  List<Map<String, dynamic>> _wishlists = [];
  bool _isLoading = true;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _fetchWishlists();
  }

  Future<void> _fetchWishlists() async {
    setState(() {
      _isLoading = true;
      _selectedIndex = null;
    });
    final data = await _kostService.getWishlists();
    setState(() {
      _wishlists = data;
      _isLoading = false;
    });
  }

  Future<void> _removeWishlist(int propertyId) async {
    await _kostService.toggleWishlist(propertyId);
    _fetchWishlists();
    if (!mounted) return;
    Get.snackbar(
      'Dihapus',
      'Kost dihapus dari keranjang',
      backgroundColor: Theme.of(context).colorScheme.secondary,
      colorText: Theme.of(context).colorScheme.onSecondary,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Kost _toKost(Map<String, dynamic> w) {
    return Kost(
      id: w['property_id'],
      name: w['name'] ?? '',
      address: w['address'] ?? '',
      city: w['city'] ?? '',
      imageUrl: w['image_url'] ?? '',
      price: w['price'] ?? 0,
      type: w['type'] ?? '-',
      rating: (w['rating'] ?? 0).toDouble(),
      description: w['description'],
      latitude: (w['latitude'] ?? 0).toDouble(),
      longitude: (w['longitude'] ?? 0).toDouble(),
      rentalType: w['rental_type'] ?? 'monthly',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedKost = _selectedIndex != null
        ? _toKost(_wishlists[_selectedIndex!])
        : null;

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
          'Keranjang Saya',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: _fetchWishlists,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang kamu masih kosong',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cari Kost Sekarang',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha((0.08 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedIndex == null
                              ? 'Pilih 1 kost untuk di-checkout'
                              : 'Kost "${_toKost(_wishlists[_selectedIndex!]).name}" dipilih',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchWishlists,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24.0),
                      itemCount: _wishlists.length,
                      itemBuilder: (context, index) {
                        final item = _wishlists[index];
                        final kost = _toKost(item);
                        final isSelected = _selectedIndex == index;

                        return GestureDetector(
                          onTap: () => Get.to(() => DetailScreen(kost: kost)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : theme.dividerColor.withAlpha(
                                        (0.4 * 255).round(),
                                      ),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(
                                          (0.1 * 255).round(),
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = isSelected
                                          ? null
                                          : index;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(
                                      right: 12,
                                      top: 28,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : theme.dividerColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kost.imageUrl.startsWith('http')
                                      ? Image.network(
                                          kost.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, _) =>
                                              Container(
                                                width: 80,
                                                height: 80,
                                                color: theme.dividerColor
                                                    .withAlpha(
                                                      (0.2 * 255).round(),
                                                    ),
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: theme.dividerColor.withAlpha(
                                            (0.2 * 255).round(),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              kost.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                _removeWishlist(kost.id),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: theme.colorScheme.error,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              kost.location,
                                              style: TextStyle(
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(
                                            (0.1 * 255).round(),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          kost.type,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rp${kost.price}/bulan',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 14,
                                                color: AppColors.warning,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${kost.rating}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
      bottomNavigationBar: _wishlists.isEmpty
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha((0.16 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Harga',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          selectedKost != null
                              ? 'Rp${selectedKost.price}'
                              : 'Pilih kost dulu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: selectedKost != null
                                ? AppColors.primary
                                : theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedKost != null
                            ? AppColors.primary
                            : theme.dividerColor.withAlpha(
                                (0.85 * 255).round(),
                              ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: selectedKost == null
                          ? null
                          : () async {
                              final checkoutSuccess = await Get.to(
                                () => CheckoutScreen(kost: selectedKost),
                              );
                              if (checkoutSuccess == true) {
                                await _kostService.toggleWishlist(
                                  selectedKost.id,
                                );
                                _fetchWishlists();
                              }
                            },
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          color: selectedKost != null
                              ? Theme.of(context).colorScheme.onPrimary
                              : theme.textTheme.bodySmall?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
