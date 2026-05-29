class Complaint {
  final int id;
  final int tenantId;
  final int propertyId;
  final int? contractId;
  final String title;
  final String description;
  final String? image;
  final String status;
  final String? createdAt;

  Complaint({
    required this.id,
    required this.tenantId,
    required this.propertyId,
    this.contractId,
    required this.title,
    required this.description,
    this.image,
    required this.status,
    this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      contractId: json['contract_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      status: json['status'] ?? 'new',
      createdAt: json['created_at'],
    );
  }
}