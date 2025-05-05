class InvestmentPlan {
  String id;
  String name;
  String description;
  int amount;
  int expectedReturn;
  int duration;
  String createdAt;

  InvestmentPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.expectedReturn,
    required this.duration,
    required this.createdAt,
  });

  factory InvestmentPlan.fromJson(Map<String, dynamic> json) {
    return InvestmentPlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] ?? 0,
      expectedReturn: json['expectedReturn'] ?? 0,
      duration: json['duration'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
