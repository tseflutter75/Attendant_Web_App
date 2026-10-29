class DoctorScheduleModel {
  final int? id;
  final int? doctorsId;
  final int? buId;
  final int? consultationTime;
  final String? days;
  final String? shiftName;
  final String? timeFrom;
  final String? timeTo;
  final int? slotNumber;
  final List<Map<String, dynamic>>? slotDetails;
  final int? consultationFee;
  final int? followupFee;
  final int? withinDay;
  final dynamic vat;
  final int? vatIncluded;
  final int? status;

  DoctorScheduleModel({
    this.id,
    this.doctorsId,
    this.buId,
    this.consultationTime,
    this.days,
    this.shiftName,
    this.timeFrom,
    this.timeTo,
    this.slotNumber,
    this.slotDetails,
    this.consultationFee,
    this.followupFee,
    this.withinDay,
    this.vat,
    this.vatIncluded,
    this.status,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: json['id'],
      doctorsId: json['doctors_id'],
      buId: json['bu_id'],
      consultationTime: json['consultation_time'],
      days: json['days'],
      shiftName: json['shift_name'],
      timeFrom: json['time_from'],
      timeTo: json['time_to'],
      slotNumber: json['slot_number'],
      slotDetails: (json['slot_details'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      consultationFee: json['consultation_fee'],
      followupFee: json['followup_fee'],
      withinDay: json['within_day'],
      vat: json['vat'],
      vatIncluded: json['vat_included'],
      status: json['status'],
    );
  }
}
