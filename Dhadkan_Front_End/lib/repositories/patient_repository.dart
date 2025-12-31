import 'package:dhadkan/models/patient.dart';
import 'package:dhadkan/repositories/local/patient_local_repository.dart';
import 'package:dhadkan/utils/http/http_client.dart';

class PatientRepository {
  final PatientLocalRepository _localRepo = PatientLocalRepository();

  // -----------------------
  // LOCAL
  // -----------------------

  List<Patient> getCachedPatients() {
    return _localRepo.getAll();
  }

  // -----------------------
  // SERVER REFRESH
  // -----------------------

  Future<List<Patient>> refreshFromServer(String token) async {
    final response = await MyHttpHelper.private_post(
      '/doctor/allpatient',
      {},
      token,
    );

    if (response['success'] != true &&
        response['success'] != 'true') {
      throw Exception('Failed to fetch patients');
    }

    final List list = response['data'] ?? [];

    // Extract patient objects
    final backendPatients = list
        .map((e) => Patient.fromJson(e['patient']))
        .toList();

    // 🔥 CRITICAL FIX
    await _localRepo.replaceAll(
      backendPatients: backendPatients,
    );

    return _localRepo.getAll();
  }
}
