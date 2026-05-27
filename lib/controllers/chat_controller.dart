import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/kost_service.dart';

class ChatController extends GetxController {
  final KostService _kostService = KostService();

  final conversations = <Map<String, dynamic>>[].obs;
  final currentMessages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  int currentUserId = 0;

  @override
  void onInit() {
    super.onInit();
    _loadUserId();
    fetchConversations();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      // Ambil dari shared prefs kalau sudah disimpan
      // Atau bisa fetch dari /api/user
    }
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    final data = await _kostService.getConversations();
    conversations.value = data;
    isLoading.value = false;
  }

  Future<void> fetchMessages(int conversationId) async {
    isLoading.value = true;
    final data = await _kostService.getMessages(conversationId);
    currentMessages.value = data;
    isLoading.value = false;
  }

  Future<Map<String, dynamic>?> createOrGetConversation(int ownerId) async {
    return await _kostService.createOrGetConversation(ownerId);
  }

  Future<void> sendMessage(int conversationId, String message) async {
    final success = await _kostService.sendMessage(conversationId, message);
    if (success) {
      await fetchMessages(conversationId);
    }
  }

  Future<bool> deleteConversation(int conversationId) async {
    try {
      final success = await _kostService.deleteConversation(conversationId);
      return success;
    } catch (e) {
      return false;
    }
  }
}