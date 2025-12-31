// class Drug {
//   final String? id;
//   final String? name;
//   final String? companyName;
//   final String? drugClass;
//   final String? format;
//   final String? generic;

//   Drug({
//     this.id,
//     this.name,
//     this.companyName,
//     this.drugClass,
//     this.format,
//     this.generic,
//   });

//   factory Drug.fromJson(Map<String, dynamic> json) {
//     return Drug(
//       id: json['_id'],
//       name: json['name'],
//       companyName: json['company_name'],
//       drugClass: json['class'],
//       format: json['format'],
//       generic: json['generic'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'company_name': companyName,
//       'class': drugClass,
//       'format': format,
//       'generic': generic,
//     };
//   }
// }

import 'package:hive/hive.dart';

part 'drug.g.dart';

@HiveType(typeId: 3) // <-- must be unique across app
class Drug {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? companyName;

  @HiveField(3)
  final String? drugClass;

  @HiveField(4)
  final String? format;

  @HiveField(5)
  final String? generic;

  Drug({
    this.id,
    this.name,
    this.companyName,
    this.drugClass,
    this.format,
    this.generic,
  });

  // ---------- Backend → App ----------
  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['_id'],
      name: json['name'],
      companyName: json['company_name'],
      drugClass: json['class'],
      format: json['format'],
      generic: json['generic'],
    );
  }

  // ---------- App → Backend ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'company_name': companyName,
      'class': drugClass,
      'format': format,
      'generic': generic,
    };
  }
}

