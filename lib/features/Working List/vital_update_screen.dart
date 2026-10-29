import 'dart:convert';
import 'dart:io';

import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Appointment%20List/data/models/appointment_list_model.dart';
import 'package:attendantwebapp/features/Working%20List/data/models/vital_editauto_fieldataapi_model.dart';
import 'package:attendantwebapp/features/Working%20List/data/models/vital_single_patient_model.dart';
import 'package:attendantwebapp/features/Working%20List/data/models/voe_multifilter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class VitalPatientInfoUpdateScreen extends StatefulWidget {
  final AppointmentModel dataitem;
  const VitalPatientInfoUpdateScreen({super.key, required this.dataitem});

  @override
  State<VitalPatientInfoUpdateScreen> createState() =>
      _VitalPatientInfoUpdateScreenState();
}

class _VitalPatientInfoUpdateScreenState
    extends State<VitalPatientInfoUpdateScreen> {
  String? studentPhotoPath;
  String? studentPhotoName;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added GlobalKey for form validation

  bool vitalUpdateInProgress = false;

  final List<DocumentEntry> _documentUploadEntries = [];

  final List<Map<String, TextEditingController>> _vitalsRows = [];

  final List<VoeMultiFilterModel> _voeMultifilterList = [];

  // vital single patient api
  bool vitalsingelPatientnProgress = false;
  VitalSinglePatient? item;
  Future<void> _vitalsinglepatientApi() async {
    vitalsingelPatientnProgress = true;
    setState(() {});
    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.vitalsinglepatientUrl(
        widget.dataitem.registerPatientId.toString(),
      ),
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      final enquiryJson = response.responseData['data'];

      item = VitalSinglePatient.fromJson(enquiryJson);
    }

    vitalsingelPatientnProgress = false;
    setState(() {});
  }

  // api 2.......................................................
  // prescribtion document
  bool vitalautoeditfieldInProgress = false;
  PrescriptionDocument? vddataitem;

  Future<void> _vitalEditAutoFieldDataApi() async {
    vitalautoeditfieldInProgress = true;
    setState(() {});

    // 1. Fetch VOE multifilter list (Master list of vitals)
    ApiResponse voeResponse = await NetworkCaller.getRequest(
      url: Urls.voeMultifilterListUrl,
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (voeResponse.isSuccess &&
        voeResponse.responseData['status'] == "success") {
      final vData = voeResponse.responseData;
      _vitalsRows.clear();
      _voeMultifilterList.clear();
      for (Map<String, dynamic> vjson in vData['data']) {
        final voeModel = VoeMultiFilterModel.fromJson(vjson);
        _voeMultifilterList.add(voeModel);
        _addNewVitalRow(
          name: voeModel.lookupValue ?? '',
          unit: voeModel.other ?? '',
        );
      }
    }

    // 2. Fetch Existing Patient Vital Data
    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.vitalEditAutoFieldDataUrl(
        widget.dataitem.prPatientId!.toString(),
      ),
      token: AuthController.accessToken,
    );

    if (response.isSuccess && response.responseData['status'] == "success") {
      final data = response.responseData['data'];
      vddataitem = PrescriptionDocument.fromJson(data);

      // Handle Documents (Images) from API
      List docsList = data['pr_document'] ?? [];
      if (docsList.isNotEmpty) {
        _documentUploadEntries
            .clear(); // Clear the default entry added in initState
        Map<String, List<Map<String, dynamic>>> groupedDocs = {};
        for (var doc in docsList) {
          String rawType = doc['doc_type'] ?? 'Others';
          String type = 'Others';

          // Map API doc_type strings to match your Dropdown values exactly
          if (rawType == 'Investigation') {
            type = 'Investigation';
          } else if (rawType == 'Pre-Procedure') {
            type = 'Pre-Procedure Documents';
          } else if (rawType == 'Post-Procedure') {
            type = 'Post-Procedure Documents';
          } else if (rawType == 'Others') {
            type = 'Others';
          }

          String url = doc['doc_file'] ?? '';
          if (url.isNotEmpty) {
            groupedDocs.putIfAbsent(type, () => []).add({
              'url': url,
              'id': doc['id'],
            });
          }
        }

        groupedDocs.forEach((type, docs) {
          _documentUploadEntries.add(
            DocumentEntry(
              docType: type,
              remoteImages: docs.map((e) => e['url'] as String).toList(),
              remoteImageIds: docs.map((e) => e['id'] as int).toList(),
            ),
          );
        });
      }

      List vitalsList = data['pr_oe_vitals'] ?? [];

      // 3. Merge saved values into the master list rows
      for (var savedVital in vitalsList) {
        String sName = savedVital['vital_name'] ?? '';
        String sValue = savedVital['vital_value'] ?? '';
        String sUnit = savedVital['vital_unit'] ?? '';

        // Try to find a row already created from the VOE template
        int existingIndex = _vitalsRows.indexWhere(
          (row) => row['name']?.text.trim() == sName.trim(),
        );

        if (existingIndex != -1) {
          // Update the controllers of the existing row
          _vitalsRows[existingIndex]['value']?.text = sValue;
          _vitalsRows[existingIndex]['unit']?.text = sUnit;
        } else {
          // If for some reason it's not in VOE but has data, add it as a new row
          _addNewVitalRow(name: sName, value: sValue, unit: sUnit);
        }
      }
    }

    vitalautoeditfieldInProgress = false;
    setState(() {});
  }

  // init state fun
  @override
  void initState() {
    super.initState();

    // ইনিশিয়াল একটি ডকুমেন্ট আপলোড রো যোগ করা হলো
    _addNewDocumentEntry();
    _vitalsinglepatientApi();

    _vitalEditAutoFieldDataApi();
  }

  void _addNewVitalRow({
    String name = "",
    String value = "",
    String unit = "",
  }) {
    setState(() {
      _vitalsRows.add({
        "name": TextEditingController(text: name),
        "value": TextEditingController(text: value),
        "unit": TextEditingController(text: unit),
      });
    });
  }

  void _addNewDocumentEntry() {
    setState(() {
      _documentUploadEntries.add(
        DocumentEntry(docType: 'Investigation'),
      ); // Default type
    });
  }

  void _removeDocumentEntry(int index) {
    setState(() {
      _documentUploadEntries.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var row in _vitalsRows) {
      row["name"]?.dispose();
      row["value"]?.dispose();
      row["unit"]?.dispose();
    }
    // DocumentEntry ক্লাস TextEditingController ধারণ করে না, তাই এখানে ডিসপোজ করার প্রয়োজন নেই।
    super.dispose();
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
          "Vital Update",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: (vitalsingelPatientnProgress || vitalautoeditfieldInProgress)
            ? const Center(child: CircularProgressIndicator())
            : item == null
            ? const Center(child: Text("No patient data found"))
            : Form(
                // Wrapped with Form widget
                key: _formKey, // Assigned the GlobalKey
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ১. পেশেন্ট ইনফো সেকশন
                      _buildPatientInfoCard(),
                      const SizedBox(height: 16),

                      // ২. ভাইটালস টেবিল/লিস্ট সেকশন
                      _buildVitalsTableSection(),
                      const SizedBox(height: 16),

                      // ৩. ডকুমেন্ট আপলোডার সেকশন
                      _buildDocumentUploadSection(),
                      const SizedBox(height: 16),

                      // ৪. বটম অ্যাকশন বাটনস
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --- উইজেট বিল্ডার ফাংশনসমূহ ---

  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF0B3E6B)),
      ),

      child: Column(
        children: [
          Row(
            children: [
              _buildInfoItem(
                "Patient ID",
                item!.patientId.toString(),
                isBold: true,
              ),
              const SizedBox(width: 20),

              _buildInfoItem(
                "Patient Name",
                item!.patientName.toString(),
                isBold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // part 2
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Save বাটন
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // Made onPressed async
              if (_formKey.currentState!.validate()) {
                // Corrected validation call
                await _vitalUpdateApi(
                  "OE",
                ); // Corrected API call and made it awaitable
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0B3E6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Update",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Send To Doctor বাটন
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () async {
              await _vitalUpdateApi("QUEUE");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0F9F6E), // গ্রিন কালার
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Send To Doctor",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3 part o/e vitals table....................................................................................................................
  Widget _buildVitalsTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF0B3E6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // টেবিল হেডার
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xffeef2f7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                SizedBox(width: 45),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Vitals",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e3a8a),
                    ),
                  ),
                ),
                SizedBox(width: 50),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Value",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e3a8a),
                    ),
                  ),
                ),
                SizedBox(width: 50),

                Expanded(
                  flex: 2,
                  child: Text(
                    "Unit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e3a8a),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ডাইনামিক রো লিস্ট
          _vitalsRows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No O/E Vitals recorded.")),
                )
              : SizedBox(
                  height: 190,
                  child: ListView.separated(
                    // shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: _vitalsRows.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xffedf2f7)),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          children: [
                            // O/E Vital Name input
                            Expanded(
                              flex: 3,
                              child: _buildTableForVitalsTextField(
                                _vitalsRows[index]["name"]!,
                                "Enter Vital",
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Value input
                            Expanded(
                              flex: 2,
                              child: _buildTableForValueTextField(
                                _vitalsRows[index]["value"]!,
                                "-",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Unit input
                            Expanded(
                              flex: 2,
                              child: _buildTableForUnitTextField(
                                _vitalsRows[index]["unit"]!,
                                "-",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTableForVitalsTextField(
    TextEditingController controller,
    String hint, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return SizedBox(
      height: 34,
      child: TextField(
        readOnly: true,
        controller: controller,
        textAlign: textAlign,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.grey.shade200,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffcbd5e1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffe2e8f0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xff0052cc), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTableForValueTextField(
    TextEditingController controller,
    String hint, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,

        textAlign: textAlign,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffcbd5e1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffe2e8f0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xff0052cc), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTableForUnitTextField(
    TextEditingController controller,
    String hint, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlign: textAlign,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.grey.shade200,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffcbd5e1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffe2e8f0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xff0052cc), width: 1.5),
          ),
        ),
      ),
    );
  }

  // 4 document section........................................................................................
  Widget _buildDocumentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF0B3E6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upload Document",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1e3a8a),
                ),
              ),

              /// Add Row Button
              SizedBox(
                height: 30,
                width: 30,
                child: ElevatedButton(
                  onPressed: () => _addNewDocumentEntry(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    backgroundColor: Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.add_rounded, size: 24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Empty State
          if (_documentUploadEntries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xfff8fafc),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffe2e8f0)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    size: 38,
                    color: Color(0xff94a3b8),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No documents added yet",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff64748b),
                    ),
                  ),
                ],
              ),
            ),

          /// List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _documentUploadEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              DocumentEntry entry = _documentUploadEntries[index];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Delete Button Left
                        Container(
                          height: 46,
                          width: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xfffff1f2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () => _removeDocumentEntry(index),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Dropdown
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffcbd5e1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: entry.docType,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),

                                items: docTypeMap.keys.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    entry.docType = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// Upload Button Right
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                final ImageSource? source =
                                    await _showImageSourceDialog();
                                if (source == null) return;

                                if (source == ImageSource.gallery) {
                                  final List<XFile> selectedImages =
                                      await ImagePicker().pickMultiImage(
                                        imageQuality: 50,
                                        maxWidth: 1024,
                                        maxHeight: 1024,
                                      );
                                  if (selectedImages.isNotEmpty) {
                                    setState(() {
                                      entry.images.addAll(selectedImages);
                                    });
                                  }
                                } else {
                                  final XFile? image = await ImagePicker()
                                      .pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 50,
                                        maxWidth: 1024,
                                        maxHeight: 1024,
                                      );
                                  if (image != null) {
                                    setState(() => entry.images.add(image));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Color(0xFF1E40AF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// Images Preview
                    if (entry.images.isNotEmpty ||
                        entry.remoteImages.isNotEmpty) ...[
                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Display Remote Images (From Server)
                            ...entry.remoteImages.map((url) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xffdbe3ef),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        url,
                                        width: 75,
                                        height: 75,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 20,
                                                ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          int idx = entry.remoteImages.indexOf(
                                            url,
                                          );
                                          if (idx != -1) {
                                            entry.remoteImageIds.removeAt(idx);
                                            entry.remoteImages.removeAt(idx);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            // Display Local Images (Newly Picked)
                            ...entry.images.map((file) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xffdbe3ef),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path),
                                        width: 75,
                                        height: 75,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  /// Remove Image
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          entry.images.remove(file);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
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
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // image gallery
  Future<void> openGallery({required bool isStudentPhoto}) async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile == null) return;

    setState(() {
      if (isStudentPhoto) {
        studentPhotoPath = pickedFile.path;
        studentPhotoName = pickedFile.name;
      }
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, String> docTypeMap = {
    'Investigation': 'Investigation',
    'Pre-Procedure Documents': 'Pre-Procedure',
    'Post-Procedure Documents': 'Post-Procedure',
    'Others': 'Others',
  };

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);

  // vital update post api...
  Future<void> _vitalUpdateApi(String saveSentStatus) async {
    if (vitalUpdateInProgress) return;

    vitalUpdateInProgress = true;
    setState(() {});

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Urls.vitalEditUrl(widget.dataitem.prPatientId.toString())),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${AuthController.accessToken}',
        'Accept': 'application/json',
      });

      request.fields['payloadPatientInfo'] = jsonEncode({
        "visit_date": formattedDate,
        "doctors_id": widget.dataitem.doctorsId,
        "age": vddataitem?.age?.toString() ?? "",
        "patient_id": widget.dataitem.registerPatientId,
        "pr_status": saveSentStatus,
        "visit_no": widget.dataitem.visitNo,
        "appointment_id": widget.dataitem.id,
      });

      request.fields['payloadvital'] = jsonEncode(
        _vitalsRows
            .map(
              (row) => {
                "vital_name": row["name"]?.text ?? "",
                "vital_value": row["value"]?.text ?? "",
                "vital_unit": row["unit"]?.text ?? "",
              },
            )
            .toList(),
      );

      for (int i = 0; i < _documentUploadEntries.length; i++) {
        // / ১. ম্যাপ থেকে আসল ভ্যালু (যেমন: 'Pre-Procedure') বের করা হচ্ছে
        final value =
            docTypeMap[_documentUploadEntries[i].docType] ??
            _documentUploadEntries[i].docType;

        // ২. রিকোয়েস্ট ফিল্ডে এই পরিবর্তিত value-টি অ্যাসাইন করা হলো (যা আগে মিসিং ছিল)
        request.fields['payloadDocument[$i][docType]'] = value;

        debugPrint("DocType Sent: $value");
        // Include existing remote image URLs so they are maintained on the server
        for (
          int j = 0;
          j < _documentUploadEntries[i].remoteImages.length;
          j++
        ) {
          request.fields['payloadDocument[$i][existing_ids][$j]'] =
              _documentUploadEntries[i].remoteImageIds[j].toString();
        }

        for (int j = 0; j < _documentUploadEntries[i].images.length; j++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'payloadDocument[$i][files][$j]',
              _documentUploadEntries[i].images[j].path,
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        Get.back(result: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF0B3E6B),
            content: Center(
              child: Text(
                responseData['message'] ?? "Update Successful",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? "Failed to update vitals");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              e.toString(),
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

    if (mounted) {
      vitalUpdateInProgress = false;
      setState(() {});
    }
  }
}

// Represents a single document entry
class DocumentEntry {
  String docType;
  List<XFile> images;
  List<String> remoteImages;
  List<int> remoteImageIds; // আগের ইমেজের আইডি সেভ রাখার জন্য

  DocumentEntry({
    required this.docType,
    List<XFile>? images,
    List<String>? remoteImages,
    List<int>? remoteImageIds,
  }) : this.images = images ?? [],
       this.remoteImages = remoteImages ?? [],
       this.remoteImageIds = remoteImageIds ?? [];
}
