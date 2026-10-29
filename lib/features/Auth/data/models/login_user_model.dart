class UserModel {
  final int? id;
  final String? userName;
  final String? fullName;
  final String? email;
  final String? mobileNo;

  UserModel({this.id, this.userName, this.fullName, this.email, this.mobileNo});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      userName: json['user_name']?.toString() ?? "",
      fullName: json['full_name']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      mobileNo: json['mobile_no']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'full_name': fullName,
      'email': email,
      'mobile_no': mobileNo,
    };
  }
}
