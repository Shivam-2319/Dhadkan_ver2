import '../../utils/http/http_client.dart';
import '../../models/patient.dart';

class PatientRemoteRepository {
  /// Fetch all patients from backend
  Future<List<Patient>> fetchAllPatients(String token) async {
    final response = await MyHttpHelper.private_post(
      '/doctor/allpatient',
      {},
      token,
    );

    if (response['success'] == true || response['success'] == 'true') {
      final List data = response['data'] ?? [];

      return data.map((item) {
        final patientJson = item['patient'] as Map<String, dynamic>;
        return Patient.fromJson(patientJson);
      }).toList();
    }

    throw Exception(response['message'] ?? 'Failed to fetch patients');
  }
}
