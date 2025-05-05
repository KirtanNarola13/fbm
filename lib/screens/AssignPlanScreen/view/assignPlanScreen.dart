import 'package:fbm_admin/modal/investmentPlanModal.dart'; // ✅ Make sure this is correct!
import 'package:flutter/material.dart';

import '../../../helper/ApiHelper.dart';
import '../../../modal/getAllUserModal.dart';

class AssignPlanScreen extends StatefulWidget {
  @override
  _AssignPlanScreenState createState() => _AssignPlanScreenState();
}

class _AssignPlanScreenState extends State<AssignPlanScreen> {
  String? selectedUserId;
  String? selectedUserName;
  String? selectedPlanId;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController returnsController =
      TextEditingController(); // Optional
  final TextEditingController durationController =
      TextEditingController(); // Optional

  List<User> users = [];
  List<InvestmentPlan> plans = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsersAndPlans();
  }

  Future<void> fetchUsersAndPlans() async {
    var fetchedUsers = await ApiHelper.fetchAllUsers();
    var fetchedPlans = await ApiHelper.fetchAllPlans();

    if (fetchedUsers != null && fetchedPlans != null) {
      setState(() {
        users = fetchedUsers;
        plans = fetchedPlans;
      });
    }
  }

  Future<void> assignPlan() async {
    if (selectedUserId == null ||
        selectedUserName == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiHelper.assignPlanToUser(
      userId: selectedUserId!,

      investedAmount: int.parse(amountController.text.trim()),
      returns: double.tryParse(returnsController.text.trim()) ?? 0.0,
      userName: selectedUserName!,
      duration: int.parse(durationController.text.trim()) ?? 0,
    );

    setState(() => isLoading = false);

    if (success) {
      selectedUserId == '';
      selectedPlanId == '';
      amountController.clear();
      returnsController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Plan assigned successfully!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to assign plan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assign Plan to User")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 User Dropdown
            DropdownButtonFormField<String>(
              value: selectedUserId,
              hint: Text("Select User"),
              isExpanded: true,
              items:
                  users.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name), // Show user name in dropdown
                    );
                  }).toList(),
              onChanged:
                  (value) => setState(() {
                    final selectedUser = users.firstWhere(
                      (user) => user.id == value,
                    );
                    selectedUserName = selectedUser.name;
                    selectedUserId = value;
                  }),
            ),

            SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Invested Amount"),
            ),

            TextField(
              controller: returnsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Returns"),
            ),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Duration"),
            ),

            SizedBox(height: 20),

            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: assignPlan,
                  child: Text("Assign Plan"),
                ),
          ],
        ),
      ),
    );
  }
}
