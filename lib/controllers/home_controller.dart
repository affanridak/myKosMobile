import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/kost_model.dart';
import '../services/kost_service.dart';
import '../services/location_service.dart';

class HomeController extends GetxController {
  final KostService _kostService = KostService();

  final RxList<Kost> allKosts = <Kost>[].obs;
  final RxList<Kost> filteredKosts = <Kost>[].obs;

  final RxString selectedFilter = 'Semua'.obs;
  final RxBool isLoading = false.obs;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.grid_view, 'label': 'Semua'},
    {'icon': Icons.location_on_outlined, 'label': 'Terdekat'},
    {'icon': Icons.sell_outlined, 'label': 'Termurah'},
    {'icon': Icons.male, 'label': 'Putra'},
    {'icon': Icons.female, 'label': 'Putri'},
    {'icon': Icons.people_outline, 'label': 'Campuran'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    isLoading.value = true;

    try {
      final result = await _kostService.getProperties();

      // AMBIL LOKASI USER
      Position? userLocation = await LocationService.getCurrentLocation();

      // HITUNG JARAK USER -> KOST
      if (userLocation != null) {
        for (var kost in result) {
          kost.distance =
              Geolocator.distanceBetween(
                userLocation.latitude,
                userLocation.longitude,
                kost.latitude,
                kost.longitude,
              ) /
              1000;
        }

        // SORT DEFAULT TERDEKAT
        result.sort((a, b) => a.distance.compareTo(b.distance));
      }

      allKosts.value = result;

      // APPLY FILTER AKTIF
      setFilter(selectedFilter.value);
    } catch (e) {
      debugPrint('ERROR FETCH KOST: $e');
    }

    isLoading.value = false;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;

    // SEMUA
    if (filter == 'Semua') {
      filteredKosts.value = List.from(allKosts);
    }
    // TERDEKAT
    else if (filter == 'Terdekat') {
      filteredKosts.value = List.from(allKosts);

      filteredKosts.sort((a, b) => a.distance.compareTo(b.distance));
    }
    // TERMURAH
    else if (filter == 'Termurah') {
      filteredKosts.value = List.from(allKosts);

      filteredKosts.sort((a, b) => a.price.compareTo(b.price));
    }
    else {
      filteredKosts.value = allKosts.where((kost) {
        return kost.type.toLowerCase() == filter.toLowerCase();
      }).toList();
    }
  }

  Future<void> refreshData() async {
    await fetchProperties();
  }
}
