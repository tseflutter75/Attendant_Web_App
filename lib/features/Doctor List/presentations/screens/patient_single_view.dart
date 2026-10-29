import 'package:attendantwebapp/features/Doctor%20List/data/patient_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PatientSingleViewScreen extends StatelessWidget {
  final PatientModel item;

  const PatientSingleViewScreen({super.key, required this.item});

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";

    try {
      return DateFormat("dd-MM-yyyy").format(DateTime.parse(date));
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5ECFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3E6B),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Patient Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _field("Patient Name", item.patientName ?? "-"),

            _field("Mobile No", item.mobileNo ?? "-"),

            _field("Email", item.email ?? "-"),

            _field("Date Of Birth", formatDate(item.dob)),

            _field("Sex", item.sex ?? "-"),

            _field("Referred By", item.referredBy ?? "-"),

            _field("Address", item.address ?? "-"),

            _field("Category", item.lookupValue.toString()),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value.isEmpty ? "-" : value,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
