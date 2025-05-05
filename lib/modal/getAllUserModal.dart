class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String role;
  final double wallet;
  final BankDetails? bankDetails;
  final List<Investment> investments;
  final List<Statement> statements;
  final String decryptedPassword;
  final String profilePic;
  final String? aadharCardFront;
  final String? aadharCardBack;
  final String? panCardFront;
  final String? panCardBack;
  final DateTime? anniversary;
  final DateTime? dob;
  final String? district;
  final String? taluka;
  final String? village;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.role,
    required this.wallet,
    this.bankDetails,
    required this.investments,
    required this.statements,
    required this.decryptedPassword,
    required this.profilePic,
    this.aadharCardFront,
    this.aadharCardBack,
    this.panCardFront,
    this.panCardBack,
    this.anniversary,
    this.dob,
    this.district,
    this.taluka,
    this.village,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
      wallet: (json['wallet'] ?? 0).toDouble(),
      bankDetails:
          (json['bankDetails'] != null &&
                  json['bankDetails'] is Map<String, dynamic>)
              ? BankDetails.fromJson(json['bankDetails'])
              : BankDetails(
                accountHolderName: "NA",
                accountNumber: "NA",
                ifscCode: "NA",
                bankName: "NA",
                branchName: "NA",
              ),
      investments:
          (json['investments'] as List<dynamic>?)
              ?.map((inv) => Investment.fromJson(inv))
              .toList() ??
          [],
      statements:
          (json['statements'] as List<dynamic>?)
              ?.map((stmt) => Statement.fromJson(stmt))
              .toList() ??
          [],
      decryptedPassword: json['decryptedPassword'] ?? "",
      profilePic: json['profilePic'] ?? "",
      // Other fields remain the same...
    );
  }
}

class BankDetails {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;

  BankDetails({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountHolderName: json['accountHolderName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',
      branchName: json['branchName'] ?? '',
    );
  }
}

class Investment {
  final String plan;
  final double investedAmount;
  final double returnPercentage;
  final double returns;
  final String? startDate;
  final String status;
  final List<Payout> payouts;
  final int totalDuration;

  Investment({
    required this.plan,
    required this.investedAmount,
    required this.returnPercentage,
    required this.returns,
    this.startDate,
    required this.status,
    required this.payouts,
    required this.totalDuration,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      plan: json['plan'] ?? "",
      investedAmount: (json['investedAmount'] ?? 0).toDouble(),
      returnPercentage: (json['returnPercentage'] ?? 0).toDouble(),
      returns: (json['returns'] ?? 0).toDouble(),
      startDate: json['startDate'],
      status: json['status'] ?? '',
      payouts:
          (json['payouts'] as List?)
              ?.map((pay) => Payout.fromJson(pay))
              .toList() ??
          [],
      totalDuration:
          int.tryParse(json['totalDuration']?.toString() ?? '0') ?? 0,
    );
  }
}

class Payout {
  final String month;
  final double amount;
  final String status;
  final String? paidDate;
  final String id;

  Payout({
    required this.month,
    required this.amount,
    required this.status,
    this.paidDate,
    required this.id,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      month: json['month'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paidDate: json['paidDate'],
      id: json['_id'] ?? '',
    );
  }
}

class Statement {
  final String type;
  final double amount;
  final String description;
  final String id;
  final String? date;

  Statement({
    required this.type,
    required this.amount,
    required this.description,
    required this.id,
    this.date,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      id: json['_id'] ?? '',
      date: json['date'],
    );
  }
}
