class Kost {
  final int id;
  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final int price;
  final String type;
  final double rating;
  final String? description;
  final double latitude;
  final double longitude;
  final String rentalType;
  double distance;

  Kost({
    required this.id,
    required this.name,

    required this.address,
    required this.city,
    required this.imageUrl,
    required this.price,
    required this.type,
    required this.rating,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.rentalType,
    this.distance = 0,
  });

  String get location => '$address, $city';

  factory Kost.fromJson(Map<String, dynamic> json) {
    return Kost(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: json['price'] ?? 0,
      type: json['type'] ?? '-',
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      rentalType: json['rental_type'] ?? 'monthly',
    );
  }
}
