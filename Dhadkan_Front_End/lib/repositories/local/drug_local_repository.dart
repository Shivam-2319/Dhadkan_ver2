import 'package:hive/hive.dart';
import '../../models/drug.dart';

class DrugLocalRepository {
  final Box<Drug> _box = Hive.box<Drug>('drugsBox');

  List<Drug> getAll() => _box.values.toList();

  Drug? getById(String id) => _box.get(id);

  Future<void> save(Drug drug) async {
    await _box.put(drug.id, drug);
  }

  Future<void> saveAll(List<Drug> drugs) async {
    for (final drug in drugs) {
      await _box.put(drug.id, drug);
    }
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
