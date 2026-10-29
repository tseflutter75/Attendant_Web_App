class NextVisitModel {
  final int? nextVisit;

  NextVisitModel({this.nextVisit});

  factory NextVisitModel.fromJson(Map<String, dynamic> json) {
    return NextVisitModel(nextVisit: json['next_visit_no']);
  }
}
