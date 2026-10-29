import 'dart:async';

import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Auth/presentation/screens/login_screen.dart';
import 'package:attendantwebapp/features/Appointment%20List/data/models/appointment_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class QueueListScreen extends StatefulWidget {
  final int fromTabIndex;
  const QueueListScreen({super.key, this.fromTabIndex = 2});

  @override
  State<QueueListScreen> createState() => _QueueListScreenState();
}

class _QueueListScreenState extends State<QueueListScreen> {
  final appointmentDateController = TextEditingController();
  final searchController = TextEditingController();
  Timer? _debounce;

  bool arrivedInProgress = false;
  bool sentToDoctorInProgress = false;

  // en list api
  bool queueInProgress = false;
  AppointmentModel? item;
  final List<AppointmentModel> _queueList = [];

  Future<void> _queueListApi() async {
    queueInProgress = true;
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
        "${Urls.queueListUrl}"
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

      // _queueList.clear();
      // print("========== QUEUE LIST ==========");
      // print("Queue List Length: ${_queueList.length}");

      // for (var json in listData) {
      //   _queueList.add(AppointmentModel.fromJson(json));
      // }
      for (var json in listData) {
        final List appointments = json['appointment'] ?? [];

        print("Appointment: $appointments");

        for (var appointment in appointments) {
          _queueList.add(AppointmentModel.fromJson(appointment));
        }
      }

      // print("========== QUEUE LIST ==========");
      // for (var item in _queueList) {
      //   print(item);
      // }
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

    queueInProgress = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appointmentDateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());
    _queueListApi(); // Load appointments for today's date initially
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
    final List<AppointmentModel> filteredList = _queueList.where((element) {
      // Only show items that are in "QUEUE" status
      if (element.status != "QUEUE") return false;

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
          "Queue List",
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

                        _queueListApi(); // 🔥 API CALL
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
                        _queueListApi();
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
                      1: FlexColumnWidth(1.8),
                      2: FlexColumnWidth(1.1),
                      3: FlexColumnWidth(1.1),
                      4: FlexColumnWidth(1.7),
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
                                item.arrivedTime.isNotEmpty
                                    ? DateFormat('hh:mm a').format(
                                        DateTime.parse(
                                          item.arrivedTime,
                                        ).toLocal(),
                                      )
                                    : '--',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            _buildDataCell(
                              Text(
                                item.status,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),

                            _buildDataCell(
                              Text(
                                item.status == "QUEUE" ? "Sent to Queue" : "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: Colors.black,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // sent to doctor api

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
