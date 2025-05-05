class DashboardData {
  final bool success;
  final DashboardCounts data;

  DashboardData({required this.success, required this.data});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      success: json["success"],
      data: DashboardCounts.fromJson(json["data"]),
    );
  }
}

class DashboardCounts {
  final int totalUsers;
  final int totalInvestors;
  final int totalPlans;
  final int totalFunds;

  DashboardCounts({
    required this.totalUsers,
    required this.totalInvestors,
    required this.totalPlans,
    required this.totalFunds,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      totalUsers: json["totalUsers"],
      totalInvestors: json["totalInvestors"],
      totalPlans: json["totalPlans"],
      totalFunds: json["totalFunds"],
    );
  }
}
