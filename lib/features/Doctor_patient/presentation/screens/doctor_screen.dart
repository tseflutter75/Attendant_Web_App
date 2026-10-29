import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/patient_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5ECFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0B3E6B),
        centerTitle: true,
        title: Text(
          "Doctor's",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            // _buildMenuButton(
            //   context: context,
            //   title: "Visit",
            //   icon: Icons.medical_services_outlined,
            //   onTap: () {},
            // ),
            // _buildMenuButton(
            //   context: context,
            //   title: "Doctor Profile",
            //   icon: Icons.account_circle_outlined,
            //   onTap: () {},
            // ),
            // _buildMenuButton(
            //   context: context,
            //   title: "Chamber Schedule",
            //   icon: Icons.calendar_month_outlined,
            //   onTap: () {},
            // ),
            _buildMenuButton(
              context: context,
              title: "Patient",
              icon: Icons.person,
              onTap: () {
                Get.to(() => PatientListScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.white, width: 2.5),
        ),
        color: const Color(0xFFFCFDFF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF0B3E6B)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3E6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
