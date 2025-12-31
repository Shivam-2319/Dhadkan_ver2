import 'package:hive/hive.dart';
import '../../models/medicine.dart';

class MedicineLocalRepository {
  final Box<Medicine> _box = Hive.box<Medicine>('medicinesBox');

  List<Medicine> getAll() => _box.values.toList();

  Future<void> saveAll(List<Medicine> medicines) async {
    int index = 0;
    for (final medicine in medicines) {
      await _box.put(index++, medicine);
    }
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
