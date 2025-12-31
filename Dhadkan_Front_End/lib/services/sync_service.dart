import 'package:dhadkan/repositories/local/patient_local_repository.dart';
import 'package:dhadkan/models/patient.dart';
import 'package:dhadkan/utils/http/http_client.dart';

class SyncService {
  static bool _isSyncing = false;

  static Future<void> syncPendingPatients(String token) async {
    if (_isSyncing) return;
    _isSyncing = true;

    final repo = PatientLocalRepository();
    final pendingPatients = repo.getPendingPatients();

    for (final patient in pendingPatients) {
      try {
        await MyHttpHelper.private_post(
          '/doctor/addpatient',
          patient.toApiJson(),
          token,
        );

        await repo.deleteByUserId(patient.user.id);
        print('[SYNC] Synced & removed → ${patient.user.name}');
      } catch (e) {
        print('[SYNC] Failed → ${patient.user.name} ($e)');
      }
    }

    _isSyncing = false;
  }
}
