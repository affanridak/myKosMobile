import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/complaint_model.dart';
import '../services/kost_service.dart';

class ReportController extends GetxController {
  final KostService _service = KostService();

  var complaints = <Complaint>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    isLoading.value = true;
    try {
      final result = await _service.getComplaints();
      complaints.assignAll(result.map((e) => Complaint.fromJson(e)).toList());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'process':
        return const Color(0xFFF59E0B);
      case 'done':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'process':
        return 'Diproses';
      case 'done':
        return 'Selesai';
      default:
        return 'Baru';
    }
  }
}