import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

// Models
import 'models/sync_status.dart';
import 'models/user.dart';
import 'models/patient.dart';
import 'models/drug.dart';
import 'models/medicine.dart';
import 'models/patient_drug.dart';
import 'models/message.dart';
import 'models/report.dart';

// Services
import 'services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // STEP 2A: INIT HIVE
  // =========================
  await Hive.initFlutter();

  // =========================
  // REGISTER ADAPTERS
  // =========================
  Hive.registerAdapter(SyncStatusAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(DrugAdapter());
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(PatientDrugAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(ReportAdapter());

  // =========================
  // STEP 2B: OPEN BOXES
  // =========================
  await Hive.openBox<User>('usersBox');
  await Hive.openBox<Patient>('patientsBox');
  await Hive.openBox<Drug>('drugsBox');
  await Hive.openBox<Medicine>('medicinesBox');
  await Hive.openBox<PatientDrug>('patientDrugsBox');
  await Hive.openBox<Message>('messagesBox');
  await Hive.openBox<Report>('reportsBox');

  // Optional sync queue box
  await Hive.openBox<Map>('syncQueueBox');

  // =========================
  // START CONNECTIVITY LISTENER
  // =========================
  ConnectivityService.startListening();

  runApp(const MyApp());
}
