import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:file_picker/file_picker.dart'; // For picking date range
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pdf/widgets.dart' as pw; // For generating PDFs
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart'; // For saving PDF
import 'dart:io';
import '../../../helper/ApiHelper.dart';
import '../../../modal/allHistoryModal.dart';

class PayoutHistoryScreen extends StatefulWidget {
  @override
  _PayoutHistoryScreenState createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  List<AllHistoryModel> historyPayouts = [];
  List<AllHistoryModel> filteredPayouts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // Show loading indicator

  @override
  void initState() {
    super.initState();
    fetchHistory();
    searchController.addListener(_filterPayouts);
  }

  Future<void> fetchHistory() async {
    List<AllHistoryModel> data = await ApiHelper.fetchAllPaymentHistory();
    setState(() {
      historyPayouts = data;
      filteredPayouts = data;
      isLoading = false; // Hide loader after fetching
    });
  }

  void _filterPayouts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPayouts =
          historyPayouts
              .where(
                (payout) =>
                    payout.userName.toLowerCase().contains(query) ||
                    payout.phone.contains(query) ||
                    payout.planName.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  // 🔥 Show a popup to select duration before generating the PDF
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
              // Select Specific Month
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
              // Select Date Range
              ListTile(
                title: Text("Select Date Range"),
                trailing: Icon(Icons.date_range),
                onTap: () async {
                  DateTimeRange? pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  );
                  if (pickedRange != null) {
                    selectedRange = pickedRange;
                    Navigator.pop(context);
                    _generatePdf(dateRange: selectedRange);
                  }
                },
              ),
              // Download All Time
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

  // 🔥 Function to generate PDF
  Future<void> _generatePdf({
    DateTime? selectedMonth,
    DateTimeRange? dateRange,
  }) async {
    final pdf = pw.Document();
    final output = await getDownloadsDirectory();
    final file = File("${output?.path}/FBM_Returns_Statement.pdf");

    // Filter Data Based on Selection
    List<AllHistoryModel> filteredData = historyPayouts;
    if (selectedMonth != null) {
      filteredData =
          historyPayouts.where((payout) {
            DateTime payoutDate = DateTime.parse(
              payout.paidDate ?? "2000-01-01",
            );
            return payoutDate.year == selectedMonth.year &&
                payoutDate.month == selectedMonth.month;
          }).toList();
    } else if (dateRange != null) {
      filteredData =
          historyPayouts.where((payout) {
            DateTime payoutDate = DateTime.parse(
              payout.paidDate ?? "2000-01-01",
            );
            return payoutDate.isAfter(dateRange.start) &&
                payoutDate.isBefore(dateRange.end);
          }).toList();
    }

    // 🔥 Create a PDF with modern styling like a bank statement
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "FBM Returns",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Statement Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.center,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: [
                  "Name",
                  "Plan",
                  "Amount",
                  "Month",
                  "Status",
                  "Paid Date",
                ],
                data:
                    filteredData.map((payout) {
                      return [
                        payout.userName,
                        payout.planName,
                        "Rs.${payout.amount.toStringAsFixed(2)}",
                        payout.month,
                        payout.status.toUpperCase(),
                        payout.paidDate != null
                            ? payout.paidDate!.split("T")[0]
                            : "N/A",
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
      SnackBar(content: Text("📄 Statement Downloaded! Check: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payout History"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _showDownloadPopup, // Show popup before generating PDF
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
                labelText: "Search History",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator()) // Show loader
                : Expanded(
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
                        DataColumn(label: Text("Paid Date")),
                      ],
                      rows:
                          filteredPayouts.map((payout) {
                            return DataRow(
                              cells: [
                                DataCell(Text(payout.userName)),
                                DataCell(Text(payout.phone)),
                                DataCell(Text(payout.planName)),
                                DataCell(
                                  Text("₹${payout.amount.toStringAsFixed(2)}"),
                                ),
                                DataCell(Text(payout.month)),
                                DataCell(Text(payout.status.toUpperCase())),
                                DataCell(
                                  Text(
                                    payout.paidDate != null
                                        ? payout.paidDate!.split("T")[0]
                                        : "N/A",
                                  ),
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
