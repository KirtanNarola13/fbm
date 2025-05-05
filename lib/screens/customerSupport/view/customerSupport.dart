import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Api/api.dart';

class CustomerSupportScreen extends StatelessWidget {
  final CustomerSupportController controller = Get.put(
    CustomerSupportController(),
  );

  void _replyToMessage(BuildContext context, String messageId) {
    TextEditingController replyController = TextEditingController();
    String? filePath;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Reply to Message"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: replyController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allows unlimited lines
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "Enter your reply",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ), // Adjust padding for better UX
                  ),
                ),

                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                    if (result != null) {
                      filePath = result.files.single.path;
                      if (filePath != null) {
                        print("Selected File Path: $filePath");
                        setState(() {}); // Update UI after selecting file
                      }
                    } else {
                      print("No file selected");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          filePath != null ? "File Selected" : "Attach PDF",
                          style: TextStyle(
                            color:
                                filePath != null
                                    ? Colors.green
                                    : Colors.blueGrey,
                            fontWeight:
                                filePath != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filePath != null) ...[
                  SizedBox(height: 10),
                  Text(
                    "Selected: ${filePath!.split('/').last}",
                    style: TextStyle(color: Colors.green, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 15),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
              TextButton(
                onPressed: () {
                  controller.replyToMessage(
                    messageId,
                    replyController.text,
                    filePath,
                  );
                },
                child: Text("Send"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Withdrawl Request"), centerTitle: true),
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
            Message message = controller.messages[index];
            bool isPending = message.status == "pending";

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isPending ? Colors.red[50] : Colors.green[50],
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                leading: Icon(
                  isPending ? Icons.pending : Icons.check_circle,
                  color: isPending ? Colors.red : Colors.green,
                ),
                title: Text(
                  message.message,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    message.reply != null
                        ? Text(
                          "Reply: ${message.reply}",
                          style: TextStyle(color: Colors.grey[700]),
                        )
                        : Text(
                          "No reply yet",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.replyFilePath != null)
                      GestureDetector(
                        onTap:
                            () => controller.openFile(message.replyFilePath!),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.attach_file,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),

                    if (isPending)
                      ElevatedButton(
                        onPressed: () => _replyToMessage(context, message.id),
                        child: Text("Reply"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
}

class CustomerSupportController extends GetxController {
  var messages = <Message>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchMessages();
    super.onInit();
  }

  Future<void> fetchMessages() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse(Api.getAllMessages));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          messages.value =
              (data['messages'] as List)
                  .map((msg) => Message.fromJson(msg))
                  .toList();
        }
      }
    } catch (e) {
      log("Error fetching messages: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> replyToMessage(
    String messageId,
    String reply,
    String? filePath,
  ) async {
    try {
      log("📤 Sending reply to message ID: $messageId");
      log("📝 Reply content: $reply");

      var uri = Uri.parse(Api.reply);
      var request = http.MultipartRequest("POST", uri);

      request.fields['messageId'] = messageId;
      request.fields['replyMessage'] = reply;

      if (filePath != null) {
        log("📎 Attaching file: $filePath");
        var file = await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType(
            'application',
            'pdf',
          ), // Set MIME type explicitly
        );
        request.files.add(file);
      } else {
        log("⚠️ No file attached");
      }

      log("🚀 Sending request to: ${uri.toString()}");
      var response = await request.send();

      log("📩 Response received. Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("✅ Reply sent successfully!");
        fetchMessages();
        Get.back();
        Get.snackbar(
          "✅ Success",
          "Reply sent successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        log("❌ Failed to send reply. Status Code: ${response.statusCode}");
        Get.snackbar(
          "❌ Error",
          "Failed to send reply",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log("🚨 Error while sending reply: $e");
    }
  }

  Future<void> openFile(String url) async {
    try {
      Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null)
        throw Exception("Downloads directory not found");

      String savePath = "${downloadsDir.path}/downloaded_file.pdf";
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        OpenFile.open(savePath);
      } else {
        throw Exception("Failed to download file.");
      }
    } catch (e) {
      log("Download error: $e");
    }
  }
}

class Message {
  final String id, sender, receiver, message, status;
  final String? filePath, reply, replyFilePath;
  final DateTime createdAt, updatedAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    this.filePath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reply,
    this.replyFilePath,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      sender: json['sender'],
      receiver: json['receiver'],
      message: json['message'],
      filePath: json['filePath'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reply: json['reply'],
      replyFilePath: json['replyFilePath'],
    );
  }
}
