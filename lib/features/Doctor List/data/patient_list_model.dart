class PatientModel {
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

  PatientModel({
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

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      patientId: json['patient_id']?.toString(),
      patientName: json['patient_name']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      email: json['email']?.toString(),
      dob: json['dob']?.toString(),
      sex: json['sex']?.toString(),
      address: json['address']?.toString(),
      referredBy: json['referred_by']?.toString(),
      categoryId: json['category_id'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),

      categoryModelId: json['category']?['id'],
      lookupValue: json['category']?['lookup_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'mobile_no': mobileNo,
      'email': email,
      'dob': dob,
      'sex': sex,
      'address': address,
      'referred_by': referredBy,
      'category_id': categoryId,
      'created_at': createdAt,
      'updated_at': updatedAt,

      'category': {'id': categoryModelId, 'lookup_value': lookupValue},
    };
  }
}
