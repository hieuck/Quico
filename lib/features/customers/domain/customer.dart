class Customer {
  final String id;
  final String storeId;
  final String name;
  final String? phone;
  final String? note;
  final int totalSpent;
  final int totalOrders;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const Customer({
    required this.id,
    required this.storeId,
    required this.name,
    required this.totalSpent,
    required this.totalOrders,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.note,
    this.deletedAt,
  });
}

class CreateCustomerInput {
  final String storeId;
  final String name;
  final String? phone;
  final String? note;

  const CreateCustomerInput({
    required this.storeId,
    required this.name,
    this.phone,
    this.note,
  });
}
