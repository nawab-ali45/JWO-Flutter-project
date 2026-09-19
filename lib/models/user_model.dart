class UserModel {
  final String uid;
  final String name;
  final String fatherName;
  final String email;
  final String? phone;
  final String? bloodGroup;
  final String? address;
  final String? profileImage;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.fatherName,
    required this.email,
    this.phone,
    this.bloodGroup,
    this.address,
    this.profileImage,
    this.role = 'user',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'fatherName': fatherName,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'address': address,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      fatherName: map['fatherName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      bloodGroup: map['bloodGroup'],
      address: map['address'],
      profileImage: map['profileImage'],
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}