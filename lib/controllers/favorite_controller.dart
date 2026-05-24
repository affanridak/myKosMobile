import 'package:get/get.dart';
import '../models/kost_model.dart';
import '../services/kost_service.dart';

class FavoriteController extends GetxController {
  final KostService _kostService = KostService();

  var favorites = <Kost>[].obs;
  var selectedSort = 'Terbaru'.obs;
  var isLoading = false.obs;

  List<Kost> _originalFavorites = [];

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    isLoading.value = true;
    final result = await _kostService.getProperties();
    _originalFavorites = List.from(result);
    favorites.assignAll(_originalFavorites);
    isLoading.value = false;
  }

  void removeFavorite(int id) {
    favorites.removeWhere((item) => item.id == id);
    _originalFavorites.removeWhere((item) => item.id == id);
  }

  void sortFavorites(String sortType) {
    selectedSort.value = sortType;
    if (sortType == 'Terbaru') {
      favorites.assignAll(_originalFavorites);
    } else if (sortType == 'Termurah') {
      var sortedList = List<Kost>.from(favorites);
      sortedList.sort((a, b) => a.price.compareTo(b.price));
      favorites.assignAll(sortedList);
    }
  }
}
