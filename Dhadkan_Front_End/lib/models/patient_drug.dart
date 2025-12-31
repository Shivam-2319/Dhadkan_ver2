// import 'medicine.dart';

// class PatientDrug {
//   final String? id;
//   final int? weight;
//   final int? sbp;
//   final int? dbp;
//   final int? hr;
//   final String? diagnosis;
//   final String? otherDiagnosis;
//   final String? status;
//   final String? canWalk;
//   final String? canClimb;
//   final List<Medicine>? medicines;
//   final String? createdAt;

//   PatientDrug({
//     this.id,
//     this.weight,
//     this.sbp,
//     this.dbp,
//     this.hr,
//     this.diagnosis,
//     this.otherDiagnosis,
//     this.status,
//     this.canWalk,
//     this.canClimb,
//     this.medicines,
//     this.createdAt,
//   });

//   factory PatientDrug.fromJson(Map<String, dynamic> json) {
//     return PatientDrug(
//       id: json['_id'],
//       weight: json['weight'],
//       sbp: json['sbp'],
//       dbp: json['dbp'],
//       hr: json['hr'],
//       diagnosis: json['diagnosis'],
//       otherDiagnosis: json['otherDiagnosis'],
//       status: json['status'],
//       canWalk: json['can_walk'],
//       canClimb: json['can_climb'],
//       medicines: (json['medicines'] as List<dynamic>?)
//           ?.map((e) => Medicine.fromJson(e))
//           .toList(),
//       createdAt: json['createdAt'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'weight': weight,
//       'sbp': sbp,
//       'dbp': dbp,
//       'hr': hr,
//       'diagnosis': diagnosis,
//       'otherDiagnosis': otherDiagnosis,
//       'status': status,
//       'can_walk': canWalk,
//       'can_climb': canClimb,
//       'medicines': medicines?.map((e) => e.toJson()).toList(),
//       'createdAt': createdAt,
//     };
//   }
// }
import 'package:hive/hive.dart';
import 'medicine.dart';

part 'patient_drug.g.dart';

@HiveType(typeId: 5) // ⚠️ UNIQUE across app
class PatientDrug {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final int? weight;

  @HiveField(2)
  final int? sbp;

  @HiveField(3)
  final int? dbp;

  @HiveField(4)
  final int? hr;

  @HiveField(5)
  final String? diagnosis;

  @HiveField(6)
  final String? otherDiagnosis;

  @HiveField(7)
  final String? status;

  @HiveField(8)
  final String? canWalk;

  @HiveField(9)
  final String? canClimb;

  @HiveField(10)
  final List<Medicine>? medicines; // 👈 Hive supports nested objects

  @HiveField(11)
  final String? createdAt;

  PatientDrug({
    this.id,
    this.weight,
    this.sbp,
    this.dbp,
    this.hr,
    this.diagnosis,
    this.otherDiagnosis,
    this.status,
    this.canWalk,
    this.canClimb,
    this.medicines,
    this.createdAt,
  });

  // ---------- Backend → App ----------
  factory PatientDrug.fromJson(Map<String, dynamic> json) {
    return PatientDrug(
      id: json['_id'],
      weight: json['weight'],
      sbp: json['sbp'],
      dbp: json['dbp'],
      hr: json['hr'],
      diagnosis: json['diagnosis'],
      otherDiagnosis: json['otherDiagnosis'],
      status: json['status'],
      canWalk: json['can_walk'],
      canClimb: json['can_climb'],
      medicines: (json['medicines'] as List<dynamic>?)
          ?.map((e) => Medicine.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'],
    );
  }

  // ---------- App → Backend ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'weight': weight,
      'sbp': sbp,
      'dbp': dbp,
      'hr': hr,
      'diagnosis': diagnosis,
      'otherDiagnosis': otherDiagnosis,
      'status': status,
      'can_walk': canWalk,
      'can_climb': canClimb,
      'medicines': medicines?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}
