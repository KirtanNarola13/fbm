class PayoutModel {
  String userId;
  String name;
  String phone;
  String investmentId;
  String plan;
  int investedAmount;
  double payoutAmount;
  String month;
  String status;

  PayoutModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.investmentId,
    required this.plan,
    required this.investedAmount,
    required this.payoutAmount,
    required this.month,
    required this.status,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      plan: json['plan'] ?? '',
      investmentId: json['investmentId'] ?? '',
      investedAmount: json['investedAmount'] ?? 0,
      payoutAmount:
          (json['payoutAmount'] ?? 0).toDouble(), // Ensuring double type
      month: json['month'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class PayoutInvestmentPlan {
  String id;
  String name;
  String description;
  int amount;
  int duration;
  String createdAt;

  PayoutInvestmentPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.duration,
    required this.createdAt,
  });

  factory PayoutInvestmentPlan.fromJson(Map<String, dynamic> json) {
    return PayoutInvestmentPlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] ?? 0,
      duration: json['duration'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
