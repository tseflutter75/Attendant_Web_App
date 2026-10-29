import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/patient_list_model.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/patient_entry_screen.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/patient_edit_screen.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/patient_single_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PatientListScreen extends StatefulWidget {
  final int fromTabIndex;
  const PatientListScreen({super.key, this.fromTabIndex = 0});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final searchController = TextEditingController();
  bool deleteinquiryinprogresss = false;

  int currentPage = 1;
  int lastPage = 1;

  // en list api
  bool enquiryInProgress = false;
  PatientModel? item;
  final List<PatientModel> _enquiryList = [];

  Future<void> _patientListApi() async {
    enquiryInProgress = true;
    setState(() {});

    String search = searchController.text.trim();

    String url =
        "${Urls.patientListUrl}?search=$search&page=$currentPage&per_page=10";

    ApiResponse response = await NetworkCaller.getRequest(
      url: url,
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      final data = response.responseData;
      final paginationData = data['data'];

      final List listData = paginationData?['data'] ?? [];
      currentPage = paginationData?['current_page'] ?? 1;
      lastPage = paginationData?['last_page'] ?? 1;

      _enquiryList.clear();

      for (var json in listData) {
        _enquiryList.add(PatientModel.fromJson(json));
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
    _patientListApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5ECFC),

      appBar: AppBar(
        backgroundColor: Color(0xFF0B3E6B),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,

        title: const Text(
          "Patient List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Row(
              children: [
                // search
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      currentPage = 1; // নতুন সার্চ করলে ১ম পেজ থেকে শুরু হবে
                      _patientListApi();
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
                const SizedBox(width: 20),

                ElevatedButton(
                  onPressed: () =>
                      Get.to(() => const PatientRegistrationScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B3E6B),
                    minimumSize: const Size(160, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Registration",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                      2: FlexColumnWidth(1.4),
                      3: FlexColumnWidth(1.1),
                      4: FlexColumnWidth(1.2),
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
                          _buildHeaderCell("mobile"),
                          _buildHeaderCell("Sex"),
                          _buildHeaderCell("Action"),
                        ],
                      ),

                      ...List.generate(_enquiryList.length, (index) {
                        final item = _enquiryList[index];
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
                                "${item.patientName}\n${item.patientId}",
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            _buildDataCell(
                              Text(
                                item.mobileNo.toString(),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            _buildDataCell(
                              Text(
                                item.sex.toString(),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            _buildDataCell(
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => PatientSingleViewScreen(
                                            item: item,
                                          ),
                                        );
                                      },

                                      child: Icon(
                                        Icons.visibility,
                                        color: Colors.blue,
                                        size: 20.0,
                                        semanticLabel:
                                            'View content', // For accessibility/screen readers
                                      ),
                                    ),
                                    const SizedBox(width: 2),

                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => PatientEditScreen(item: item),
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                  ],
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

            const SizedBox(height: 10),

            // Pagination Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1
                      ? () {
                          currentPage--;
                          _patientListApi();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3E6B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.chevron_left),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Page $currentPage of $lastPage",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3E6B),
                      fontSize: 14,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: currentPage < lastPage
                      ? () {
                          currentPage++;
                          _patientListApi();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3E6B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),

      // bottom nav
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime inputDate = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yy').format(inputDate);
    } catch (e) {
      return "Invalid Date";
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
