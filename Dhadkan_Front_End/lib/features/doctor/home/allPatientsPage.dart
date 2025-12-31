import 'package:flutter/material.dart';
import 'package:dhadkan/features/auth/landing_screen.dart';
import 'package:dhadkan/features/doctor/home/patient_drugdatascreen.dart';
import 'package:dhadkan/features/common/top_bar.dart';
import 'package:dhadkan/utils/device/device_utility.dart';
import 'package:dhadkan/utils/constants/colors.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';

import 'package:dhadkan/repositories/patient_repository.dart';
import 'package:dhadkan/models/patient.dart';
import 'package:dhadkan/models/sync_status.dart';

class AllPatientsPage extends StatefulWidget {
  const AllPatientsPage({super.key});

  @override
  State<AllPatientsPage> createState() => _AllPatientsPageState();
}

class _AllPatientsPageState extends State<AllPatientsPage> {
  final PatientRepository _repo = PatientRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];

  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // -----------------------------
  // INIT
  // -----------------------------
  Future<void> _init() async {
    final token = await SecureStorageService.getData('authToken');

    if (token == null || token.isEmpty) {
      _redirectToLanding();
      return;
    }

    _token = token;

    // 1️⃣ Load clean cache immediately
    final cached = _repo
        .getCachedPatients()
        .where((p) => p.syncStatus != SyncStatus.failed)
        .toList();

    setState(() {
      _allPatients = cached;
      _filteredPatients = cached;
      _isLoading = false;
    });

    // 2️⃣ Refresh from backend (if online)
    _refreshFromServer();
  }

  Future<void> _refreshFromServer() async {
    try {
      final fresh = await _repo.refreshFromServer(_token!);

      setState(() {
        _allPatients = fresh;
        _filteredPatients = fresh;
      });
    } catch (_) {
      // Offline → keep cache silently
    }
  }

  // -----------------------------
  // SEARCH FILTER
  // -----------------------------
  void _filterPatients() {
    final q = _searchController.text.toLowerCase();

    if (q.isEmpty) {
      setState(() => _filteredPatients = _allPatients);
      return;
    }

    setState(() {
      _filteredPatients = _allPatients.where((p) {
        return p.user.name.toLowerCase().contains(q) ||
            p.uhid.toLowerCase().contains(q) ||
            p.user.mobile.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _redirectToLanding() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    });
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final padding = MyDeviceUtils.getScreenWidth(context) * 0.05;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const TopBar(title: "All Patients")),
      body: RefreshIndicator(
        onRefresh: _refreshFromServer,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildCount(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // SEARCH BAR WITH DROPDOWN
  // -----------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: RawAutocomplete<Patient>(
        textEditingController: _searchController,
        focusNode: FocusNode(),

        // 🔹 Suggestion logic
        optionsBuilder: (TextEditingValue value) {
          if (value.text.isEmpty) {
            return const Iterable<Patient>.empty();
          }

          final q = value.text.toLowerCase();

          return _allPatients.where((p) {
            return p.user.name.toLowerCase().contains(q) ||
                p.uhid.toLowerCase().contains(q) ||
                p.user.mobile.toLowerCase().contains(q);
          });
        },

        displayStringForOption: (Patient p) => p.user.name,

        // 🔹 When suggestion selected
        onSelected: (Patient p) {
          _searchController.text = p.user.name;
          setState(() {
            _filteredPatients = [p];
          });
        },

        // 🔹 TextField UI
        fieldViewBuilder:
            (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Search by Name, UHID or Mobile',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _filterPatients(),
          );
        },

        // 🔹 Dropdown UI
        optionsViewBuilder:
            (context, onSelected, Iterable<Patient> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: options.length,
                itemBuilder: (_, index) {
                  final p = options.elementAt(index);

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(p.user.name),
                    subtitle: Text(
                      'UHID: ${p.uhid} | ${p.user.mobile}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => onSelected(p),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // -----------------------------
  // COUNT
  // -----------------------------
  Widget _buildCount() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Total patients: ${_allPatients.length}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MyColors.primary,
        ),
      ),
    );
  }

  // -----------------------------
  // LIST
  // -----------------------------
  Widget _buildList() {
    if (_filteredPatients.isEmpty) {
      return const Center(child: Text("No patients found"));
    }

    return ListView.builder(
      itemCount: _filteredPatients.length,
      itemBuilder: (_, i) => _buildPatientCard(_filteredPatients[i]),
    );
  }

  Widget _buildPatientCard(Patient p) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('assets/Images/patient2.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.user.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'UHID: ${p.uhid}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientDrugDataScreen(
                    patientMobile: p.user.mobile,
                    patientName: p.user.name,
                    patientId: p.user.id,
                  ),
                ),
              );
            },
            child: const Text("More Info"),
          ),
        ],
      ),
    );
  }
}
