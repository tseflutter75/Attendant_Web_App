class AppointmentModel {
  final int id;
  final int doctorsId;
  final String registrationType;
  final String appointmentType;
  final String visitNo;
  final String patientType;
  final String appointmentDate;
  final String appointmentTime;
  final String dayName;
  final String shiftName;
  final int slotNo;
  final int scheduleId;
  final String patientName;
  final String mobileNo;
  final String status;
  final int buId;
  final int? registerPatientId;
  final int? prPatientId;
  final String arrivedTime;

  AppointmentModel({
    required this.id,
    required this.doctorsId,
    required this.registrationType,
    required this.appointmentType,
    required this.visitNo,
    required this.patientType,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.dayName,
    required this.shiftName,
    required this.slotNo,
    required this.scheduleId,
    required this.patientName,
    required this.mobileNo,
    required this.status,
    required this.buId,
    this.registerPatientId,
    this.prPatientId,
    required this.arrivedTime,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      doctorsId: json['doctors_id'] ?? 0,
      registrationType: json['registration_type'] ?? "",
      appointmentType: json['appointment_type'] ?? "",
      visitNo: json['visit_no']?.toString() ?? "",
      patientType: json['patient_type'] ?? "",
      appointmentDate: json['appointment_date'] ?? "",
      appointmentTime: json['appointment_time'] ?? "",
      dayName: json['day_name'] ?? "",
      shiftName: json['shift_name'] ?? "",
      slotNo: json['slot_no'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      patientName: json['patient_name'] ?? "",
      mobileNo: json['mobile_no'] ?? "",
      status: json['status'] ?? "",
      buId: json['bu_id'] ?? 0,
      registerPatientId: json['register_patient_id'] ?? 0,
      prPatientId: json['pr_patient_id'],
      arrivedTime: json['arrived_time'] ?? "",
    );
  }
}
