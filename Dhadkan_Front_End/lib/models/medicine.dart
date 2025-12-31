import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 4) // ⚠️ must be UNIQUE across the app
class Medicine {
  @HiveField(0)
  final String? name;

  @HiveField(1)
  final String? format;

  @HiveField(2)
  final String? dosage;

  @HiveField(3)
  final String? frequency;

  @HiveField(4)
  final String? customFrequency;

  @HiveField(5)
  final String? companyName;

  @HiveField(6)
  final String? medClass;

  @HiveField(7)
  final String? medicineTiming;

  @HiveField(8)
  final String? generic;

  Medicine({
    this.name,
    this.format,
    this.dosage,
    this.frequency,
    this.customFrequency,
    this.companyName,
    this.medClass,
    this.medicineTiming,
    this.generic,
  });

  // ---------- Backend → App ----------
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      format: json['format'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      customFrequency: json['customFrequency'],
      companyName: json['company_name'],
      medClass: json['class'],
      medicineTiming: json['medicineTiming'],
      generic: json['generic'],
    );
  }

  // ---------- App → Backend ----------
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'format': format,
      'dosage': dosage,
      'frequency': frequency,
      'customFrequency': customFrequency,
      'company_name': companyName,
      'class': medClass,
      'medicineTiming': medicineTiming,
      'generic': generic,
    };
  }
}

