// lib/models/admin_model.dart
class AdminModel {
  final int adminId;
  final String name;
  final String contact;
  final String password;

  AdminModel({
    required this.adminId,
    required this.name,
    required this.contact,
    required this.password,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json['admin_id'] is int ? json['admin_id'] : int.tryParse(json['admin_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'admin_id': adminId,
        'name': name,
        'contact': contact,
        'password': password,
      };
}
