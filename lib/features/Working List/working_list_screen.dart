import 'dart:async';

import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Auth/presentation/screens/login_screen.dart';
import 'package:attendantwebapp/features/Appointment%20List/data/models/appointment_list_model.dart';
import 'package:attendantwebapp/features/Working%20List/vital_entry_screen.dart';
import 'package:attendantwebapp/features/Working%20List/vital_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WorkinglistScreen extends StatefulWidget {
  final int fromTabIndex;
  const WorkinglistScreen({super.key, this.fromTabIndex = 2});

  @override
  State<WorkinglistScreen> createState() => _WorkinglistScreenState();
}

class _WorkinglistScreenState extends State<WorkinglistScreen> {
  final appointmentDateController = TextEditingController();
  final searchController = TextEditingController();
  Timer? _debounce;

  bool arrivedInProgress = false;
  bool sentToDoctorInProgress = false;

  // en list api
  bool enquiryInProgress = false;
  AppointmentModel? item;
  final List<AppointmentModel> _enquiryList = [];

  Future<void> _workingListApi() async {
    enquiryInProgress = true;
    setState(() {});

    String search = searchController.text.trim();

    String dateParam = "";
    if (appointmentDateController.text.isNotEmpty) {
      try {
        DateTime parsedDate = DateFormat(
          "dd-MM-yyyy",
        ).parse(appointmentDateController.text);

        dateParam = DateFormat("yyyy-MM-dd").format(parsedDate);
      } catch (e) {
        dateParam = "";
      }
    }

    String url =
        "${Urls.workingListUrl}"
        "?search=$search"
        "&appointment_date=$dateParam";

    ApiResponse response = await NetworkCaller.getRequest(
      url: url,
      token: AuthController.accessToken,
    );

    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      final data = response.responseData;

      // ✅ FIX: correct list path
      final List listData = data['data']?['data'] ?? [];

      _enquiryList.clear();

      for (var json in listData) {
        _enquiryList.add(AppointmentModel.fromJson(json));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              response.errorMessage,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    enquiryInProgress = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appointmentDateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());
    _workingListApi(); // Load appointments for today's date initially
  }

  @override
  void dispose() {
    _debounce?.cancel();
    appointmentDateController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Local filtering logic: Filter the list based on the controller's date
    final List<AppointmentModel> filteredList = _enquiryList.where((element) {
      if (appointmentDateController.text.isEmpty) return true;

      try {
        // date select
        DateTime selected = DateFormat(
          'dd-MM-yyyy',
        ).parse(appointmentDateController.text);

        // formate for api key  "appointment_date": "2026-05-22",
        String formattedSelected = DateFormat('yyyy-MM-dd').format(selected);

        // api theke nilam and formate korlam
        DateTime itemDate = DateTime.parse(element.appointmentDate);
        String formattedItemDate = DateFormat('yyyy-MM-dd').format(itemDate);

        return formattedSelected == formattedItemDate;
      } catch (e) {
        return false;
      }
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFE5ECFC),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B3E6B),

        centerTitle: true,

        title: const Text(
          "Working List",
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

      body: Padding(
        padding: EdgeInsets.only(left: 7, right: 7, top: 10),
        child: Column(
          children: [
            SizedBox(height: 10),

            Row(
              children: [
                // date inquiry
                Expanded(
                  child: TextFormField(
                    controller: appointmentDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      hintText: "Date",
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      filled: true,
                      fillColor: Colors.white,

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
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        appointmentDateController.text = DateFormat(
                          'dd-MM-yyyy',
                        ).format(pickedDate);

                        _workingListApi(); // 🔥 API CALL
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a date inquiry";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _workingListApi();
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      hintText: "Search ",
                      suffixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,

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
                ),
              ],
            ),

            SizedBox(height: 16),

            // Clean, Professional Combined Table
            Expanded(
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(0.4),
                      1: FlexColumnWidth(1.7),
                      2: FlexColumnWidth(1.0),
                      3: FlexColumnWidth(1.0),
                      4: FlexColumnWidth(1.8),
                    },
                    // Modern lightweight borders instead of heavy black dividers
                    border: TableBorder.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    children: [
                      // Header
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFFF4F6F9,
                          ), // Subtle grey professional background
                        ),
                        children: [
                          _buildHeaderCell("#"),
                          _buildHeaderCell("Patient"),
                          _buildHeaderCell("A.Time"),
                          _buildHeaderCell("Status"),
                          _buildHeaderCell("Action"),
                        ],
                      ),

                      ...List.generate(filteredList.length, (index) {
                        final item = filteredList[index];
                        // Zebra striping effect for excellent data scannability
                        final isEven = index % 2 == 0;

                        return TableRow(
                          decoration: BoxDecoration(
                            color: isEven ? Colors.white : Colors.grey.shade50,
                          ),
                          children: [
                            _buildDataCell(
                              Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            _buildDataCell(
                              alignment: Alignment.centerLeft,
                              Text(
                                "${item.patientName}\n${item.mobileNo}",
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),

                            _buildDataCell(
                              Text(
                                DateFormat('hh:mm a').format(
                                  DateTime.parse(item.arrivedTime).toLocal(),
                                ),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            _buildDataCell(
                              Text(
                                "${item.patientType}\n${item.appointmentType == "P1"
                                    ? "EMERGENCY"
                                    : item.appointmentType == "P2"
                                    ? "BOOKED"
                                    : "WALK IN"}",
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),

                            _buildDataCell(
                              ///....................button logic start.................
                              item.status != "CANCELLED" &&
                                      item.status != "QUEUE"
                                  ? Row(
                                      children: [
                                        // row
                                        GestureDetector(
                                          onTap: () async {
                                            // TODO: Implement Cancel logic

                                            bool?
                                            confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Are you sure?"),
                                                content: Text(
                                                  "Do you want to Update?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(
                                                      result: false,
                                                    ), // No
                                                    child: Text(
                                                      "No",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 22,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Get.back(
                                                      result: true,
                                                    ), // Yes
                                                    child: Text(
                                                      "Yes",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color(
                                                          0xFF8F66DC,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm != true) return;

                                            await _updateStatusApi(
                                              item.id.toString(),
                                              "CANCELLED",
                                            );
                                            await _workingListApi();
                                          },
                                          child: const Text(
                                            "      ",
                                            style: TextStyle(
                                              color: Color(0xFFDC2626),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        /// যদি prPatientId থাকে তাহলে শুধু Edit + Send দেখাবে
                                        if (item.prPatientId != null) ...[
                                          GestureDetector(
                                            onTap: () async {
                                              // Edit Action
                                              var result = await Get.to(
                                                () =>
                                                    VitalPatientInfoUpdateScreen(
                                                      dataitem: item,
                                                    ),
                                              );
                                              if (result == true) {
                                                await _workingListApi();
                                              }
                                            },
                                            child: Container(
                                              height: 27,

                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFEF3C7),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF92400E,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                    color: Color(0xFF92400E),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          GestureDetector(
                                            onTap: () async {
                                              // Send Action
                                              var res = await _senttoDoctorApi(
                                                item.id.toString(),
                                              );
                                              if (res == true) {
                                                await _workingListApi();
                                              }
                                            },
                                            child: Container(
                                              height: 27,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0F2FE),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Color(0xFF0369A1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  "Send",
                                                  style: TextStyle(
                                                    color: Color(0xFF0369A1),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                        /// prPatientId না থাকলে আগের button logic চলবে
                                        else ...[
                                          // arrived button
                                          if (item.registrationType == "NEW" &&
                                              item.status == "BOOKED") ...[
                                            const SizedBox(width: 8),
                                            Center(
                                              child: const Text(
                                                "",
                                                style: TextStyle(
                                                  color: Color(0xFF6D28D9),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ] else if (item.registrationType ==
                                                  "REGISTERED" &&
                                              item.status == "ARRIVED") ...[
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () async {
                                                var result = await Get.to(
                                                  () => VitalPatientInfoEntryScreen(
                                                    singlePatientId:
                                                        item.registerPatientId ??
                                                        0,
                                                    apitem: item,
                                                  ),
                                                );
                                                if (result == true) {
                                                  _workingListApi();
                                                }
                                              },

                                              child: Container(
                                                height: 27,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFD1FAE5),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Color(0xFF065F46),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: const Text(
                                                    "Vitals",
                                                    style: TextStyle(
                                                      color: Color(0xFF065F46),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ] else if ((item.registrationType ==
                                                      "NEW" ||
                                                  item.registrationType ==
                                                      "REGISTERED") &&
                                              item.status == "BOOKED") ...[
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () async {
                                                bool?
                                                confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: const Text(
                                                          "Are you sure?",
                                                        ),
                                                        content: const Text(
                                                          "Do you want to Update?",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Get.back(
                                                                  result: false,
                                                                ), // No
                                                            child: const Text(
                                                              "No",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 22,
                                                              ),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Get.back(
                                                                  result: true,
                                                                ), // Yes
                                                            child: const Text(
                                                              "Yes",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                  0xFF8F66DC,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );

                                                if (confirm != true) return;

                                                await _updateStatusApi(
                                                  item.id.toString(),
                                                  "ARRIVED",
                                                );
                                                await _workingListApi();
                                              },
                                              child: Container(
                                                height: 27,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFFEDD5),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Color(0xFFC2410C),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: const Text(
                                                    "Arrived",
                                                    style: TextStyle(
                                                      color: Color(0xFFC2410C),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        "Sent to Doctor",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatusApi(String id, String status) async {
    if (arrivedInProgress) return;

    arrivedInProgress = true;
    setState(() {});

    final Map<String, dynamic> requestBody = {
      "updated_by": AuthController.userModel!.id,
      "status": status,
    };

    ApiResponse response = await NetworkCaller.postRequest(
      url: Urls.arrivedButtonUrl(id),
      body: requestBody,
      token: AuthController.accessToken,
    );

    if (response.isSuccess && response.responseData["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Color(0xFF0B3E6B),

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
    if (mounted) {
      arrivedInProgress = false;
      setState(() {});
    }
  }

  // sent to doctor api
  Future<bool?> _senttoDoctorApi(String id) async {
    if (sentToDoctorInProgress) return false;

    sentToDoctorInProgress = true;
    if (mounted) setState(() {});

    final Map<String, dynamic> requestBody = {"status": "QUEUE"};

    ApiResponse response = await NetworkCaller.postRequest(
      url: Urls.sentToDoctorQueueUrl(id),
      body: requestBody,
      token: AuthController.accessToken,
    );

    if (mounted) {
      sentToDoctorInProgress = false;
      setState(() {});
    }

    if (response.isSuccess && response.responseData["status"] == "success") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Color(0xFF0B3E6B),
            content: Center(
              child: Text(
                response.errorMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
      return true;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                response.errorMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
      return true;
    }
  }

  // 2 table
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF34495E),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    Widget child, {
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      height: 48, // Reduced from 55 to match clean dashboard design standards
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: child,
    );
  }
}
