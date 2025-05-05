import 'package:fbm_admin/helper/ApiHelper.dart';
import 'package:flutter/material.dart';

import '../../../modal/dashBoardData.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardCounts? counts;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  void fetchCounts() async {
    final data = await ApiHelper.fetchDashboardCounts();
    if (data != null) {
      setState(() {
        counts = data.data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.white,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : counts == null
              ? Center(child: Text("Failed to load data"))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  children: [
                    buildDashboardCard(
                      "Total Users",
                      counts!.totalUsers,
                      Icons.people,
                    ),
                    buildDashboardCard(
                      "Total Investors",
                      counts!.totalInvestors,
                      Icons.monetization_on,
                    ),
                    buildDashboardCard(
                      "Total Plans",
                      counts!.totalPlans,
                      Icons.business,
                    ),
                    buildDashboardCard(
                      "Total Funds",
                      counts!.totalFunds,
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget buildDashboardCard(String title, int count, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
