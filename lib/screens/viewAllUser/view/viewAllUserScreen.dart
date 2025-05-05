import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/ApiHelper.dart';
import '../../../modal/getAllUserModal.dart';
import '../../AllPayoutsOfUserScreen/view/allPayoutsOfUserScreen.dart';
import '../../allStatementScreen/view/allStatementScreen.dart';

class ViewUsersScreen extends StatefulWidget {
  @override
  _ViewUsersScreenState createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  Map<String, bool> passwordVisibility = {};
  ApiHelper _apiHelper = ApiHelper();
  bool _isCsvUploading = false;

  Future<void> _uploadCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ No CSV file selected.')));
      return;
    }

    File file = File(result.files.single.path!);

    setState(() {
      _isCsvUploading = true;
    });

    try {
      // Read CSV File
      final input = await file.readAsString();
      List<List<dynamic>> csvData = const CsvToListConverter().convert(input);

      if (csvData.isEmpty || csvData.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Invalid or empty CSV data.')),
        );
        setState(() => _isCsvUploading = false);
        return;
      }

      // Extract Headers and Data
      List<String> headers = csvData[0].map((e) => e.toString()).toList();
      List<Map<String, dynamic>> usersData = [];

      for (int i = 1; i < csvData.length; i++) {
        Map<String, dynamic> userMap = {
          'profilePic':
              "https://cdn.vectorstock.com/i/500p/17/61/male-avatar-profile-picture-vector-10211761.jpg",
        };
        for (int j = 0; j < headers.length; j++) {
          userMap[headers[j]] = csvData[i][j];
        }
        usersData.add(userMap);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📊 Total Users to Process: ${usersData.length}'),
        ),
      );

      // Call API for Each User
      for (var userData in usersData) {
        bool isSuccess = await _apiHelper.createUser(userData, null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSuccess
                  ? '✅ Success: ${userData['email']}'
                  : '❌ Failed: ${userData['email']}',
            ),
          ),
        );
      }
      setState(() {
        _fetchUsers();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ CSV Processing Completed.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error processing CSV: $e')));
    } finally {
      setState(() {
        _isCsvUploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    searchController.addListener(_filterUsers);
  }

  _fetchUsers() async {
    List<User>? fetchedUsers = await ApiHelper.fetchAllUsers();
    if (fetchedUsers != null) {
      setState(() {
        users = fetchedUsers;
        filteredUsers = fetchedUsers;
      });
    }
  }

  _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers =
          users.where((user) {
            return user.name.toLowerCase().contains(query) ||
                user.phone.contains(query) ||
                user.email.toLowerCase().contains(query);
          }).toList();
    });
  }

  _togglePasswordVisibility(String userId) {
    setState(() {
      passwordVisibility[userId] = !(passwordVisibility[userId] ?? false);
    });
  }

  void _showDocumentDialog(
    BuildContext context,
    String title,
    String? frontUrl,
    String? backUrl,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  frontUrl != null
                      ? SizedBox(
                        width: 200, // Adjust width as needed
                        height: 200, // Adjust height as needed
                        child: Image.network(frontUrl, fit: BoxFit.cover),
                      )
                      : const Text('No Front Image'),
                  const SizedBox(width: 10),
                  backUrl != null
                      ? SizedBox(
                        width: 200, // Adjust width as needed
                        height: 200, // Adjust height as needed
                        child: Image.network(backUrl, fit: BoxFit.cover),
                      )
                      : const Text('No Back Image'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(String userId) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Confirm Delete"),
                content: Text("Are you sure you want to delete this user?"),
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

  void _deleteUser(String userId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(userId);

    if (confirmDelete) {
      bool result = await ApiHelper.deleteUser(userId);

      if (result) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ User deleted successfully!")));

        _fetchUsers(); // Refresh the user list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to delete user.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
        actions: [
          GestureDetector(
            onTap: _uploadCsv,
            child: Row(
              children: [
                Container(
                  height: Get.height * 0.04,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(minHeight: 40, minWidth: 120),
                  child: Center(
                    child: Text(
                      "Upload CSV",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Get.height * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Get.width * 0.01),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Users',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                // Users List
                Expanded(
                  child:
                      filteredUsers.isEmpty
                          ? Center(child: Text("User List Empty"))
                          : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              User user = filteredUsers[index];

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    foregroundImage: NetworkImage(
                                      user.profilePic,
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  title: Text(
                                    user.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text("📞 ${user.phone}"),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow("✉️ Email", user.email),
                                          _buildInfoRow(
                                            "🏠 Address",
                                            user.address,
                                          ),

                                          _buildInfoRow(
                                            "👥 Role",
                                            user.role.toUpperCase(),
                                          ),
                                          if (user.dob != null)
                                            _buildInfoRow(
                                              "📅 DOB",
                                              "${user.dob!.day}/${user.dob!.month}/${user.dob!.year}",
                                            ),
                                          if (user.anniversary != null)
                                            _buildInfoRow(
                                              "💍 Anniversary",
                                              "${user.anniversary!.day}/${user.anniversary!.month}/${user.anniversary!.year}",
                                            ),
                                          if (user.village?.isNotEmpty ?? false)
                                            _buildInfoRow(
                                              "🏡 Village",
                                              user.village!.toUpperCase(),
                                            ),
                                          if (user.taluka?.isNotEmpty ?? false)
                                            _buildInfoRow(
                                              "📍 Taluka",
                                              user.taluka!.toUpperCase(),
                                            ),
                                          if (user.district?.isNotEmpty ??
                                              false)
                                            _buildInfoRow(
                                              "🌍 District",
                                              user.district!.toUpperCase(),
                                            ),

                                          if (user.panCardBack?.isNotEmpty ??
                                              false)
                                            ElevatedButton(
                                              onPressed:
                                                  () => _showDocumentDialog(
                                                    context,
                                                    'PAN Card',
                                                    user.panCardFront,
                                                    user.panCardBack,
                                                  ),
                                              child: const Text(
                                                'Show PAN Card',
                                              ),
                                            ),
                                          const SizedBox(height: 10),
                                          if (user.aadharCardBack?.isNotEmpty ??
                                              false)
                                            ElevatedButton(
                                              onPressed:
                                                  () => _showDocumentDialog(
                                                    context,
                                                    'Aadhaar Card',
                                                    user.aadharCardFront,
                                                    user.aadharCardBack,
                                                  ),
                                              child: const Text(
                                                'Show Aadhaar Card',
                                              ),
                                            ),

                                          SizedBox(height: 8),
                                          _buildSectionTitle("🏦 Bank Details"),
                                          _buildInfoRow(
                                            "Account Holder",
                                            user
                                                    .bankDetails
                                                    ?.accountHolderName ??
                                                "N/A",
                                          ),
                                          _buildInfoRow(
                                            "Bank Name",
                                            user.bankDetails?.bankName ?? "N/A",
                                          ),
                                          _buildInfoRow(
                                            "Branch",
                                            user.bankDetails?.branchName ??
                                                "N/A",
                                          ),
                                          _buildInfoRow(
                                            "Account No.",
                                            user.bankDetails?.accountNumber ??
                                                "N/A",
                                          ),
                                          _buildInfoRow(
                                            "IFSC Code",
                                            user.bankDetails?.ifscCode ?? "N/A",
                                          ),

                                          SizedBox(height: 8),
                                          _buildSectionTitle(
                                            "📌 Investment Plans",
                                          ),
                                          _buildInvestmentSection(
                                            user.investments,
                                          ),

                                          SizedBox(height: 8),
                                          _buildSectionTitle("Actions"),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Toggle Password Visibility
                                              IconButton(
                                                icon: Icon(Icons.visibility),
                                                onPressed:
                                                    () =>
                                                        _togglePasswordVisibility(
                                                          user.id,
                                                        ),
                                              ),
                                              passwordVisibility[user.id] ==
                                                      true
                                                  ? Text(
                                                    user.decryptedPassword,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text('*****'),

                                              // Delete User
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    () => _deleteUser(user.id),
                                              ),

                                              // All Statements Button
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Navigate to All Statements Screen
                                                  Get.to(
                                                    () =>
                                                        AllStatementsOfUserScreen(
                                                          user: user,
                                                        ),
                                                  );
                                                },
                                                child: Text("All Statements"),
                                              ),

                                              // All Payouts Button
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Navigate to All Payouts Screen
                                                  Get.to(
                                                    () =>
                                                        AllPayoutsOfUserScreen(
                                                          user: user,
                                                        ),
                                                  );
                                                },
                                                child: Text("Payouts Details"),
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
            if (_isCsvUploading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Uploading CSV... Please do not close the window.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Investment Section with Styled Cards
  Widget _buildInvestmentSection(List<Investment> investments) {
    if (investments.isEmpty) {
      return Text("No investments found", style: TextStyle(color: Colors.grey));
    }

    return Column(
      children:
          investments.map((investment) {
            return Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.monetization_on, color: Colors.green),
                title: Text(
                  "Plan: ${investment.plan}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invested: ₹${investment.investedAmount.toStringAsFixed(2)}",
                    ),
                    Text("Returns: ${investment.returns.toStringAsFixed(2)}%"),
                    Text(
                      "Status: ${investment.status}",
                      style: TextStyle(
                        color:
                            investment.status == "active"
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      investment.startDate != null
                          ? "Start Date: ${investment.startDate.toString().split(' ')[0]}"
                          : "Start Date: N/A",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

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
