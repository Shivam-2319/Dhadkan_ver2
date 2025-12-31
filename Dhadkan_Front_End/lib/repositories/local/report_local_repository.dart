import 'package:hive/hive.dart';
import '../../models/report.dart';

class ReportLocalRepository {
  final Box<Report> _box = Hive.box<Report>('reportsBox');

  List<Report> getAll() => _box.values.toList();

  List<Report> getByPatient(String patientId) {
    return _box.values
        .where((r) => r.patientId == patientId)
        .toList();
  }

  Future<void> save(Report report) async {
    await _box.put(report.id, report);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
