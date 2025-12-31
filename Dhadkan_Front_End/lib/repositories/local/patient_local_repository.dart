import 'package:hive/hive.dart';
import '../../models/patient.dart';
import '../../models/sync_status.dart';

class PatientLocalRepository {
  final Box<Patient> _box = Hive.box<Patient>('patientsBox');

  // -----------------------
  // READ
  // -----------------------

  List<Patient> getAll() {
    final list = _box.values.toList();
    print('[Hive][PatientRepo] getAll → ${list.length}');
    return list;
  }

  List<Patient> getPendingPatients() {
    final pending = _box.values
        .where((p) => p.syncStatus == SyncStatus.pending)
        .toList();

    print('[Hive][PatientRepo] Pending → ${pending.length}');
    return pending;
  }

  // -----------------------
  // WRITE
  // -----------------------

  Future<void> save(Patient patient) async {
    await _box.put(patient.user.id, patient);
    print(
      '[Hive][PatientRepo] Saved ${patient.user.name} '
      '(id=${patient.user.id}, status=${patient.syncStatus})',
    );
  }

  Future<void> deleteByUserId(String userId) async {
    await _box.delete(userId);
    print('[Hive][PatientRepo] Deleted userId=$userId');
  }

  Future<void> clear() async {
    await _box.clear();
    print('[Hive][PatientRepo] Cleared box');
  }

  // -----------------------
  // 🔥 CRITICAL FIX
  // -----------------------

  /// Replace cache with backend truth + keep ONLY pending
  Future<void> replaceAll({
    required List<Patient> backendPatients,
  }) async {
    // 1️⃣ Keep pending patients
    final pending = _box.values
        .where((p) => p.syncStatus == SyncStatus.pending)
        .toList();

    // 2️⃣ Clear everything
    await _box.clear();

    // 3️⃣ Save backend patients
    for (final p in backendPatients) {
      await _box.put(p.user.id, p);
    }

    // 4️⃣ Re-add pending if not already present
    for (final p in pending) {
      if (!_box.containsKey(p.user.id)) {
        await _box.put(p.user.id, p);
      }
    }

    print(
      '[Hive][PatientRepo] Cache replaced → '
      'backend=${backendPatients.length}, pending=${pending.length}',
    );
  }
}
