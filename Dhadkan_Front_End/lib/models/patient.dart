import 'package:hive/hive.dart';
import 'sync_status.dart';
import 'user.dart';

part 'patient.g.dart';

@HiveType(typeId: 7)
class Patient {
  @HiveField(0)
  final User user;

  @HiveField(1)
  final String uhid;

  @HiveField(2)
  final int? age;

  @HiveField(3)
  final String? gender;

  @HiveField(4)
  final String? disease;

  @HiveField(5)
  final SyncStatus syncStatus;

  Patient({
    required this.user,
    required this.uhid,
    this.age,
    this.gender,
    this.disease,
    this.syncStatus = SyncStatus.pending,
  });

  // -----------------------------
  // 🧠 Convenience getters
  // -----------------------------
  bool get isPending => syncStatus == SyncStatus.pending;
  bool get isSynced => syncStatus == SyncStatus.synced;
  bool get isFailed => syncStatus == SyncStatus.failed;

  // -----------------------------
  // 🔁 copyWith
  // -----------------------------
  Patient copyWith({
    User? user,
    String? uhid,
    int? age,
    String? gender,
    String? disease,
    SyncStatus? syncStatus,
  }) {
    return Patient(
      user: user ?? this.user,
      uhid: uhid ?? this.uhid,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      disease: disease ?? this.disease,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  // -----------------------------
  // 🌐 Backend → App
  // -----------------------------
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      user: User.fromJson(json),
      uhid: json['uhid'] ?? '',
      age: json['age'],
      gender: json['gender'],
      disease: json['diagnosis'],
      syncStatus: SyncStatus.synced,
    );
  }

  // -----------------------------
  // 📦 Local / UI JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      ...user.toJson(),
      'uhid': uhid,
      'age': age,
      'gender': gender,
      'diagnosis': disease,
    };
  }

  // -----------------------------
  // 🔐 Generate default password
  // -----------------------------
  String _generatePatientPassword() {
    final namePart =
        user.name.length >= 4 ? user.name.substring(0, 4) : user.name;
    final mobilePart =
        user.mobile.length >= 4 ? user.mobile.substring(user.mobile.length - 4) : user.mobile;

    return '${namePart.toLowerCase()}$mobilePart';
  }

  // -----------------------------
  // 🚀 App → Backend
  // Matches /doctor/addpatient
  // -----------------------------
  Map<String, dynamic> toApiJson() {
    return {
      'name': user.name,
      'mobile': user.mobile,
      'password': _generatePatientPassword(), // ✅ GENERATED HERE
      'email': user.email,
      'uhid': uhid,
      'age': age,
      'gender': gender,
    };
  }
}
