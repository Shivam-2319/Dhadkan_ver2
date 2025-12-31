import 'package:hive/hive.dart';
import '../../models/message.dart';

class MessageLocalRepository {
  final Box<Message> _box = Hive.box<Message>('messagesBox');

  List<Message> getAll() => _box.values.toList();

  List<Message> getConversation(String user1, String user2) {
    return _box.values.where((msg) =>
        (msg.senderId == user1 && msg.receiverId == user2) ||
        (msg.senderId == user2 && msg.receiverId == user1)
    ).toList();
  }

  Future<void> save(Message message) async {
    await _box.put(message.id, message);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
