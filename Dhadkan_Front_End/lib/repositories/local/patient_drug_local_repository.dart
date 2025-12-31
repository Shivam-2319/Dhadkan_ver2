import 'package:hive/hive.dart';
import '../../models/patient_drug.dart';

class PatientDrugLocalRepository {
  final Box<PatientDrug> _box = Hive.box<PatientDrug>('patientDrugsBox');

  List<PatientDrug> getAll() => _box.values.toList();

  List<PatientDrug> getByPatientId(String patientId) {
    return _box.values
        .where((e) => e.id == patientId)
        .toList();
  }

  Future<void> save(PatientDrug record) async {
    await _box.put(record.id, record);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
