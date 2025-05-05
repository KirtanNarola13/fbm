import 'package:flutter/material.dart';
import '../../../helper/ApiHelper.dart';
import '../../../modal/investmentPlanModal.dart';

class EditInvestmentPlanScreen extends StatefulWidget {
  final InvestmentPlan plan;

  EditInvestmentPlanScreen({required this.plan});

  @override
  _EditInvestmentPlanScreenState createState() =>
      _EditInvestmentPlanScreenState();
}

class _EditInvestmentPlanScreenState extends State<EditInvestmentPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  late TextEditingController expectedReturnController;
  late TextEditingController durationController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.plan.name);
    descriptionController = TextEditingController(
      text: widget.plan.description,
    );
    amountController = TextEditingController(
      text: widget.plan.amount.toString(),
    );
    expectedReturnController = TextEditingController(
      text: widget.plan.expectedReturn.toString(),
    );
    durationController = TextEditingController(
      text: widget.plan.duration.toString(),
    );
  }

  Future<void> _updatePlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Map<String, dynamic> planData = {
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
        "amount": int.tryParse(amountController.text.trim()) ?? 0,
        "expectedReturn":
            int.tryParse(expectedReturnController.text.trim()) ?? 0,
        "duration": int.tryParse(durationController.text.trim()) ?? 0,
      };

      bool result = await ApiHelper.updatePlan(widget.plan.id, planData);
      setState(() => isLoading = false);

      if (result) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Plan updated successfully!")));

        Navigator.pop(context, true); // Pop and return true to refresh list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to update plan.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Investment Plan")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nameController, "Plan Name", Icons.work),
              _buildTextField(
                descriptionController,
                "Description",
                Icons.description,
                maxLines: 3,
              ),
              _buildTextField(
                amountController,
                "Investment Amount",
                Icons.attach_money,
                isNumeric: true,
              ),
              _buildTextField(
                expectedReturnController,
                "Expected Return (%)",
                Icons.percent,
                isNumeric: true,
              ),
              _buildTextField(
                durationController,
                "Duration (Months)",
                Icons.timer,
                isNumeric: true,
              ),

              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: _updatePlan,
                    icon: Icon(Icons.save),
                    label: Text("Update Plan"),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumeric = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Field cannot be empty";
          }
          return null;
        },
      ),
    );
  }
}
