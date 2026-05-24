import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/kost_model.dart';
import '../../services/kost_service.dart';
import '../payment/checkout_screen.dart';
import '../chat/chat_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final data = await _kostService.getPropertyDetail(widget.kost.id);
    setState(() {
      _detail = data;
      _isLoading = false;
    });
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

  List<String> get _gallery {
    final imgs = _detail?['images'];
    if (imgs is List && imgs.isNotEmpty) return imgs.cast<String>();
    return [widget.kost.imageUrl];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kost = widget.kost;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.iconTheme.color),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      itemCount: _gallery.length,
                      itemBuilder: (context, i) => Image.network(
                        _gallery[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, _) => Container(
                          color: theme.dividerColor.withAlpha(
                            (0.12 * 255).round(),
                          ),
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kost.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Rp${kost.price}/bulan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on, color: Colors.deepPurple),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                kost.location,
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _detail?['description'] ?? kost.description ?? '-',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOwnerInfo(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: theme.cardColor,
        child: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Get.to(() => const ChatDetailScreen()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isAddingWishlist ? null : _addToWishlist,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAddingWishlist
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.bookmark_border,
                          color: theme.iconTheme.color,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Get.to(() => CheckoutScreen(kost: widget.kost)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sewa Sekarang',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildOwnerInfo(ThemeData theme) {
    final owner = _detail?['owner'];
    final name = owner?['name'] ?? '-';
    final phone = owner?['phone'] ?? '-';
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withAlpha((0.1 * 255).round()),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phone.isNotEmpty && phone != '-' ? phone : 'Belum ada nomor HP',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
