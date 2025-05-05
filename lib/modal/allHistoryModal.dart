class AllHistoryModel {
  String userId;
  String userName;
  String phone;
  String investmentId;
  String planName;
  int investedAmount;
  String month;
  double amount;
  String status;
  String? paidDate;

  AllHistoryModel({
    required this.userId,
    required this.userName,
    required this.phone,
    required this.investmentId,
    required this.planName,
    required this.investedAmount,
    required this.month,
    required this.amount,
    required this.status,
    this.paidDate,
  });

  factory AllHistoryModel.fromJson(Map<String, dynamic> json) {
    return AllHistoryModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      phone: json['phone'] ?? '',
      investmentId: json['investmentId'] ?? '',
      planName: json['planName'] ?? '',
      investedAmount: json['investedAmount'] ?? 0,
      month: json['month'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paidDate: json['paidDate'], // Nullable field
    );
  }
}
