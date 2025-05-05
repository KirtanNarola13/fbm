import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../Api/api.dart';
import '../modal/allHistoryModal.dart';
import '../modal/dashBoardData.dart';
import '../modal/getAllUserModal.dart';
import '../modal/investmentPlanModal.dart';
import '../modal/pendingReturnModal.dart'; // Import the Logger package

final logger = Logger();

class ApiHelper {
  Future<bool> createUser(
    Map<String, dynamic> userData,

    File? profilePhoto,
  ) async {
    logger.d("🔧 Creating user with data: $userData");

    final String apiUrl = Api.createUser;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add user data as fields

      // Assign values properly
      userData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add profile photo if available
      if (profilePhoto != null) {
        logger.d("📸 Uploading profile photo: ${profilePhoto.path}");
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePic',
            profilePhoto.path,
            // contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      request.headers['Content-Type'] = 'multipart/form-data';

      logger.d("📡 Sending API request to: $apiUrl");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      logger.d("💬 API Response: ${response.statusCode} - ${response.body}");

      switch (response.statusCode) {
        case 201:
          logger.i("✅ User created successfully!");
          return true;
        case 400:
          logger.w("⚠️ Bad Request (400). Check the user data.");
          return false;
        case 401:
          logger.w("⚠️ Unauthorized (401). Authentication failed.");
          return false;
        case 404:
          logger.w("⚠️ Not Found (404). API endpoint not found.");
          return false;
        case 500:
          logger.e("❌ Internal Server Error (500). Please try again later.");
          return false;
        case 502:
          logger.e("❌ Bad Gateway (502). Server is down.");
          return false;
        default:
          logger.w("⚠️ Unexpected status code: ${response.statusCode}");
          return false;
      }
    } catch (e) {
      logger.e("❌ Error occurred while creating user: $e");
      return false;
    }
  }

  static Future<List<User>?> fetchAllUsers() async {
    logger.i("🔵 Fetching all users from: ${Api.getAllUser}");

    try {
      final response = await http.get(Uri.parse(Api.getAllUser));

      logger.i("📡 Response Status Code: ${response.statusCode}");
      logger.d("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] ?? false) {
          List<User> users =
              (data['users'] as List)
                  .map((userJson) => User.fromJson(userJson))
                  .toList();
          logger.d(users.toString());
          return users;
        } else {
          logger.w("⚠️ Failed to fetch users: ${data['message']}");
          return null;
        }
      } else {
        logger.e("❌ Server Error: Status Code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      logger.e("🚨 Error occurred while fetching users: $e");
      return null;
    }
  }

  static Future<bool?> createInvestmentPlan(
    Map<String, dynamic> planData,
  ) async {
    final url = Uri.parse(Api.createPlan);

    logger.i("📡 Sending API request to: $url");
    logger.d("📩 Request Body: ${jsonEncode(planData)}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(planData),
      );

      logger.i("📡 Response Status Code: ${response.statusCode}");
      logger.d("📩 Raw Response Body: ${response.body}");

      // Handle invalid JSON response
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        logger.e("❌ Failed to parse JSON response: $e");
        return null;
      }

      if (response.statusCode == 201) {
        if (data?['success'] == true) {
          logger.i("✅ Investment plan created successfully!");
          return true;
        } else {
          logger.w("⚠️ API responded with failure: ${data?['message']}");
          return false;
        }
      } else if (response.statusCode == 400) {
        logger.e("❌ Bad Request: ${data?['message'] ?? 'Invalid input'}");
      } else if (response.statusCode == 500) {
        logger.e(
          "🔥 Server Error: ${data?['message'] ?? 'Something went wrong'}",
        );
      } else {
        logger.w(
          "⚠️ Unexpected Status Code: ${response.statusCode}, Message: ${data?['message']}",
        );
      }

      return false;
    } catch (e) {
      logger.e("🔥 Exception occurred during API call: $e");
      return null;
    }
  }

  static Future<List<InvestmentPlan>?> fetchAllPlans() async {
    final url = Uri.parse(Api.getAllPlan);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<InvestmentPlan> plans =
              (data['plans'] as List)
                  .map((plan) => InvestmentPlan.fromJson(plan))
                  .toList();
          return plans;
        } else {
          print("❌ Failed to fetch plans: ${data['message']}");
          return null;
        }
      } else {
        print("❌ Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔥 Error fetching plans: $e");
      return null;
    }
  }

  static Future<bool> deleteUser(String userId) async {
    final url = Uri.parse(Api.deleteUser);

    logger.i("📡 Sending DELETE request to: $url");
    logger.d("📩 Request Body: {\"userId\": \"$userId\"}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": userId}),
      );

      logger.i("📡 Response Status Code: ${response.statusCode}");
      logger.d("📩 Raw Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        logger.i("✅ User deleted successfully: $userId");
        return true;
      } else {
        logger.e("❌ Failed to delete user: ${data['message']}");
        return false;
      }
    } catch (e) {
      logger.e("🔥 Error deleting user: $e");
      return false;
    }
  }

  static Future<bool> deletePlan(String planId) async {
    final url = Uri.parse(Api.deletePlan);

    logger.i("📡 Sending DELETE request to: $url");
    logger.d("📩 Request Body: {\"planId\": \"$planId\"}");

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"planId": planId}),
      );

      logger.i("📡 Response Status Code: ${response.statusCode}");
      logger.d("📩 Raw Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        logger.i("✅ Investment plan deleted successfully: $planId");
        return true;
      } else {
        logger.e("❌ Failed to delete plan: ${data['message']}");
        return false;
      }
    } catch (e) {
      logger.e("🔥 Error deleting plan: $e");
      return false;
    }
  }

  static Future<bool> updatePlan(
    String planId,
    Map<String, dynamic> planData,
  ) async {
    final url = Uri.parse(Api.updatePlan);

    logger.i("📡 Sending UPDATE request to: $url");
    logger.d("📩 Request Body: ${jsonEncode({...planData, "planId": planId})}");

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({...planData, "planId": planId}),
      );

      logger.i("📡 Response Status Code: ${response.statusCode}");
      logger.d("📩 Raw Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        logger.i("✅ Investment plan updated successfully: $planId");
        return true;
      } else {
        logger.e("❌ Failed to update plan: ${data['message']}");
        return false;
      }
    } catch (e) {
      logger.e("🔥 Error updating plan: $e");
      return false;
    }
  }

  static Future<bool> assignPlanToUser({
    required String userId,
    required String userName,
    required int duration,
    required int investedAmount,
    required double returns, // Remove this if you don't need returns
  }) async {
    final url = Uri.parse(Api.assignPlan);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "plan": userName + "_" + investedAmount.toString(),
          "investedAmount": investedAmount,
          "returnPercentage": returns, // Optional field (remove if unnecessary)
          "duration": duration, // Optional field (remove if unnecessary)
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Plan assigned successfully!");
        return true;
      } else {
        print("❌ Failed to assign plan: ${response.body}");
        return false;
      }
    } catch (e) {
      print("🔥 Error assigning plan: $e");
      return false;
    }
  }

  /// ✅ Fetch Pending Payouts
  static Future<List<PayoutModel>> fetchPendingPayouts() async {
    final response = await http.get(
      Uri.parse(Api.getPendingReturnUser),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['payouts'] as List)
            .map((payout) => PayoutModel.fromJson(payout))
            .toList();
      }
    }
    return [];
  }

  /// ✅ Mark Payout as Paid with Full Debug Logs
  static Future<bool> markPayoutAsPaid(
    String userId,
    String investmentId,
  ) async {
    final url = Uri.parse(Api.markAsPaid);
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> body = {
      "userId": userId,
      "investmentId": investmentId,
    };

    log("📡 [API CALL] Sending request to: $url");
    log("📤 [REQUEST] Headers: $headers");
    log("📨 [REQUEST] Body: ${json.encode(body)}");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      log("📡 [RESPONSE] Status Code: ${response.statusCode}");
      log("📄 [RESPONSE] Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log("✅ [SUCCESS] Response JSON: $data");

        if (data['success'] == true) {
          log("💰 [PAYOUT] Successfully marked as PAID for user: $userId, ");
          return true;
        } else {
          log("⚠️ [WARNING] API Response did not confirm success.");
        }
      } else if (response.statusCode == 400) {
        log("🚫 [ERROR 400] Bad Request - Check the request payload.");
      } else if (response.statusCode == 401) {
        log("🔒 [ERROR 401] Unauthorized - Check authentication.");
      } else if (response.statusCode == 403) {
        log("⛔ [ERROR 403] Forbidden - You don't have permission.");
      } else if (response.statusCode == 404) {
        log("🔍 [ERROR 404] API Endpoint Not Found.");
      } else if (response.statusCode == 500) {
        log("🔥 [ERROR 500] Internal Server Error - Issue with the server.");
      } else {
        log("❌ [ERROR] Unexpected Status Code: ${response.statusCode}");
      }
    } catch (e) {
      log("🔥 [EXCEPTION] Error Occurred: $e");
    }

    log("❌ [PAYOUT] Failed to mark as PAID for user: $userId,");
    return false;
  }

  static Future<List<AllHistoryModel>> fetchAllPaymentHistory() async {
    final url = Uri.parse(Api.allPaymentHistory);
    final headers = {"Content-Type": "application/json"};

    try {
      print("📡 [API CALL] Fetching all users' payment history...");

      final response = await http.get(url, headers: headers);

      print("📄 [RESPONSE] Status Code: ${response.statusCode}");
      print("📨 [RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['paymentHistory'] != null) {
          List<AllHistoryModel> historyList =
              (data['paymentHistory'] as List)
                  .map((history) => AllHistoryModel.fromJson(history))
                  .toList();
          print("✅ [SUCCESS] Total history records: ${historyList.length}");
          return historyList;
        } else {
          print("⚠️ [WARNING] No payment history found.");
        }
      } else {
        print("❌ [ERROR] API returned status code: ${response.statusCode}");
      }
    } catch (e) {
      print("🔥 [EXCEPTION] Error fetching payment history: $e");
    }

    return [];
  }

  static Future<DashboardData?> fetchDashboardCounts() async {
    final url = Uri.parse(Api.count);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return DashboardData.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching dashboard counts: $e");
      return null;
    }
  }
}
