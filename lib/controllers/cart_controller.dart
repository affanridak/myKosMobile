import 'package:get/get.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  // Mock Data: Anggap saja pengguna sudah memasukkan 2 kost ini ke keranjang
  var cartItems = <CartItem>[].obs;

  // Getter untuk menghitung total harga dinamis
  int get totalPrice {
    int total = 0;
    for (var item in cartItems) {
      total += item.kost.price * item.duration;
    }
    return total;
  }

  void incrementDuration(int index) {
    cartItems[index].duration++;
    cartItems.refresh(); // Memaksa GetX untuk update UI
  }

  void decrementDuration(int index) {
    if (cartItems[index].duration > 1) {
      cartItems[index].duration--;
      cartItems.refresh();
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }
}
