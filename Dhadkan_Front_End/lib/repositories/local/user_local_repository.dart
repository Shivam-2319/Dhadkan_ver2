import 'package:hive/hive.dart';
import '../../models/user.dart';

class UserLocalRepository {
  final Box<User> _box = Hive.box<User>('usersBox');

  User? getById(String id) => _box.get(id);

  List<User> getAll() => _box.values.toList();

  Future<void> save(User user) async {
    await _box.put(user.id, user);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
