class PrescriptionDocument {
  final int? id;
  final String? visitDate;
  final String? visitId;
  final int? doctorsId;
  final int? age;
  final int? patientId;
  final String? drugHistory;
  final String? note;
  final String? plan;
  final String? nextVisitTime;
  final String? nextVisitDate;
  final dynamic paymentAmount;
  final String? visitNo;
  final String? visitType;
  final String? ho;
  final String? dx;
  final String? prStatus;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic>? prOeVitals;

  PrescriptionDocument({
    this.id,
    this.visitDate,
    this.visitId,
    this.doctorsId,
    this.age,
    this.patientId,
    this.drugHistory,
    this.note,
    this.plan,
    this.nextVisitTime,
    this.nextVisitDate,
    this.paymentAmount,
    this.visitNo,
    this.visitType,
    this.ho,
    this.dx,
    this.prStatus,
    this.createdAt,
    this.updatedAt,
    this.prOeVitals,
  });

  factory PrescriptionDocument.fromJson(Map<String, dynamic> json) {
    return PrescriptionDocument(
      id: json['id'],
      visitDate: json['visit_date'],
      visitId: json['visit_id'],
      doctorsId: json['doctors_id'],
      age: json['age'],
      patientId: json['patient_id'],
      drugHistory: json['drug_history'],
      note: json['note'],
      plan: json['plan'],
      nextVisitTime: json['next_visit_time'],
      nextVisitDate: json['next_visit_date'],
      paymentAmount: json['payment_amount'],
      visitNo: json['visit_no'],
      visitType: json['visit_type'],
      ho: json['ho'],
      dx: json['dx'],
      prStatus: json['pr_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      prOeVitals: json['pr_oe_vitals'],
    );
  }
}
