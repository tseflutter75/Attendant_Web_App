import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Appointment%20List/data/models/appointment_list_model.dart';
import 'package:attendantwebapp/features/Working%20List/data/models/vital_single_patient_model.dart';
import 'package:attendantwebapp/features/Working%20List/data/models/voe_multifilter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class VitalPatientInfoEntryScreen extends StatefulWidget {
  final int singlePatientId;
  final AppointmentModel apitem;
  const VitalPatientInfoEntryScreen({
    super.key,
    required this.singlePatientId,
    required this.apitem,
  });

  @override
  State<VitalPatientInfoEntryScreen> createState() =>
      _VitalPatientInfoEntryScreenState();
}

class _VitalPatientInfoEntryScreenState
    extends State<VitalPatientInfoEntryScreen> {
  // String? studentPhotoPath;
  // String? studentPhotoName;

  XFile? studentPhotoPath;
  String? studentPhotoName;
  Uint8List? studentPhotoBytes;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? _calculatedAge; // Added to store calculated age

  // Added GlobalKey for form validation

  bool vitralEntryInProgress = false;

  final List<DocumentEntry> _documentUploadEntries = [];

  final List<Map<String, TextEditingController>> _vitalsRows = [];

  // vital single patient api
  bool vitalsingelPatientnProgress = false;
  VitalSinglePatient? item;
  Future<void> _vitalsinglepatientApi() async {
    vitalsingelPatientnProgress = true;
    setState(() {});
    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.vitalsinglepatientUrl(widget.singlePatientId.toString()),
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      final enquiryJson = response.responseData['data'];

      item = VitalSinglePatient.fromJson(enquiryJson);
      ageCalculator();
    }

    vitalsingelPatientnProgress = false;
    setState(() {});
  }

  // voe multifilter api
  bool voeMultifilterInProgress = false;
  VoeMultiFilterModel? vmitem;
  final List<VoeMultiFilterModel> _voeMultifilterList = [];
  Future<void> _voeMultifilterApi() async {
    voeMultifilterInProgress = true;
    setState(() {});
    ApiResponse response = await NetworkCaller.getRequest(
      url: Urls.voeMultifilterListUrl,
      token: AuthController.accessToken,
    );
    if (!mounted) return;
    if (response.isSuccess && response.responseData['status'] == "success") {
      final Vdata = response.responseData;
      _voeMultifilterList.clear(); // Clear existing data before adding new
      for (Map<String, dynamic> vjson in Vdata['data']) {
        // Assuming 'data' is a list of maps
        final voeModel = VoeMultiFilterModel.fromJson(vjson);
        _voeMultifilterList.add(voeModel);
        _addNewVitalRow(
          name: voeModel.lookupValue ?? '',
          unit: voeModel.other ?? "",
        ); // Assuming VoeMultiFilterModel has a lookupValue property
      }
    }

    voeMultifilterInProgress = false;
    setState(() {});
  }

  // init state fun
  @override
  void initState() {
    super.initState();

    // ইনিশিয়াল একটি ডকুমেন্ট আপলোড রো যোগ করা হলো
    _addNewDocumentEntry();
    _vitalsinglepatientApi();
    _voeMultifilterApi();
  }

  void _addNewVitalRow({String name = "", String unit = ""}) {
    setState(() {
      _vitalsRows.add({
        "name": TextEditingController(text: name),
        "value": TextEditingController(),
        "unit": TextEditingController(text: unit),
      });
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
          "Vital Entry",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: vitalsingelPatientnProgress
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
                      // ১. patient info
                      _buildPatientInfoCard(),
                      const SizedBox(height: 16),

                      // ২.vital table section
                      _buildVitalsTableSection(),
                      const SizedBox(height: 16),

                      // ৩ document section
                      _buildDocumentUploadSection(),
                      const SizedBox(height: 16),

                      // ৪. button save sent to doctor
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

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
          child: Visibility(
            visible: vitralEntryInProgress == false,
            replacement: Center(child: CircularProgressIndicator()),
            child: ElevatedButton(
              onPressed: () async {
                // Made onPressed async
                if (_formKey.currentState!.validate()) {
                  // Corrected validation call
                  await _vitalEntryApi(
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
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
              if (_formKey.currentState!.validate()) {
                // Corrected validation call
                await _vitalEntryApi(
                  "QUEUE",
                ); // Corrected API call and made it awaitable
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0F9F6E),
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
                    separatorBuilder: (context, index) => const SizedBox(),
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
        controller: controller,
        readOnly: true,

        textAlign: textAlign,
        style: const TextStyle(fontSize: 12),

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
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
                        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
                    if (entry.images.isNotEmpty) ...[
                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: entry.images.map((file) {
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
                                    child: FutureBuilder<Uint8List>(
                                      future: file.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 75,
                                            height: 75,
                                            fit: BoxFit.cover,
                                          );
                                        }

                                        if (snapshot.hasError) {
                                          return const SizedBox(
                                            width: 75,
                                            height: 75,
                                            child: Icon(Icons.broken_image),
                                          );
                                        }

                                        return const SizedBox(
                                          width: 75,
                                          height: 75,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
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
                          }).toList(),
                        ),
                      ),

                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: Wrap(
                      //     spacing: 6,
                      //     runSpacing: 6,
                      //     children: entry.images.map((file) {
                      //       return Stack(
                      //         clipBehavior: Clip.none,
                      //         children: [
                      //           Container(
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(8),
                      //               border: Border.all(
                      //                 color: const Color(0xffdbe3ef),
                      //               ),
                      //             ),
                      //             child: ClipRRect(
                      //               borderRadius: BorderRadius.circular(8),
                      //               child: Image.file(
                      //                 File(file.path),
                      //                 width: 75,
                      //                 height: 75,
                      //                 fit: BoxFit.cover,
                      //               ),
                      //             ),
                      //           ),

                      //           /// Remove Image
                      //           Positioned(
                      //             top: -6,
                      //             right: -6,
                      //             child: GestureDetector(
                      //               onTap: () {
                      //                 setState(() {
                      //                   entry.images.remove(file);
                      //                 });
                      //               },
                      //               child: Container(
                      //                 padding: const EdgeInsets.all(4),
                      //                 decoration: const BoxDecoration(
                      //                   color: Colors.red,
                      //                   shape: BoxShape.circle,
                      //                 ),
                      //                 child: const Icon(
                      //                   Icons.close,
                      //                   size: 14,
                      //                   color: Colors.white,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
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

    // Read image bytes for Web compatibility
    final bytes = await pickedFile.readAsBytes();

    setState(() {
      if (isStudentPhoto) {
        studentPhotoPath = pickedFile;
        studentPhotoName = pickedFile.name;
        studentPhotoBytes = bytes;
      }
    });
  }

  // Future<void> openGallery({required bool isStudentPhoto}) async {
  //   final ImageSource? source = await _showImageSourceDialog();
  //   if (source == null) return;

  //   final pickedFile = await ImagePicker().pickImage(
  //     source: source,
  //     imageQuality: 50,
  //     maxWidth: 1024,
  //     maxHeight: 1024,
  //   );

  //   if (pickedFile == null) return;

  //   setState(() {
  //     if (isStudentPhoto) {
  //       studentPhotoPath = pickedFile.path;
  //       studentPhotoName = pickedFile.name;
  //     }
  //   });
  // }

  final Map<String, String> docTypeMap = {
    'Investigation': 'Investigation',
    'Pre-Procedure Documents': 'Pre-Procedure',
    'Post-Procedure Documents': 'Post-Procedure',
    'Others': 'Others',
  };

  void ageCalculator() {
    if (item?.dob == null || item!.dob!.isEmpty) {
      debugPrint("DOB is null or empty");
      return;
    }

    try {
      DateTime? dob;
      String dobStr = item!.dob!;

      // Try parsing with multiple formats to handle different API responses
      try {
        dob = DateTime.parse(dobStr);
      } catch (_) {
        try {
          dob = DateFormat("dd-MM-yyyy").parse(dobStr);
        } catch (_) {
          dob = DateFormat("yyyy-MM-dd").parse(dobStr);
        }
      }

      DateTime today = DateTime.now();
      int age = today.year - dob.year;

      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      setState(() {
        _calculatedAge = age;
      });
    } catch (e) {
      debugPrint("Error calculating age: $e");
    }
  }

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);

  // vital entry post api...
  Future<void> _vitalEntryApi(String saveSentStatus) async {
    if (vitralEntryInProgress) return;

    vitralEntryInProgress = true;

    // Ensure age is calculated before sending if it hasn't been set yet
    if (_calculatedAge == null && item?.dob != null) {
      ageCalculator();
    }

    setState(() {});

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Urls.vitalEntryUrl),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${AuthController.accessToken}',
        'Accept': 'application/json',
      });

      request.fields['payloadPatientInfo'] = jsonEncode({
        "visit_date": formattedDate,
        "doctors_id": widget.apitem.doctorsId,
        "age": _calculatedAge ?? 0,
        "patient_id": widget.apitem.registerPatientId,
        "pr_status": saveSentStatus,
        "visit_no": widget.apitem.visitNo,
        "appointment_id": widget.apitem.id,
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
      print("hellooo");
      print(widget.apitem.visitNo);

      for (int i = 0; i < _documentUploadEntries.length; i++) {
        // / ১. ম্যাপ থেকে আসল ভ্যালু (যেমন: 'Pre-Procedure') বের করা হচ্ছে
        final value =
            docTypeMap[_documentUploadEntries[i].docType] ??
            _documentUploadEntries[i].docType;

        // ২. রিকোয়েস্ট ফিল্ডে এই পরিবর্তিত value-টি অ্যাসাইন করা হলো (যা আগে মিসিং ছিল)
        request.fields['payloadDocument[$i][docType]'] = value;

        debugPrint("DocType Sent: $value");

        for (int j = 0; j < _documentUploadEntries[i].images.length; j++) {
          final file = _documentUploadEntries[i].images[j];
          final bytes = await file.readAsBytes();

          request.files.add(
            http.MultipartFile.fromBytes(
              'payloadDocument[$i][files][$j]',
              bytes,
              filename: file.name,
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
                responseData['message'] ?? "Entry Successful",
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
        throw Exception(responseData['message'] ?? "Failed to save vitals");
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
      vitralEntryInProgress = false;
      setState(() {});
    }
  }
}

//   Future<void> _vitalEntryApi(String saveSentStatus) async {
//     if (vitralEntryInProgress) return;

//     vitralEntryInProgress = true;

//     // Ensure age is calculated before sending if it hasn't been set yet
//     if (_calculatedAge == null && item?.dob != null) {
//       ageCalculator();
//     }

//     setState(() {});

//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(Urls.vitalEntryUrl),
//       );

//       request.headers.addAll({
//         'Authorization': 'Bearer ${AuthController.accessToken}',
//         'Accept': 'application/json',
//       });

//       request.fields['payloadPatientInfo'] = jsonEncode({
//         "visit_date": formattedDate,
//         "doctors_id": widget.apitem.doctorsId,
//         "age": _calculatedAge ?? 0,
//         "patient_id": widget.apitem.registerPatientId,
//         "pr_status": saveSentStatus,
//         "visit_no": widget.apitem.visitNo,
//         "appointment_id": widget.apitem.id,
//       });

//       request.fields['payloadvital'] = jsonEncode(
//         _vitalsRows
//             .map(
//               (row) => {
//                 "vital_name": row["name"]?.text ?? "",
//                 "vital_value": row["value"]?.text ?? "",
//                 "vital_unit": row["unit"]?.text ?? "",
//               },
//             )
//             .toList(),
//       );

//       for (int i = 0; i < _documentUploadEntries.length; i++) {
//         // / ১. ম্যাপ থেকে আসল ভ্যালু (যেমন: 'Pre-Procedure') বের করা হচ্ছে
//         final value =
//             docTypeMap[_documentUploadEntries[i].docType] ??
//             _documentUploadEntries[i].docType;

//         // ২. রিকোয়েস্ট ফিল্ডে এই পরিবর্তিত value-টি অ্যাসাইন করা হলো (যা আগে মিসিং ছিল)
//         request.fields['payloadDocument[$i][docType]'] = value;

//         debugPrint("DocType Sent: $value");
//         for (int j = 0; j < _documentUploadEntries[i].images.length; j++) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'payloadDocument[$i][files][$j]',
//               _documentUploadEntries[i].images[j].path,
//             ),
//           );
//         }
//       }

//       // ==================== [DEBUG PRINT START] ====================
//       debugPrint("====== REQUEST PAYLOAD ======");
//       debugPrint("API URL: ${request.url}");
//       debugPrint("Headers: ${request.headers}");

//       // Fields প্রিন্ট করার জন্য
//       request.fields.forEach((key, value) {
//         debugPrint("Field Key: $key");
//         try {
//           // JSON স্ট্রিং হলে তা সুন্দরভাবে (pretty print) দেখানোর জন্য
//           var decoded = jsonDecode(value);
//           var prettyJson = const JsonEncoder.withIndent('  ').convert(decoded);
//           debugPrint("Field Value (JSON):\n$prettyJson");
//         } catch (e) {
//           // সাধারণ টেক্সট হলে সরাসরি প্রিন্ট করবে
//           debugPrint("Field Value: $value");
//         }
//         debugPrint("-----------------------------------");
//       });

//       // Files প্রিন্ট করার জন্য
//       debugPrint("Total Files to Upload: ${request.files.length}");
//       for (var file in request.files) {
//         debugPrint("File Field Key: ${file.field}");
//         debugPrint("File Name: ${file.filename}");
//         debugPrint("File Size: ${file.length} bytes");
//         debugPrint("-----------------------------------");
//       }
//       debugPrint("===============================================");
//       // ==================== [DEBUG PRINT END] ====================

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       debugPrint("Response Status: ${response.statusCode}");
//       debugPrint("Response Body: ${response.body}");

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200 && responseData["status"] == "success") {
//         Get.back(result: true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             duration: const Duration(seconds: 2),
//             backgroundColor: const Color(0xFF0B3E6B),
//             content: Center(
//               child: Text(
//                 responseData['message'] ?? "Entry Successful",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         );
//       } else {
//         throw Exception(responseData['message'] ?? "Failed to save vitals");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           duration: const Duration(seconds: 2),
//           backgroundColor: Colors.red,
//           content: Center(
//             child: Text(
//               e.toString(),
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     if (mounted) {
//       vitralEntryInProgress = false;
//       setState(() {});
//     }
//   }
// }

// Represents a single document entry
class DocumentEntry {
  String docType;
  List<XFile> images; // Changed from String? filePath and String? fileName

  DocumentEntry({required this.docType, List<XFile>? images})
    : this.images = images ?? [];
}
