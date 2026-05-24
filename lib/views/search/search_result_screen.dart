import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../models/kost_model.dart';
import '../../services/kost_service.dart';
import '../detail/detail_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String location;
  final String type;
  final int minPrice;
  final int maxPrice;
  final List<String> facilities;
  final List<Kost> results;

  const SearchResultScreen({
    super.key,
    required this.location,
    required this.type,
    required this.minPrice,
    required this.maxPrice,
    required this.facilities,
    required this.results,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final KostService _kostService = KostService();
  late List<Kost> _displayResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayResults = List.from(widget.results);
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final result = await _kostService.getProperties();
      setState(() {
        _displayResults = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color ?? theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Hasil Pencarian',
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
            onPressed: _fetchAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _displayResults.isEmpty
          ? _buildEmptyState(context)
          : _buildListResults(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Kost tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba sesuaikan filter pencarianmu.',
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildListResults(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _displayResults.length,
      itemBuilder: (context, index) {
        final kost = _displayResults[index];
        return GestureDetector(
          onTap: () => Get.to(() => DetailScreen(kost: kost)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha((0.02 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildImage(context, kost.imageUrl),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBadge(kost.type),
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
                        _buildLocationInfo(context, kost.location),
                        if (kost.distance > 0)
                          _buildDistanceInfo(kost.distance),
                        const SizedBox(height: 8),
                        _buildPriceAndRating(kost.price, kost.rating),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, String url) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: url.startsWith('http')
          ? Image.network(
              url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 120,
                height: 120,
                color: theme.dividerColor.withAlpha((0.4 * 255).round()),
                child: Icon(
                  Icons.image_not_supported,
                  color: theme.iconTheme.color,
                ),
              ),
            )
          : Image.asset(url, width: 120, height: 120, fit: BoxFit.cover),
    );
  }

  Widget _buildBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, String location) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo(double distance) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.near_me, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '${distance.toStringAsFixed(1)} km',
            style: const TextStyle(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndRating(int price, double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rp$price',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              '$rating',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
