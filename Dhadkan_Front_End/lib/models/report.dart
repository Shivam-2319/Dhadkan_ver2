import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 8) // ⚠️ UNIQUE across app
class Report {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? patientId;

  @HiveField(2)
  final String? doctorId;

  @HiveField(3)
  final String? reportUrl;

  @HiveField(4)
  final String? createdAt;

  Report({
    this.id,
    this.patientId,
    this.doctorId,
    this.reportUrl,
    this.createdAt,
  });

  // ---------- Backend → App ----------
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      patientId: json['patient'],
      doctorId: json['doctor'],
      reportUrl: json['report'],
      createdAt: json['createdAt'],
    );
  }

  // ---------- App → Backend ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'patient': patientId,
      'doctor': doctorId,
      'report': reportUrl,
      'createdAt': createdAt,
    };
  }
}
