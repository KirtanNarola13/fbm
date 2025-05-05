import 'package:flutter/material.dart';
import '../../../helper/ApiHelper.dart';

class CreateInvestmentPlanScreen extends StatefulWidget {
  @override
  _CreateInvestmentPlanScreenState createState() =>
      _CreateInvestmentPlanScreenState();
}

class _CreateInvestmentPlanScreenState
    extends State<CreateInvestmentPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController expectedReturnController =
      TextEditingController();
  final TextEditingController durationController = TextEditingController();

  bool isLoading = false;

  clearAllFeild() {
    nameController.clear();
    descriptionController.clear();
    amountController.clear();
    expectedReturnController.clear();
    descriptionController.clear();
  }

  Future<void> _submitPlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Map<String, dynamic> planData = {
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
        if (amountController.text.trim().isNotEmpty)
          "amount": int.tryParse(amountController.text.trim()),
        if (expectedReturnController.text.trim().isNotEmpty)
          "expectedReturn": double.tryParse(
            expectedReturnController.text.trim(),
          ),
        "duration": int.tryParse(durationController.text.trim()) ?? 0,
      };

      var result = await ApiHelper.createInvestmentPlan(planData);
      setState(() => isLoading = false);

      if (result == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Plan Created Successfully")),
          );
          clearAllFeild();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ Failed to Create Plan")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Investment Plan")),
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
                    onPressed: _submitPlan,
                    icon: Icon(Icons.check),
                    label: Text("Create Plan"),
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
