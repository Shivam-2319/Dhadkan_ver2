class PatientSummary {
  final String name;
  final String age;
  final String gender;
  final String mobile;
  final String disease;

  PatientSummary({
    required this.name,
    required this.age,
    required this.gender,
    required this.mobile,
    required this.disease,
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) {
    return PatientSummary(
      name: json['name']?.toString() ?? 'N/A',
      age: json['age']?.toString() ?? 'N/A',
      gender: json['gender']?.toString() ?? 'N/A',
      mobile: json['mobile']?.toString() ?? 'N/A',
      disease: (json['diagnosis'] == 'Other'
              ? json['customDisease']
              : json['diagnosis'])
          ?.toString() ??
          'N/A',
    );
  }
}
