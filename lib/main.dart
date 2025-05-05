import 'package:fbm_admin/screens/AssignPlanScreen/view/assignPlanScreen.dart';
import 'package:fbm_admin/screens/InvestmentRequest/view/investmentRequest.dart';
import 'package:fbm_admin/screens/blog/view/blog.dart';
import 'package:fbm_admin/screens/createInvestmentPlanScreen/view/createInvestmentPlanScreen.dart';
import 'package:fbm_admin/screens/customerSupport/view/customerSupport.dart';
import 'package:fbm_admin/screens/dashboardScreen/view/dashBoardScreen.dart';
import 'package:fbm_admin/screens/pendingReturnScreen/view/pendingReturnScreen.dart';
import 'package:fbm_admin/screens/setting/view/setting.dart';
import 'package:fbm_admin/screens/userCreate/view/userCreate.dart';
import 'package:fbm_admin/screens/viewAllPlanScreen/view/viewAllPlanScreen.dart';
import 'package:fbm_admin/screens/viewAllUser/view/viewAllUserScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FBM Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminPanelScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminPanelScreen extends StatelessWidget {
  // Controller to manage the selected screen
  final selectedIndex = Rx<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FBM Admin Panel')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Dashboard'),
              onTap: () {
                selectedIndex.value = 0;
                Get.back();
              },
            ),
            ListTile(
              title: Text('Create User'),
              onTap: () {
                selectedIndex.value = 1;
                Get.back();
              },
            ),
            ListTile(
              title: Text('View All Users'),
              onTap: () {
                selectedIndex.value = 2;
                Get.back();
              },
            ),

            ListTile(
              title: Text('Assign Plan'),
              onTap: () {
                selectedIndex.value = 5;
                Get.back();
              },
            ),
            ListTile(
              title: Text('Return'),
              onTap: () {
                selectedIndex.value = 6;
                Get.back();
              },
            ),
            ListTile(
              title: Text('Withdrawl Request'),
              onTap: () {
                selectedIndex.value = 7;
                Get.back();
              },
            ),
            ListTile(
              title: Text('Investment Request'),
              onTap: () {
                selectedIndex.value = 8;
                Get.back();
              },
            ),
            ListTile(
              title: Text('Blogs'),
              onTap: () {
                selectedIndex.value = 9;
                Get.back();
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                selectedIndex.value = 10;
                Get.back();
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        switch (selectedIndex.value) {
          case 0:
            return DashboardScreen();
          case 1:
            return CreateUserScreen();
          case 2:
            return ViewUsersScreen();
          case 3:
            return CreateInvestmentPlanScreen();
          case 4:
            return ViewAllPlansScreen();
          case 5:
            return AssignPlanScreen();
          case 6:
            return PendingPayoutsScreen();
          case 7:
            return CustomerSupportScreen();
          case 8:
            return InvestmentRequest();
          case 9:
            return CreateBlogScreen();
          case 10:
            return SettingsScreen();
          default:
            return DashboardScreen();
        }
      }),
    );
  }
}
