import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/doctor_list_model.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/book_appintment_entry_screen.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/emergency_walkin_entry_screen.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Auth/presentation/screens/login_screen.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/widgets/doctor_card.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/patient_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _formKey = GlobalKey<FormState>();

  // bu_id
  DoctorListModel? selectedDoctor;
  Map<String, dynamic>? selectedBusinessUnit;

  // doctor list api
  bool doctorListInProgress = false;
  DoctorListModel? doctoritem;
  final List<DoctorListModel> _doctorList = [];
  Future<void> _doctorListApi() async {
    doctorListInProgress = true;
    setState(() {});

    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.doctorListUrl,
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      final enquirydata = response.responseData;
      _doctorList.clear();
      for (Map<String, dynamic> enquiryjson in enquirydata['data']) {
        final doctormodel = DoctorListModel.fromJson(enquiryjson);
        _doctorList.add(doctormodel);
      }
    }

    // default selection
    if (_doctorList.isNotEmpty) {
      selectedDoctor = _doctorList.first;

      if (selectedDoctor!.businessUnits != null &&
          selectedDoctor!.businessUnits!.isNotEmpty) {
        selectedBusinessUnit = selectedDoctor!.businessUnits!.first;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,

          content: Center(
            child: Text(
              response.errorMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    doctorListInProgress = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    _doctorListApi();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5ECFC),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0B3E6B)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Patient'),
              onTap: () {
                Navigator.pop(context); // প্রথমে Drawer বন্ধ করুন

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Color(0xFF0B3E6B),
        iconTheme: const IconThemeData(
          color: Colors.white, // Drawer menu icon white
        ),

        centerTitle: true,
        title: Text(
          "Doctor List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                await AuthController.clearUserData();
                Get.offAll(() => LoginScreen());
              },
              icon: Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Column(
            children: [
              /// start
              const SizedBox(height: 20),

              // // // business unit drop dwon
              DropdownButtonFormField<Map<String, dynamic>>(
                isExpanded: true,

                value: selectedBusinessUnit,

                // সব ডাক্তারের business units কে একটি লিস্টে নিয়ে আসা হচ্ছে
                items: _doctorList.expand((doc) {
                  return (doc.businessUnits ?? []).map((bu) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: bu,
                      child: Text(bu['short_name'].toString()),
                    );
                  });
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedBusinessUnit = value;
                    // সিলেক্ট করা BU কোন ডাক্তারের আন্ডারে আছে তা খুঁজে বের করা
                    selectedDoctor = _doctorList.firstWhere(
                      (doc) => (doc.businessUnits ?? []).contains(value),
                      orElse: () => selectedDoctor!,
                    );
                  });
                },

                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,

                  labelText: "Select Area",

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),

                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // doctor list.........................
              selectedDoctor == null
                  ? const SizedBox()
                  : DoctorCard(
                      imageUrl: selectedDoctor?.image ?? "",

                      name: selectedDoctor?.doctorName ?? "",

                      degrees: selectedDoctor?.degrees == null
                          ? []
                          : selectedDoctor!.degrees!
                                .map((e) => e['lookup_value'].toString())
                                .toList(),

                      speciality:
                          selectedDoctor?.speciality?['lookup_value']
                              ?.toString() ??
                          "",

                      // dropdown selected BU show করবে
                      workingPlace:
                          selectedBusinessUnit?['short_name']?.toString() ?? "",

                      onTap: () {
                        Get.to(
                          () => AppointmentScreen(
                            fromTabIndex: 1,
                            ditem: selectedDoctor!,
                            selectedBU: selectedBusinessUnit,
                          ),
                        );
                      },
                      ontapForEmergecy: () {
                        Get.to(
                          () => EmergencyEntryScreen(
                            ditem: selectedDoctor!,
                            selectedBU: selectedBusinessUnit,
                            keyy: "P1",
                          ),
                        );
                      },
                      ontapForWalkIn: () {
                        Get.to(
                          () => EmergencyEntryScreen(
                            ditem: selectedDoctor!,
                            selectedBU: selectedBusinessUnit,
                            keyy: "P3",
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
