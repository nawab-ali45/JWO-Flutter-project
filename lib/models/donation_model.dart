class DonationModel {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String status;
  final String? accountNumber;
  final String? cardNumber;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.status = 'pending',
    this.accountNumber,
    this.cardNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'accountNumber': accountNumber,
      'cardNumber': cardNumber,
      'createdAt': createdAt,
    };
  }

  factory DonationModel.fromMap(Map<String, dynamic> map, String id) {
    return DonationModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? '',
      transactionId: map['transactionId'],
      status: map['status'] ?? 'pending',
      accountNumber: map['accountNumber'],
      cardNumber: map['cardNumber'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}