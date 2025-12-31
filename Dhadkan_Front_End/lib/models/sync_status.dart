import 'package:hive/hive.dart';

part 'sync_status.g.dart';

@HiveType(typeId: 20) // ⚠️ must be unique app-wide
enum SyncStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  synced,

  @HiveField(2)
  failed,
}
