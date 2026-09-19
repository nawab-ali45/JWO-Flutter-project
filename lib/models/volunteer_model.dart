class VolunteerModel {
  final String id;
  final String name;
  final String fatherName;
  final String phone;
  final String? bloodGroup;
  final String? address;
  final String? cnic;
  final String? skills;
  final String? experience;
  final String? availability;
  final String userId;
  final String status;
  final String? cvPath;
  final String? identityPath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VolunteerModel({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.phone,
    this.bloodGroup,
    this.address,
    this.cnic,
    this.skills,
    this.experience,
    this.availability,
    required this.userId,
    this.status = 'pending',
    this.cvPath,
    this.identityPath,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fatherName': fatherName,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'address': address,
      'cnic': cnic,
      'skills': skills,
      'experience': experience,
      'availability': availability,
      'userId': userId,
      'status': status,
      'cvPath': cvPath,
      'identityPath': identityPath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory VolunteerModel.fromMap(Map<String, dynamic> map, String id) {
    return VolunteerModel(
      id: id,
      name: map['name'] ?? '',
      fatherName: map['fatherName'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'],
      address: map['address'],
      cnic: map['cnic'],
      skills: map['skills'],
      experience: map['experience'],
      availability: map['availability'],
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'pending',
      cvPath: map['cvPath'],
      identityPath: map['identityPath'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as dynamic).toDate() : null,
    );
  }
}