import 'dart:convert';
import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/doctor_list_model.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/pateint_search_model.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Doctor_patient/data/models/category_list_model.dart';
import 'package:attendantwebapp/features/Common/presentation/widgets/custom_textfeild.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EmergencyEntryScreen extends StatefulWidget {
  final DoctorListModel ditem;
  final String keyy;
  final Map<String, dynamic>? selectedBU;
  const EmergencyEntryScreen({
    super.key,
    required this.ditem,
    this.selectedBU,
    required this.keyy,
  });

  @override
  State<EmergencyEntryScreen> createState() => _EmergencyEntryScreenState();
}

class _EmergencyEntryScreenState extends State<EmergencyEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _sexController = TextEditingController();
  final _refbyController = TextEditingController();
  final _addressController = TextEditingController();
  final visitnoController = TextEditingController();
  final ageController = TextEditingController();

  // Dropdown values

  bool registrationInProgress = false;

  bool categoryInProgress = false;
  CategoryListModel? selectedCategory;
  final List<CategoryListModel> _categoryList = [];
  Future<void> _categoryListApi() async {
    categoryInProgress = true;
    setState(() {});
    _categoryList.clear();
    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.categoryListUrl,
      token: AuthController.accessToken,
    );
    if (response.isSuccess && response.responseData['status'] == "success") {
      final enquirydata = response.responseData;

      for (Map<String, dynamic> enquiryjson in enquirydata['data']) {
        final model = CategoryListModel.fromJson(enquiryjson);
        _categoryList.add(model);
      }

      // Set default selection to "Regular" if it exists in the list
      if (_categoryList.isNotEmpty) {
        try {
          selectedCategory = _categoryList.firstWhere(
            (element) =>
                element.lookupValue?.toString().toLowerCase() == "regular",
          );
        } catch (e) {
          // "Regular" not found in the list, selectedCategory remains null
        }
      }
    } else if (!response.isSuccess) {
      Get.snackbar(
        "Error",
        "Failed to load categories: ${response.errorMessage}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    categoryInProgress = false;
    setState(() {});
  }

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

  @override
  void initState() {
    super.initState();
    _refbyController.text = "Self";
    _sexController.text = "Male";
    _dobController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    _categoryListApi();
    _pateintSearchListApi();
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
          "Patient Registration",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ), // ইমেজের ব্যাকগ্রাউন্ড কালার
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownSearch<PatientModelSearch>(
                  items: _pateintList,
                  itemAsString: (PatientModelSearch t) =>
                      "${t.patientId} || ${t.patientName.toString()}",
                  selectedItem: selectedSeacrchPatient,
                  onChanged: (PatientModelSearch? pas) async {
                    if (pas != null) {
                      selectedSeacrchPatient = pas;
                      setState(() {
                        _nameController.text = pas.patientName.toString();

                        _mobileController.text = pas.mobileNo.toString();
                      });

                      await nextVisitApi(pas.id!, widget.ditem.id!);
                      visitnoController.text = nextVisitNo.toString();
                    }
                  },
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    showSelectedItems: false,
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      hintText: "Search Patient...",
                      labelText: "Search Patient...",
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

                SizedBox(height: 10),

                CustomTextField(
                  hintText: "Patient Name",
                  controller: _nameController,
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
                  hintText: "Mobile No",
                  controller: _mobileController,
                  filled: true,
                  fillColor: Colors.white,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter mobile no";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                CustomTextField(
                  hintText: "Email",
                  controller: _emailController,
                  filled: true,
                  fillColor: Colors.white,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return "enter patient name";
                  //   }
                  //   return null;
                  // },
                ),

                SizedBox(height: 10),

                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    labelText: "Date Of Birth",
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
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
                      firstDate: DateTime(1930),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        'dd-MM-yyyy',
                      ).format(pickedDate);
                      _dobController.text = formattedDate;
                    }
                  },
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hintText: "Age",
                  controller: ageController,
                  filled: true,
                  fillColor: Colors.white,
                  keyboardType: TextInputType.number,

                  // onChanged: (value) {
                  //   if (value.isEmpty) {
                  //     _dobController.clear();
                  //     return;
                  //   }

                  //   final age = int.tryParse(value);
                  //   if (age != null && age >= 0) {
                  //     _dobController.text = calculateDobFromAge(age);
                  //   }
                  // },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter age";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _sexController.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    labelText: "Sex",
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
                  items: ["Male", "Female"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sexController.text = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select sex" : null,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hintText: "Referred By",
                  controller: _refbyController,
                  filled: true,
                  fillColor: Colors.white,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter referred name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hintText: "Address",
                  controller: _addressController,
                  filled: true,
                  fillColor: Colors.white,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return "enter patient name";
                  //   }
                  //   return null;
                  // },
                ),
                const SizedBox(height: 10),

                DropdownSearch<CategoryListModel>(
                  items: _categoryList,
                  itemAsString: (CategoryListModel p) =>
                      p.lookupValue.toString(),
                  selectedItem: selectedCategory,

                  onChanged: (CategoryListModel? pur) {
                    setState(() {
                      selectedCategory = pur;
                    });
                  },

                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                        ), // এখানে search icon

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    showSelectedItems: false,
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Select category",
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

                  validator: (CategoryListModel? pur) =>
                      pur == null ? "Please select a purpose" : null,
                ),

                const SizedBox(height: 30),

                Visibility(
                  visible: !registrationInProgress,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _emergencyEntry();
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFF0B3E6B),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Submit Registration",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String calculateDobFromAge(int age) {
    final today = DateTime.now();

    DateTime dob = DateTime(today.year - age, today.month, today.day);
    return DateFormat('dd-MM-yyyy').format(dob);
  }

  Future<void> _emergencyEntry() async {
    if (registrationInProgress) return;

    registrationInProgress = true;
    setState(() {});

    Map<String, dynamic> requestBody = {
      "patient_name": _nameController.text.trim(),
      "mobile_no": _mobileController.text.trim(),
      "email": _emailController.text.trim(),
      "dob": _dobController.text.isNotEmpty
          ? DateFormat(
              'yyyy-MM-dd',
            ).format(DateFormat('dd-MM-yyyy').parse(_dobController.text.trim()))
          : "",
      "address": _addressController.text.trim(),
      "sex": _sexController.text.trim(),
      "referred_by": _refbyController.text.trim(),
      "category_id": selectedCategory?.id,
      "appointment_type": widget.keyy,
      "register_patient_id": selectedSeacrchPatient?.id.toString(),
      "visit_no": visitnoController.text.trim(),
      "doctors_id": widget.ditem.id,
      "bu_id": widget.selectedBU?['id']?.toString() ?? "",
    };

    ApiResponse response = await NetworkCaller.postRequest(
      url: Urls.emergencyWalkinUrl,
      body: requestBody,
      token: AuthController.accessToken,
    );

    if (response.isSuccess && response.responseData["status"] == "success") {
      _clearFields();
      Get.back();
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
      registrationInProgress = false;
      setState(() {});
    }
  }

  void _clearFields() {
    _nameController.clear();
    _mobileController.clear();
    _idController.clear();
    _emailController.clear();
    _dobController.clear();
    _sexController.text = "Male";
    _refbyController.text = "Self";
    _addressController.clear();
    setState(() {
      selectedCategory = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _sexController.dispose();
    _refbyController.dispose();

    super.dispose();
  }
}
