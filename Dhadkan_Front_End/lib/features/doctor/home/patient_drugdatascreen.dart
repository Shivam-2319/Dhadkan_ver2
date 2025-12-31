import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dhadkan/utils/http/http_client.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';

import 'package:dhadkan/models/patient_drug.dart';
import 'package:dhadkan/models/medicine.dart';
import 'package:dhadkan/models/patient_summary.dart';

import 'package:dhadkan/features/patient/home/patient_graph.dart';
import 'package:dhadkan/features/doctor/doctor_buttonsindisplaydata.dart';
import 'package:dhadkan/features/doctor/home/drug.dart/adddrug.dart';

class PatientDrugDataScreen extends StatefulWidget {
  final String patientMobile;
  final String patientName;
  final String patientId;

  const PatientDrugDataScreen({
    super.key,
    required this.patientMobile,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<PatientDrugDataScreen> createState() => _PatientDrugDataScreenState();
}

class _PatientDrugDataScreenState extends State<PatientDrugDataScreen> {
  String _token = '';

  bool _isLoading = true;
  bool _loadingPatientDetails = true;

  String _errorMessage = '';
  String _patientDetailsError = '';

  PatientSummary? _patientDetails;

  List<PatientDrug> _allDrugRecords = [];
  List<PatientDrug> _filteredDrugRecords = [];

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await SecureStorageService.getData('authToken');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication token missing';
        _isLoading = false;
        _loadingPatientDetails = false;
      });
      return;
    }

    _token = token;

    await Future.wait([
      _fetchPatientDetails(),
      _fetchAllAndFilterDrugData(),
    ]);
  }

  // -----------------------------
  // PATIENT DETAILS
  // -----------------------------
  Future<void> _fetchPatientDetails() async {
    try {
      final response = await MyHttpHelper.private_post(
        '/doctor/getinfo/${widget.patientMobile}',
        {},
        _token,
      );

      if (response['status'] == 'success') {
        setState(() {
          _patientDetails = PatientSummary.fromJson(response['data']);
          _loadingPatientDetails = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed');
      }
    } catch (e) {
      setState(() {
        _patientDetailsError = e.toString();
        _loadingPatientDetails = false;
      });
    }
  }

  // -----------------------------
  // DRUG DATA
  // -----------------------------
  Future<void> _fetchAllAndFilterDrugData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await MyHttpHelper.private_post(
        '/doctor/patient-drug-data/mobile/${widget.patientMobile}',
        {},
        _token,
      );

      final List list = response['data'] ?? [];

      final records =
          list.map((e) => PatientDrug.fromJson(e)).toList();

      List<PatientDrug> filtered = records;

      if (_selectedDate != null) {
        final selected =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);

        filtered = records.where((r) {
          if (r.createdAt == null) return false;
          final d = DateTime.parse(r.createdAt!);
          return DateFormat('yyyy-MM-dd').format(d) == selected;
        }).toList();
      }

      setState(() {
        _allDrugRecords = records;
        _filteredDrugRecords = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF03045E),
        title: Text(
          'Drug data for ${widget.patientName}',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPatientDetailsCard(),
        const SizedBox(height: 10),
        PatientGraph(graphData: _generateGraphData()),
        const SizedBox(height: 10),
        DoctorButtonsindisplaydata(
          patientMobile: widget.patientMobile,
          patientId: widget.patientId,
        ),
        const SizedBox(height: 10),
        _buildDateFilter(),
        const SizedBox(height: 10),
        ..._filteredDrugRecords.map(_buildDrugCard),
      ],
    );
  }

  // -----------------------------
  // PATIENT CARD (❤️ FIXED UI)
  // -----------------------------
  Widget _buildPatientDetailsCard() {
    if (_loadingPatientDetails) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_patientDetailsError.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _patientDetailsError,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final p = _patientDetails!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ❤️ PATIENT HEART ICON
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAFF),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Image.asset(
                'assets/Images/patient2.png',
                height: 55,
                width: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // 🧾 PATIENT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Name', p.name),
                _row('Age', p.age),
                _row('Gender', p.gender),
                _row('Phone', p.mobile),
                _row('Disease', p.disease),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // GRAPH DATA
  // -----------------------------
  Map<String, dynamic> _generateGraphData() {
    return {
      'sbp': _allDrugRecords.map((e) => e.sbp ?? 0).toList(),
      'dbp': _allDrugRecords.map((e) => e.dbp ?? 0).toList(),
      'hr': _allDrugRecords.map((e) => e.hr ?? 0).toList(),
      'weight': _allDrugRecords.map((e) => e.weight ?? 0).toList(),
    };
  }

  // -----------------------------
  // DATE FILTER
  // -----------------------------
  Widget _buildDateFilter() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        _selectedDate == null
            ? 'Filter by Date'
            : DateFormat('dd MMM yyyy').format(_selectedDate!),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: _pickDate,
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (d != null) {
      setState(() => _selectedDate = d);
      _fetchAllAndFilterDrugData();
    }
  }

  // -----------------------------
  // DRUG CARD (SIMPLE)
  // -----------------------------
  Widget _buildDrugCard(PatientDrug r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'SBP: ${r.sbp ?? '-'} | DBP: ${r.dbp ?? '-'} | HR: ${r.hr ?? '-'}',
        ),
      ),
    );
  }
}
