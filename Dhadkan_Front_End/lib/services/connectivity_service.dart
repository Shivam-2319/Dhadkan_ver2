import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';
import 'sync_service.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Start listening to network changes
  static void startListening() {
    if (_subscription != null) {
      print('[NET] Connectivity listener already running');
      return;
    }

    print('[NET] Starting connectivity listener');

    _subscription =
        _connectivity.onConnectivityChanged.listen((results) async {
      print('[NET] Connectivity changed: $results');

      // If ANY connection is not none → internet available
      final hasInternet =
          results.any((result) => result != ConnectivityResult.none);

      if (!hasInternet) {
        print('[NET] No internet connection');
        return;
      }

      print('[NET] Internet detected');

      final token = await SecureStorageService.getData('authToken');

      if (token == null || token.isEmpty) {
        print('[NET] No auth token found, skipping sync');
        return;
      }

      print('[NET] Auth token found → triggering SyncService');

      await SyncService.syncPendingPatients(token);
    });
  }

  /// Stop listening (optional, rarely used)
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    print('[NET] Connectivity listener stopped');
  }
}
