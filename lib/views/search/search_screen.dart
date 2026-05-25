// lib/views/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_inputs.dart'; // Menggunakan button yang sudah dibuat
import '../../controllers/search_controller.dart';

class SearchScreen extends StatelessWidget {
  final SearchKostController searchC = Get.put(SearchKostController());

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Filter Pencarian',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: searchC.resetFilters,
            child: const Text('Reset', style: TextStyle()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama atau Lokasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withAlpha(50),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchC.locationController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Misal: Jember, Jawa Timur',
                  hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(Icons.my_location, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Tipe Kost',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: searchC.kostTypes.map((type) {
                    final isSelected = searchC.selectedType.value == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: theme.cardColor,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : theme.dividerColor.withAlpha(50),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            searchC.selectedType.value = type;
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Rentang Harga',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => RangeSlider(
                values: searchC.priceRange.value,
                min: 0,
                max: 5000000,
                divisions: 50,
                activeColor: AppColors.primary,
                inactiveColor: theme.dividerColor,
                labels: RangeLabels(
                  'Rp${(searchC.priceRange.value.start / 1000).round()} rb',
                  'Rp${(searchC.priceRange.value.end / 1000000).toStringAsFixed(1)} jt+',
                ),
                onChanged: (RangeValues values) {
                  searchC.priceRange.value = values;
                },
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp${(searchC.priceRange.value.start / 1000).round()} rb',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rp${(searchC.priceRange.value.end / 1000000).toStringAsFixed(1)} jt+',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Fasilitas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 12,
                children: searchC.facilities.map((facility) {
                  bool isSelected = searchC.selectedFacilities.contains(
                    facility,
                  );
                  return ChoiceChip(
                    label: Text(facility),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.textTheme.bodyLarge?.color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: theme.cardColor,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : theme.dividerColor.withAlpha(50),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      searchC.toggleFacility(facility, selected);
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha((0.12 * 255).round()),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Terapkan Filter',
            onPressed: searchC.applyFilters,
          ),
        ),
      ),
    );
  }
}
