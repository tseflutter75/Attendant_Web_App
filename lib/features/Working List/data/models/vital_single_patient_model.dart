class VitalSinglePatient {
  final int? id;
  final String? patientId;
  final String? patientName;
  final String? mobileNo;
  final String? email;
  final String? dob;
  final String? sex;
  final String? address;
  final String? referredBy;
  final int? categoryId;
  final String? createdAt;
  final String? updatedAt;

  // Category
  final int? categoryModelId;
  final String? lookupValue;

  VitalSinglePatient({
    this.id,
    this.patientId,
    this.patientName,
    this.mobileNo,
    this.email,
    this.dob,
    this.sex,
    this.address,
    this.referredBy,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.categoryModelId,
    this.lookupValue,
  });

  factory VitalSinglePatient.fromJson(Map<String, dynamic> json) {
    return VitalSinglePatient(
      id: json['id'] ?? 0,
      patientId: json['patient_id'].toString(),
      patientName: json['patient_name'] ?? "",
      mobileNo: json['mobile_no'] ?? "",
      email: json['email'] ?? "",
      dob: json['dob'] ?? "",
      sex: json['sex'] ?? "",
      address: json['address'] ?? "",
      referredBy: json['referred_by'] ?? "",
      categoryId: json['category_id'] ?? 0,
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",

      categoryModelId: json['category']?['id'] ?? 0,
      lookupValue: json['category']?['lookup_value'] ?? "",
    );
  }
}
