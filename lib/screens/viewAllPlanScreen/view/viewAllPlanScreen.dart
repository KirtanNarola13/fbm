import 'package:flutter/material.dart';
import '../../../helper/ApiHelper.dart';
import '../../../modal/investmentPlanModal.dart';
import '../../editInvestmentPlanScreen/view/editInvestmentPlanScreen.dart';

class ViewAllPlansScreen extends StatefulWidget {
  @override
  _ViewAllPlansScreenState createState() => _ViewAllPlansScreenState();
}

class _ViewAllPlansScreenState extends State<ViewAllPlansScreen> {
  List<InvestmentPlan> plans = [];
  List<InvestmentPlan> filteredPlans = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    searchController.addListener(_filterPlans);
  }

  _fetchPlans() async {
    List<InvestmentPlan>? fetchedPlans = await ApiHelper.fetchAllPlans();
    if (fetchedPlans != null) {
      setState(() {
        plans = fetchedPlans;
        filteredPlans = fetchedPlans;
      });
    }
  }

  _filterPlans() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPlans =
          plans.where((plan) {
            return plan.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<bool> _showDeleteConfirmationDialog(String planId) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Confirm Delete"),
                content: Text(
                  "Are you sure you want to delete this investment plan?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _deletePlan(String planId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(planId);

    if (confirmDelete) {
      bool result = await ApiHelper.deletePlan(planId);

      if (result) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Plan deleted successfully!")));

        _fetchPlans(); // Refresh the plan list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to delete plan.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Investment Plans')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Plans',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // Plans List
            Expanded(
              child:
                  filteredPlans.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: filteredPlans.length,
                        itemBuilder: (context, index) {
                          InvestmentPlan plan = filteredPlans[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: Icon(
                                Icons.monetization_on,
                                color: Colors.green,
                              ),
                              title: Text(
                                plan.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "💰 ₹${plan.amount} | 📈 ${plan.expectedReturn}% Return",
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow(
                                        "📝 Description",
                                        plan.description,
                                      ),
                                      _buildInfoRow(
                                        "💰 Investment Amount",
                                        "₹${plan.amount}",
                                      ),
                                      _buildInfoRow(
                                        "📈 Expected Return",
                                        "${plan.expectedReturn}%",
                                      ),
                                      _buildInfoRow(
                                        "⏳ Duration",
                                        "${plan.duration} months",
                                      ),
                                      _buildInfoRow(
                                        "📅 Created At",
                                        plan.createdAt,
                                      ),

                                      SizedBox(height: 8),
                                      _buildSectionTitle("Actions"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Edit Plan (if needed)
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () async {
                                              bool?
                                              isUpdated = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          EditInvestmentPlanScreen(
                                                            plan: plan,
                                                          ),
                                                ),
                                              );

                                              if (isUpdated == true) {
                                                _fetchPlans(); // Refresh the plan list if update was successful
                                              }
                                            },
                                          ),

                                          // Delete Plan
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _deletePlan(plan.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // Helper function for information rows
  Widget _buildInfoRow(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
