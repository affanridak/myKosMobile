import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/kost_model.dart';
import '../services/kost_service.dart';
import '../views/search/search_result_screen.dart';

class SearchKostController extends GetxController {
  final KostService _kostService = KostService();

  final locationController = TextEditingController();
  final selectedType = 'Semua'.obs;
  final kostTypes = ['Semua', 'Putra', 'Putri', 'Campuran'];
  final priceRange = const RangeValues(0, 2000000).obs;

  final facilities = [
    'Kamar Mandi Dalam',
    'AC',
    'WiFi',
    'Parkir Motor',
    'Dapur Bersama',
    'CCTV',
    'Penjaga 24 Jam',
    'Kipas Angin',
  ];

  final selectedFacilities = <String>[].obs;

  @override
  void onClose() {
    locationController.dispose();
    super.onClose();
  }

  void resetFilters() {
    locationController.clear();
    selectedType.value = 'Semua';
    priceRange.value = const RangeValues(0, 2000000);
    selectedFacilities.clear();
  }

  void toggleFacility(String facility, bool isSelected) {
    if (isSelected) {
      selectedFacilities.add(facility);
    } else {
      selectedFacilities.remove(facility);
    }
  }

  Future<List<Kost>> _fetchFiltered() async {
    final result = await _kostService.getProperties(
      type: selectedType.value == 'Semua' ? null : selectedType.value,
      search: locationController.text.trim().isEmpty
          ? null
          : locationController.text.trim(),
    );

    return result.where((kost) {
      return kost.price >= priceRange.value.start &&
          kost.price <= priceRange.value.end;
    }).toList();
  }

  void applyFilters() {
    final theme = Theme.of(Get.context!);

    Get.dialog(
      Dialog(
        backgroundColor: theme.colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha((0.1 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Menerapkan Filter...',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mencari kost yang sesuai',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    _fetchFiltered()
        .then((results) {
          Get.back();
          Get.to(
            () => SearchResultScreen(
              location: locationController.text.trim(),
              type: selectedType.value,
              minPrice: priceRange.value.start.toInt(),
              maxPrice: priceRange.value.end.toInt(),
              facilities: selectedFacilities.toList(),
              results: results,
            ),
          );
        })
        .catchError((_) {
          Get.back();
          final theme = Theme.of(Get.context!);
          Get.snackbar(
            'Error',
            'Gagal memuat data kost',
            backgroundColor: theme.colorScheme.error,
            colorText: theme.colorScheme.onError,
          );
        });
  }
}
