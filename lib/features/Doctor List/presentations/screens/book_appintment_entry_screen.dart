import 'dart:convert';
import 'package:attendantwebapp/features/Doctor%20List/data/book_check_model.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/emergency_walkin_entry_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/doctor_list_model.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/pateint_search_model.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Common/presentation/widgets/custom_textfeild.dart';
import 'package:attendantwebapp/features/Common/presentation/widgets/doctor_book_card.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentScreen extends StatefulWidget {
  final int fromTabIndex;
  final DoctorListModel ditem;
  final Map<String, dynamic>? selectedBU;

  const AppointmentScreen({
    super.key,
    required this.fromTabIndex,
    required this.ditem,
    this.selectedBU,
  });

  @override
  State<AppointmentScreen> createState() => _AppintmentScreenState();
}

class _AppintmentScreenState extends State<AppointmentScreen> {
  final _patientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _visitnoController = TextEditingController();

  final _oldpatientNameController = TextEditingController();
  final _oldphoneController = TextEditingController();
  final _oldvisitnoController = TextEditingController();

  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  bool appointmentInProgress = false;

  final List<String> pateinttypelist = ["New Patient", "Registered"];
  String? selectedPatient;

  // pateint search get api
  bool pateintSearchInProgress = false;
  PatientModelSearch? selectedSeacrchPatient;
  final List<PatientModelSearch> _pateintList = [];

  Future<void> _pateintSearchListApi() async {
    print("API CALL START");

    setState(() {
      pateintSearchInProgress = true;
    });

    try {
      final response = await http.get(
        Uri.parse(Urls.patientSearchUrl),
        headers: {'Authorization': 'Bearer ${AuthController.accessToken}'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final List decodedData = jsonDecode(response.body);

        _pateintList.clear();

        for (var item in decodedData) {
          _pateintList.add(PatientModelSearch.fromJson(item));
        }
      } else {
        print("Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    setState(() {
      pateintSearchInProgress = false;
    });
  }

  // next visit num
  int nextVisitNo = 0;
  bool inprogressnextvisit = false;

  Future<void> nextVisitApi(int patientId, int doctorId) async {
    setState(() {});

    try {
      final uri = Uri.parse(Urls.nextvisitUrl);

      final request = http.Request("GET", uri);

      request.headers.addAll({
        'Authorization': 'Bearer ${AuthController.accessToken}',
        'Content-Type': 'application/json',
      });

      // 🔥 body send in GET
      request.body = jsonEncode({
        "patient_id": patientId,
        "doctor_id": doctorId,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        nextVisitNo = decodedData['next_visit_no'] ?? 0;

        print("Next Visit No: $nextVisitNo");
      } else {
        print("Failed: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {});
  }

  //  book checked api........................................
  bool bookcheckedInProgress = false;
  List<BookChecked> _bookcheckList = [];
  final Map<int, String> bookedSlots = {};

  Future<void> _bookCheckedApi() async {
    if (bookcheckedInProgress) return;

    String formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    bookedSlots.clear();
    _bookcheckList.clear();
    setState(() {});

    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.bookappointmentViewUrl(
        widget.ditem.id.toString(),
        widget.selectedBU!['id'].toString(),
        formattedDate,
      ),
      token: AuthController.accessToken,
    );

    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      print("All Schedule = ${_allSchedules.length}");

      final data = response.responseData['data'];
      for (Map<String, dynamic> json in data) {
        final model = BookChecked.fromJson(json);
        _bookcheckList.add(model);

        // bookedSlots[model.slotNo!] = model.status!;
        if (model.slotNo != null && model.status != null) {
          bookedSlots[model.slotNo!] = model.status!;
        }
      }

      _selectFirstAvailableSlot();
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
      bookcheckedInProgress = false;
      setState(() {});
    }
  }

  // chamber shift...........................................
  bool doctorScheduleInProgress = false;
  List<dynamic> _allSchedules = [];
  Map<String, dynamic>? _selectedDaySchedule;
  List<dynamic> _currentSlots = [];

  Future<void> _doctorScheduleListApi() async {
    doctorScheduleInProgress = true;
    setState(() {});

    // Business Unit ID বের করা
    String buId = widget.selectedBU?['id']?.toString() ?? "";
    if (buId.isEmpty && widget.ditem.businessUnits?.isNotEmpty == true) {
      buId = widget.ditem.businessUnits!.first['id'].toString();
    }

    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.chamberScheduleUrl(widget.ditem.id.toString(), buId),
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      _allSchedules = response.responseData['data'];

      _filterSlotsForSelectedDay();
      await _bookCheckedApi();
    }

    doctorScheduleInProgress = false;
    setState(() {});
  }

  // সিলেক্ট করা দিনের (Day Name) উপর ভিত্তি করে স্লট ফিল্টার করা
  void _filterSlotsForSelectedDay() {
    if (dates.isEmpty || _allSchedules.isEmpty) return;

    String selectedDayName = dates[selectedIndex]["day"]!;

    // API ডাটা থেকে ওই দিনের শিডিউল খুঁজে বের করা
    final scheduleForDay = _allSchedules.firstWhere(
      (element) =>
          element['days'].toString().toLowerCase() ==
          selectedDayName.toLowerCase(),
      orElse: () => null,
    );

    if (scheduleForDay != null) {
      _currentSlots = scheduleForDay['slot_details'] ?? [];
      _selectedDaySchedule = scheduleForDay; // Store the found schedule
    } else {
      _currentSlots = [];
      _selectedDaySchedule = null;
    }
    setState(() {});
  }

  // schedule 1st part
  int visitvale = 1;
  DateTime? selectedDate;
  int selectedIndex = 0;
  List<Map<String, String>> dates = [];

  void generateWeek(DateTime startDate) {
    List<Map<String, String>> temp = [];

    for (int i = 0; i < 7; i++) {
      DateTime date = startDate.add(Duration(days: i));

      String day = getDayName(date.weekday);

      temp.add({"day": day, "date": date.day.toString()});
    }

    setState(() {
      dates = temp;
      selectedIndex = 0;
    });
  }

  String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  int selectedIndexshift = 0;

  // ডাইনামিক ডেট ও স্লট ফিল্টার পরিবর্তন মেথড
  Future<void> _onDateOrDayChanged(int index, DateTime newDate) async {
    setState(() {
      selectedIndex = index;
      selectedDate = newDate;
      selectedIndexshift = -1; // স্লট রিসেট
    });
    _filterSlotsForSelectedDay();
    await _bookCheckedApi(); // নতুন করে বুকড স্লট ডাটা রিকোয়েস্ট
  }
  //   Future<void> _onDateOrDayChanged(
  //   int index,
  //   DateTime newDate,
  // ) async {
  //   setState(() {
  //     selectedIndex = index;
  //     selectedDate = newDate;
  //     selectedIndexshift = -1;

  //     bookedSlots.clear();
  //     _bookcheckList.clear();
  //   });

  //   _filterSlotsForSelectedDay();

  //   // 🔥 নতুন date-টা API-তে পাঠাচ্ছি
  //   await _bookCheckedApi(newDate);
  // }

  // empty slot thakle bose jabe auto slot
  void _selectFirstAvailableSlot() {
    selectedIndexshift = -1;

    for (int i = 0; i < _currentSlots.length; i++) {
      final slotNo = _currentSlots[i]['slot_no'];
      final status = bookedSlots[slotNo] ?? "";

      // BOOKED এবং ARRIVED বাদ দিয়ে প্রথম slot select হবে
      if (status != "BOOKED" && status != "ARRIVED") {
        selectedIndexshift = i;
        break;
      }
    }
  }

  // init State lifecircle
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedPatient = pateinttypelist[0];
    _visitnoController.text = visitvale.toString();

    selectedDate = DateTime.now();
    generateWeek(selectedDate!);

    _doctorScheduleListApi(); // API কল করা হচ্ছে
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
        title: Text(
          "Book Appointment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),

      body: Form(
        key: _fromKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorBookCard(
                  imageUrl: widget.ditem.image ?? "",
                  name: widget.ditem.doctorName ?? "",
                  degrees: widget.ditem.degrees == null
                      ? []
                      : widget.ditem.degrees!
                            .map((e) => e['lookup_value'].toString())
                            .toList(),
                  speciality:
                      widget.ditem.speciality?['lookup_value']?.toString() ??
                      "",
                  workingPlace:
                      widget.selectedBU?['short_name']?.toString() ??
                      (widget.ditem.businessUnits?.isNotEmpty == true
                          ? widget.ditem.businessUnits!.first['short_name']
                                .toString()
                          : ""),
                  ontapForEmergecy: () {
                    Get.to(
                      () => EmergencyEntryScreen(
                        ditem: widget.ditem,
                        selectedBU: widget.selectedBU,
                        keyy: "P1",
                      ),
                    );
                  },
                  ontapForWalkIn: () {
                    Get.to(
                      () => EmergencyEntryScreen(
                        ditem: widget.ditem,
                        selectedBU: widget.selectedBU,
                        keyy: "P3",
                      ),
                    );
                  },
                ),

                // schedule...............................................................
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Schedule",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        if (selectedDate != null)
                          Text(
                            "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}  ",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3E6B),
                            ),
                          ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              generateWeek(
                                picked,
                              ); // সপ্তাহের দিনগুলো নতুন করে জেনারেট
                              await _onDateOrDayChanged(
                                0,
                                picked,
                              ); // প্রথম ইনডেক্সে সিলেক্টেড ডেট ও এপিআই কল সেট
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B3E6B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Pick Date",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // list of day and num
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () async {
                          // সিলেক্ট করা ইনডেক্স অনুযায়ী তারিখ ক্যালকুলেট করা হচ্ছে
                          DateTime targetDate = selectedDate!
                              .subtract(Duration(days: selectedIndex))
                              .add(Duration(days: index));

                          // দিন পরিবর্তন মেথড কল
                          await _onDateOrDayChanged(index, targetDate);
                        },
                        child: Container(
                          width: 70,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF0B3E6B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Color(0xFF0B3E6B)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dates[index]["day"]!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                dates[index]["date"]!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // seletct type
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedPatient,
                  items: pateinttypelist
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    setState(() {
                      selectedPatient = value;
                    });

                    if (value == "Registered") {
                      await _pateintSearchListApi();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Patient Type',
                    filled: true,
                    fillColor: Colors.white,

                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                SizedBox(height: 10),

                ///
                if (selectedPatient == "New Patient") ...[
                  CustomTextField(
                    hintText: "Patient Name",
                    controller: _patientNameController,
                    filled: true,
                    fillColor: Colors.white,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter patient name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  CustomTextField(
                    hintText: "Mobile Number",
                    controller: _phoneController,
                    filled: true,
                    fillColor: Colors.white,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(11),
                      FilteringTextInputFormatter
                          .digitsOnly, // শুধু নাম্বার ইনপুট নিতে
                    ],

                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter phone number";
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  DropdownSearch<PatientModelSearch>(
                    items: _pateintList,
                    itemAsString: (PatientModelSearch t) =>
                        "${t.patientId} || ${t.patientName.toString()}",
                    selectedItem: selectedSeacrchPatient,
                    onChanged: (PatientModelSearch? pas) async {
                      if (pas != null) {
                        selectedSeacrchPatient = pas;
                        setState(() {
                          _oldpatientNameController.text = pas.patientName
                              .toString();

                          _oldphoneController.text = pas.mobileNo.toString();
                        });

                        await nextVisitApi(pas.id!, widget.ditem.id!);
                        _oldvisitnoController.text = nextVisitNo.toString();
                      }
                    },
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      showSelectedItems: false,
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        hintText: "Search Patient...",
                        labelText: "Search Patient...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  CustomTextField(
                    hintText: "Patient Name",
                    controller: _oldpatientNameController,
                    filled: true,
                    fillColor: Colors.white,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter patient name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  CustomTextField(
                    hintText: "Mobile Number",
                    controller: _oldphoneController,
                    filled: true,
                    fillColor: Colors.white,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter phone number";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 10),
                ],

                const SizedBox(height: 20),

                Center(
                  child: appointmentInProgress
                      ? const CircularProgressIndicator()
                      : FilledButton(
                          onPressed: () {
                            if (_fromKey.currentState!.validate()) {
                              _appointmentStore();
                            }
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF0B3E6B),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            "Confirm Appointment",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                if (_selectedDaySchedule != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "${_selectedDaySchedule!['shift_name'] ?? ''} Shift  "
                      "${_selectedDaySchedule!['time_from'] ?? ''} - "
                      "${_selectedDaySchedule!['time_to'] ?? ''} "
                      "(Slots: ${_selectedDaySchedule!['slot_number'] ?? ''})",
                      style: const TextStyle(
                        color: Color(0xFF0B3E6B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                _currentSlots.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currentSlots.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.1,
                            ),
                        itemBuilder: (context, index) {
                          bool isSelected = selectedIndexshift == index;
                          final slot = _currentSlots[index];

                          final slotNo = slot['slot_no'];

                          String status = bookedSlots[slotNo] ?? "";

                          bool isBooked = status == "BOOKED";
                          bool isArrived = status == "ARRIVED";
                          bool isQueue = status == "QUEUE";
                          return GestureDetector(
                            onTap: () {
                              // ১. স্লটটি বুকড অথবা অ্যারাইভড থাকলে ক্লিক এখানে রিটার্ন বা ব্লক হবে
                              if (isBooked || isArrived) return;

                              setState(() {
                                selectedIndexshift = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isBooked
                                    ? Colors.grey.shade300
                                    : isQueue
                                    ? Colors.deepOrange
                                    : isArrived
                                    ? Colors.green
                                    : isSelected
                                    ? const Color(0xFF0B3E6B)
                                    : Colors.white,

                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF0B3E6B),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF0B3E6B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      slot['slot_no'].toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? const Color(0xFF0B3E6B)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    slot['time'].toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No schedule available for this day.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // bottom nav
    );
  }

  Future<void> _appointmentStore() async {
    if (appointmentInProgress) return;

    String buId = widget.selectedBU?['id']?.toString() ?? "";
    if (buId.isEmpty && widget.ditem.businessUnits?.isNotEmpty == true) {
      buId = widget.ditem.businessUnits!.first['id'].toString();
    }

    String appointmentDateStr = selectedDate != null
        ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
        : "";

    final selectedSlot =
        selectedIndexshift >= 0 && selectedIndexshift < _currentSlots.length
        ? _currentSlots[selectedIndexshift]
        : null;

    appointmentInProgress = true;
    setState(() {});

    final Map<String, dynamic> requestBody = {
      "doctors_id": widget.ditem.id,
      "bu_id": buId,
      "registration_type": selectedPatient == "New Patient"
          ? "NEW"
          : "REGISTERED",
      "visit_no": selectedPatient == "New Patient"
          ? _visitnoController.text
          : _oldvisitnoController.text,
      "appointment_date": appointmentDateStr,
      "appointment_time": selectedSlot?['time'] ?? "",
      "slot_no": selectedSlot?['slot_no'] ?? "",
      "schedule_id": _selectedDaySchedule?['id'],
      "patient_name": selectedPatient == "New Patient"
          ? _patientNameController.text
          : _oldpatientNameController.text,
      "mobile_no": selectedPatient == "New Patient"
          ? _phoneController.text
          : _oldphoneController.text,
      "day_name": dates[selectedIndex]["day"],

      "register_patient_id": selectedPatient == "Registered"
          ? selectedSeacrchPatient?.id
          : null,
      "shift_name": _selectedDaySchedule?['shift_name'],
      "created_by": AuthController.userModel!.id,
      // Static data
      "status": "BOOKED",
      "appointment_type": "P2",
    };

    ApiResponse response = await NetworkCaller.postRequest(
      url: Urls.apointmentEntryUrl,
      body: requestBody,
      token: AuthController.accessToken,
    );

    if (response.isSuccess && response.responseData["status"] == "success") {
      _clearText();
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
      // 🔥 Important
      // পুরোনো selected slot remove
      setState(() {
        selectedIndexshift = -1;
      });

      // 🔥 আবার server থেকে booked slot check করবে
      await _bookCheckedApi();
    } else {
      String message = response.responseData["message"] ?? "";

      final errors = response.responseData["errors"];

      if (errors != null) {
        if (errors is Map) {
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              message += "\n${value.first}";
            } else {
              message += "\n$value";
            }
          });
        } else if (errors is List) {
          for (var error in errors) {
            message += "\n$error";
          }
        }
      }

      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    if (mounted) {
      appointmentInProgress = false;
      setState(() {});
    }
  }

  void _clearText() {
    _patientNameController.clear();
    _phoneController.clear();
    _oldpatientNameController.clear();
    _oldphoneController.clear();
    _oldvisitnoController.clear();
    selectedSeacrchPatient = null;
    setState(() {});
  }
}
