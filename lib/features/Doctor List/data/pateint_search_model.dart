class PatientModelSearch {
  final int? id;
  final String? patientId;
  final String? patientName;
  final String? mobileNo;

  const PatientModelSearch({
    this.id,
    this.patientId,
    this.patientName,
    this.mobileNo,
  });

  factory PatientModelSearch.fromJson(Map<String, dynamic> json) {
    return PatientModelSearch(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      mobileNo: json['mobile_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'mobile_no': mobileNo,
    };
  }
}
