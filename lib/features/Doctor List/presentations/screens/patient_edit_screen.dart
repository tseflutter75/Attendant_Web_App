import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Doctor_patient/data/models/category_list_model.dart';
import 'package:attendantwebapp/features/Doctor%20List/data/patient_list_model.dart';
import 'package:attendantwebapp/features/Common/presentation/widgets/custom_textfeild.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PatientEditScreen extends StatefulWidget {
  final PatientModel item;

  const PatientEditScreen({super.key, required this.item});

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
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

      if (_categoryList.isNotEmpty) {
        try {
          selectedCategory = _categoryList.firstWhere(
            (element) => element.id == widget.item.categoryId,
          );
        } catch (e) {}
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

  @override
  void initState() {
    super.initState();

    // widget.item থেকে ডেটা কন্ট্রোলারগুলোতে বসানো হচ্ছে
    _nameController.text = widget.item.patientName ?? "";
    _mobileController.text = widget.item.mobileNo ?? "";
    _emailController.text = widget.item.email ?? "";

    // তারিখ ফরম্যাট কনভার্ট করা (Server yyyy-MM-dd -> UI dd-MM-yyyy)
    if (widget.item.dob != null && widget.item.dob!.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(widget.item.dob!);
        _dobController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        _dobController.text = widget.item.dob!;
      }
    }

    _sexController.text = widget.item.sex ?? "Male";
    _refbyController.text = widget.item.referredBy ?? "Self";
    _addressController.text = widget.item.address ?? "";
    _idController.text = widget.item.patientId?.toString() ?? "";

    _categoryListApi();
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
          "Edit Patient",
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
                CustomTextField(
                  hintText: "Patient Name",
                  filled: true,
                  fillColor: Colors.white,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter patient name";
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
                    FilteringTextInputFormatter
                        .digitsOnly, // শুধু নাম্বার ইনপুট নিতে
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter mobile no";
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
                    labelText: "Date of Birth",
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
                      lastDate: DateTime(2050),
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
                      return "Enter referrer name";
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
                        filled: true,
                        fillColor: Colors.white,

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
                        _patientEdit();
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
                      "Update Patient",
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

  Future<void> _patientEdit() async {
    if (registrationInProgress) return;

    registrationInProgress = true;
    setState(() {});

    Map<String, dynamic> requestBody = {
      "patient_name": _nameController.text.trim(),
      "mobile_no": _mobileController.text.trim(),
      "patient_id_no": _idController.text.trim(),
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
    };

    ApiResponse response = await NetworkCaller.postRequest(
      url: Urls.patientEditUrl(widget.item.id.toString()),
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
