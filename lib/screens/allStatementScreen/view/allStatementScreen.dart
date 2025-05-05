import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../modal/getAllUserModal.dart';

class AllStatementsOfUserScreen extends StatefulWidget {
  final User user;

  AllStatementsOfUserScreen({required this.user});

  @override
  State<AllStatementsOfUserScreen> createState() =>
      _AllStatementsOfUserScreenState();
}

class _AllStatementsOfUserScreenState extends State<AllStatementsOfUserScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${user.name} - Statements',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(icon: Icon(Icons.download), onPressed: _showDownloadPopup),
        ],
      ),
      body:
          user.statements.isEmpty
              ? Center(
                child: Text(
                  "No statements available",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              )
              : ListView.builder(
                itemCount: user.statements.length,
                padding: EdgeInsets.only(top: 16),
                itemBuilder: (context, index) {
                  final statement =
                      user.statements[user.statements.length - 1 - index];
                  return StatementCard(statement: statement);
                },
              ),
    );
  }

  void _showDownloadPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Download Invoice"),
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
                    Navigator.pop(context);
                    _generatePdf(selectedMonth: picked);
                  }
                },
              ),
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
                    Navigator.pop(context);
                    _generatePdf(dateRange: pickedRange);
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

  Future<void> _generatePdf({
    DateTime? selectedMonth,
    DateTimeRange? dateRange,
  }) async {
    List<Statement> filteredStatements = widget.user.statements;

    if (selectedMonth != null) {
      filteredStatements =
          widget.user.statements.where((statement) {
            DateTime statementDate = DateTime.parse(statement.date!);
            return statementDate.year == selectedMonth.year &&
                statementDate.month == selectedMonth.month;
          }).toList();
    } else if (dateRange != null) {
      filteredStatements =
          widget.user.statements.where((statement) {
            DateTime statementDate = DateTime.parse(statement.date!);
            return statementDate.isAfter(dateRange.start) &&
                statementDate.isBefore(dateRange.end);
          }).toList();
    }

    if (filteredStatements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No statements found for the selected period.")),
      );
      return;
    }

    final pdf = pw.Document();
    final output = await getDownloadsDirectory();
    final file = File("${output?.path}/Invoice_${widget.user.name}.pdf");

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Invoice for ${widget.user.name}",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Invoice Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.center,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ["Description", "Amount", "Date"],
                data:
                    filteredStatements.map((statement) {
                      DateTime date = DateTime.parse(statement.date!);
                      return [
                        statement.description,
                        "₹${statement.amount}",
                        DateFormat("dd MMM yyyy").format(date),
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
}

class StatementCard extends StatelessWidget {
  final Statement statement;

  StatementCard({required this.statement});

  @override
  Widget build(BuildContext context) {
    bool isInvestment = statement.type == "investment";
    DateTime date = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(statement.date!);
    String formattedDate = DateFormat("dd MMM yyyy, hh:mm a").format(date);

    IconData icon = isInvestment ? Icons.trending_up : Icons.account_balance;
    Color iconColor = isInvestment ? Colors.orange : Colors.green;
    Color cardColor =
        isInvestment
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1);

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: iconColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statement.description,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Amount: ₹${statement.amount}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
