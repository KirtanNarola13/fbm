import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helper/ApiHelper.dart';
import '../../../modal/pendingReturnModal.dart';
import '../components/paymentHistory.dart';

class PendingPayoutsScreen extends StatefulWidget {
  @override
  _PendingPayoutsScreenState createState() => _PendingPayoutsScreenState();
}

class _PendingPayoutsScreenState extends State<PendingPayoutsScreen> {
  List<PayoutModel> payouts = [];
  List<PayoutModel> filteredPayouts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPayouts();
    searchController.addListener(_filterPayouts);
  }

  Future<void> fetchPayouts() async {
    List<PayoutModel> data = await ApiHelper.fetchPendingPayouts();
    setState(() {
      payouts = data;
      filteredPayouts = data;
    });
  }

  void _filterPayouts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPayouts =
          payouts
              .where(
                (payout) =>
                    payout.name.toLowerCase().contains(query) ||
                    payout.phone.contains(query),
              )
              .toList();
    });
  }

  Future<void> _markAsPaid(String userId, String investmentId) async {
    bool success = await ApiHelper.markPayoutAsPaid(userId, investmentId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Payout marked as paid!")));
      fetchPayouts(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to mark payout as paid.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Payouts"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
            ), // 🔥 View History Icon
            onPressed: () {
              Get.to(() => PayoutHistoryScreen()); // Navigate to history screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Users",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Phone")),
                    DataColumn(label: Text("Plan")),
                    DataColumn(label: Text("Amount")),
                    DataColumn(label: Text("Month")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Action")),
                  ],
                  rows:
                      filteredPayouts.map((payout) {
                        return DataRow(
                          cells: [
                            DataCell(Text(payout.name)),
                            DataCell(Text(payout.phone)),
                            DataCell(Text(payout.plan)),
                            DataCell(
                              Text(
                                "₹${payout.payoutAmount.toStringAsFixed(2)}",
                              ),
                            ),
                            DataCell(Text(payout.month)),
                            DataCell(
                              Text(
                                payout.status.toUpperCase(),
                                style: TextStyle(
                                  color:
                                      payout.status == "pending"
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              ),
                            ),
                            DataCell(
                              payout.status == "pending"
                                  ? ElevatedButton(
                                    onPressed:
                                        () => _markAsPaid(
                                          payout.userId,
                                          payout.investmentId,
                                          // payout.plan.id,
                                        ),
                                    child: Text("Mark as Paid"),
                                  )
                                  : Text("Paid"),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
