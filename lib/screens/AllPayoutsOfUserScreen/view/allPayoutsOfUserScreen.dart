import 'dart:io';

import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../modal/getAllUserModal.dart';

class AllPayoutsOfUserScreen extends StatefulWidget {
  final User user;

  AllPayoutsOfUserScreen({required this.user});

  @override
  State<AllPayoutsOfUserScreen> createState() => _AllPayoutsOfUserScreenState();
}

class _AllPayoutsOfUserScreenState extends State<AllPayoutsOfUserScreen> {
  late List<Map<String, dynamic>> allPayouts;

  @override
  void initState() {
    super.initState();
    _preparePayouts();
  }

  void _preparePayouts() {
    allPayouts = [];

    for (var investment in widget.user.investments) {
      for (var payout in investment.payouts) {
        allPayouts.add({"payout": payout, "planName": investment.plan});
      }
    }

    allPayouts.sort((a, b) {
      DateTime dateB = DateTime.parse('${b["payout"].month}-01');
      DateTime dateA = DateTime.parse('${a["payout"].month}-01');
      return dateB.compareTo(dateA);
    });
  }

  // 🔥 Show the download popup
  void _showDownloadPopup() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? selectedMonth;
        DateTimeRange? selectedRange;

        return AlertDialog(
          title: Text("Download Statement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Select a Month"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showMonthPicker(
                    context: context,
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    selectedMonth = picked;
                    Navigator.pop(context);
                    _generatePdf(selectedMonth: selectedMonth);
                  }
                },
              ),
              ListTile(
                title: Text("All Time"),
                trailing: Icon(Icons.history),
                onTap: () {
                  Navigator.pop(context);
                  _generatePdf();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔥 Generate Invoice PDF
  Future<void> _generatePdf({DateTime? selectedMonth}) async {
    final pdf = pw.Document();
    final output = await getDownloadsDirectory();
    final file = File(
      "${output?.path}/${widget.user.name}_Payout_Statement.pdf",
    );

    List<Map<String, dynamic>> filteredPayouts = allPayouts;
    if (selectedMonth != null) {
      filteredPayouts =
          allPayouts.where((payout) {
            DateTime payoutDate = DateTime.parse(
              "${payout["payout"].month}-01",
            );
            return payoutDate.year == selectedMonth.year &&
                payoutDate.month == selectedMonth.month;
          }).toList();
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Payout Statement - ${widget.user.name}",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.center,
                headers: ["Plan", "Amount", "Month", "Status", "Paid Date"],
                data:
                    filteredPayouts.map((payout) {
                      return [
                        payout["planName"],
                        "Rs.${payout["payout"].amount}",
                        payout["payout"].month,
                        payout["payout"].status.toUpperCase(),
                        payout["payout"].paidDate ?? "Not Paid",
                      ];
                    }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("📄 Invoice Downloaded! Check: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name} - Payouts'),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.black),
            onPressed: _showDownloadPopup,
          ),
        ],
      ),
      body:
          allPayouts.isEmpty
              ? Center(child: Text('No payouts available.'))
              : ListView.builder(
                itemCount: allPayouts.length,
                itemBuilder: (context, index) {
                  final payout = allPayouts[index]["payout"];
                  final planName = allPayouts[index]["planName"];

                  return Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 2,
                        color:
                            payout.status == "paid"
                                ? Colors.green
                                : Colors.orange,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            payout.status == "paid"
                                ? Icons.check_circle
                                : Icons.hourglass_empty,
                            color:
                                payout.status == "paid"
                                    ? Colors.green
                                    : Colors.orange,
                            size: 28,
                          ),
                          title: Text(
                            "Paid on: ${payout.paidDate ?? 'Not Paid'}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Amount: ₹${payout.amount}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  payout.status == "paid"
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              payout.status.toUpperCase(),
                              style: TextStyle(
                                color:
                                    payout.status == "paid"
                                        ? Colors.green
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Plan: $planName",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
