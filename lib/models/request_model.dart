class RequestModel {
  final String id;
  final String name;
  final String fatherName;
  final String phone;
  final String? cnic;
  final String? address;
  final String need;
  final String? urgency;
  final String request;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RequestModel({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.phone,
    this.cnic,
    this.address,
    required this.need,
    this.urgency,
    required this.request,
    required this.userId,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fatherName': fatherName,
      'phone': phone,
      'cnic': cnic,
      'address': address,
      'need': need,
      'urgency': urgency,
      'request': request,
      'userId': userId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      name: map['name'] ?? '',
      fatherName: map['fatherName'] ?? '',
      phone: map['phone'] ?? '',
      cnic: map['cnic'],
      address: map['address'],
      need: map['need'] ?? 'General',
      urgency: map['urgency'],
      request: map['request'] ?? '',
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as dynamic).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as dynamic).toDate() : null,
    );
  }
}