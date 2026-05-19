import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  var duration = 1.obs;
  var selectedDate = DateTime.now().obs;
  var isLoading = false.obs;
  var selectedRoomTypeId = 0.obs;
  var durationType = 'monthly'.obs;

  void increment() => duration++;

  void decrement() {
    if (duration > 1) duration--;
  }

  void setDurationType(String type) {
    durationType.value = type;
    duration.value = 1;
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) selectedDate.value = picked;
  }
}
