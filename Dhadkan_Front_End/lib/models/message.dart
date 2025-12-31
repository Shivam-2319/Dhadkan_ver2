import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 6) // ⚠️ UNIQUE across app
class Message {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? message;

  @HiveField(2)
  final String? senderId;

  @HiveField(3)
  final String? receiverId;

  @HiveField(4)
  final String? createdAt;

  Message({
    this.id,
    this.message,
    this.senderId,
    this.receiverId,
    this.createdAt,
  });

  // ---------- Backend → App ----------
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      message: json['message'],
      senderId: json['sender'],
      receiverId: json['receiver'],
      createdAt: json['createdAt'],
    );
  }

  // ---------- App → Backend ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'sender': senderId,
      'receiver': receiverId,
      'createdAt': createdAt,
    };
  }
}
