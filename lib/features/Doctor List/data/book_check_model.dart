class BookChecked {
  final String? patientName;
  final int? scheduleId;
  final int? slotNo;
  final String? status;

  BookChecked({this.patientName, this.scheduleId, this.slotNo, this.status});

  factory BookChecked.fromJson(Map<String, dynamic> json) {
    return BookChecked(
      patientName: json['patient_name'] ?? "",
      scheduleId: json['schedule_id'] ?? 0,
      slotNo: json['slot_no'] ?? 0,
      status: json['status'] ?? "",
    );
  }
}
