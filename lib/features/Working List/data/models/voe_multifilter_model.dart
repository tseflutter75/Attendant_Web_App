class VoeMultiFilterModel {
  final int? id;
  final String? lookupValue;
  final String? lookupCode;
  final int? prLookupTypeId;
  final int? doctorsId;
  final int? slNo;
  final String? other;
  final int? isActive;
  final int? createdBy;

  VoeMultiFilterModel({
    this.id,
    this.lookupValue,
    this.lookupCode,
    this.prLookupTypeId,
    this.doctorsId,
    this.other,
    this.slNo,
    this.isActive,
    this.createdBy,
  });

  factory VoeMultiFilterModel.fromJson(Map<String, dynamic> json) {
    return VoeMultiFilterModel(
      id: json['id'] ?? 0,
      lookupValue: json['lookup_value'] ?? "",
      lookupCode: json['lookup_code'] ?? "",
      prLookupTypeId: json['pr_lookup_type_id'] ?? 0,
      doctorsId: json['doctors_id'] ?? 0,
      slNo: json['sl_no'] ?? 0,
      isActive: json['is_active'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      other: json['others'] ?? "",
    );
  }
}
