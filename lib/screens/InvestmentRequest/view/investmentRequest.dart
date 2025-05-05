import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Api/api.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class InvestmentRequest extends StatefulWidget {
  @override
  State<InvestmentRequest> createState() => _InvestmentRequestState();
}

class _InvestmentRequestState extends State<InvestmentRequest> {
  InvestmentSupportController controller = Get.put(
    InvestmentSupportController(),
  );

  @override
  void initState() {
    // TODO: implement initState
    controller.fetchMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Investment Requests"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.messages.isEmpty) {
          return Center(
            child: Text("No messages found", style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            InvestmentMessage message = controller.messages[index];

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),

                title: Text(
                  message.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Message: ${message.message}",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Phone: ${message.phone}",
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Email: ${message.userEmail}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _replyToMessage(BuildContext context, String userId) {
    // Implement reply functionality
  }
}

class InvestmentSupportController extends GetxController {
  var messages = <InvestmentMessage>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchMessages();
    super.onInit();
  }

  //   Future<void> fetchMessages() async {
  //     try {
  //       isLoading(true);
  //       final response = await http.post(
  //         Uri.parse(Api.getAllMessages),
  //         body: {'adminId': '67af49eb761939db1f1ce853'},
  //       );
  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         if (data['success']) {
  //           messages.value =
  //               (data['data'] as List)
  //                   .map((msg) => Message.fromJson(msg))
  //                   .toList();
  //         }
  //       }
  //     } catch (e) {
  //       log("Error fetching messages: $e");
  //     } finally {
  //       isLoading(false);
  //     }
  //   }
  // }
  Future<void> fetchMessages() async {
    try {
      log("🚀 Fetching messages...");

      isLoading(true);
      log("⏳ Loading state set to true.");

      var uri = Uri.parse(Api.getAllRequest);
      var body = {'adminId': '67af49eb761939db1f1ce853'};

      log("📡 Sending POST request to: $uri");
      log("📤 Request Body: $body");

      final response = await http.post(uri, body: body);

      log("📩 Response received. Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("✅ Response JSON decoded successfully.");

        if (data['success'] == true) {
          log("📊 Messages data found. Parsing messages...");

          messages.value =
              (data['data'] as List)
                  .map((msg) => InvestmentMessage.fromJson(msg))
                  .toList();

          log("📥 ${messages.length} messages loaded successfully.");
        } else {
          log(
            "⚠️ API response indicates failure: ${data['message'] ?? 'Unknown error'}",
          );
        }
      } else {
        log("❌ Server returned non-200 status code: ${response.statusCode}");
        log("🛑 Response Body: ${response.body}");
      }
    } catch (e) {
      log("🚨 Error fetching messages: $e");
    } finally {
      isLoading(false);
      log("🔄 Loading state set to false.");
    }
  }
}

class InvestmentMessage {
  final String userId, userName, userEmail, phone, message, adminId;

  InvestmentMessage({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.phone,
    required this.message,
    required this.adminId,
  });

  factory InvestmentMessage.fromJson(Map<String, dynamic> json) {
    return InvestmentMessage(
      userId: json['userId'] ?? "",
      userName: json['userName'] ?? "",
      userEmail: json['userEmail'] ?? "",
      phone: json['phone'] ?? "",
      message: json['message'] ?? "",
      adminId: json['adminId'] ?? "",
    );
  }
}
