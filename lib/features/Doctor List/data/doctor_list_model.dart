class DoctorListModel {
  final int? id;
  final String? image;
  final String? doctorName;

  final List<Map<String, dynamic>>? businessUnits;
  final List<Map<String, dynamic>>? degrees;
  final Map<String, dynamic>? speciality;

  DoctorListModel({
    this.id,
    this.doctorName,
    this.businessUnits,
    this.degrees,
    this.speciality,
    this.image,
  });

  factory DoctorListModel.fromJson(Map<String, dynamic> json) {
    return DoctorListModel(
      id: json['id'],
      image: json['image'],
      doctorName: json['doctor_name'],

      businessUnits: json['business_units'] != null
          ? List<Map<String, dynamic>>.from(json['business_units'])
          : [],

      degrees: json['degrees'] != null
          ? List<Map<String, dynamic>>.from(json['degrees'])
          : [],

      speciality: json['speciality'] != null
          ? Map<String, dynamic>.from(json['speciality'])
          : null,
    );
  }
}
