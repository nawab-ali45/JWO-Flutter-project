class CardModel {
  final String id;
  final String userId;
  final String name;
  final String volunteerId;
  final String fatherName;
  final String bloodGroup;
  final String position;
  final String issueDate;
  final String expiryDate;
  final String? cnic;
  final String? phone;
  final String? profileImageUrl;
  final String? profileImageBase64;
  final String status;
  final DateTime createdAt;

  CardModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.volunteerId,
    required this.fatherName,
    required this.bloodGroup,
    required this.position,
    required this.issueDate,
    required this.expiryDate,
    this.cnic,
    this.phone,
    this.profileImageUrl,
    this.profileImageBase64,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'volunteerId': volunteerId,
      'fatherName': fatherName,
      'bloodGroup': bloodGroup,
      'position': position,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'cnic': cnic,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'profileImageBase64': profileImageBase64,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map, String id) {
    return CardModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      volunteerId: map['volunteerId'] ?? '',
      fatherName: map['fatherName'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      position: map['position'] ?? '',
      issueDate: map['issueDate'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cnic: map['cnic'],
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      profileImageBase64: map['profileImageBase64'],
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}