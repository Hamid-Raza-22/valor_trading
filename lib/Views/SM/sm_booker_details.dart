import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/Bookers_RSM_SM_NSM_Models/BookerStatusModel.dart';
import 'package:http/http.dart' as http;
import '../../Models/Bookers_RSM_SM_NSM_Models/RSMStatusModel.dart';
import 'dart:convert';

import '../../Models/Bookers_RSM_SM_NSM_Models/AttendanceStatusModel.dart';



class SMBookerDetailPage extends StatefulWidget {
  final RSMStatusModel booker;

  SMBookerDetailPage({required this.booker});

  @override
  _RSMBookerDetailsPageState createState() => _RSMBookerDetailsPageState();
}
class _RSMBookerDetailsPageState extends State<SMBookerDetailPage> {
  final List<String> _statusOptions = ["Clock in", "Clock out"];
  List<AttendanceStatusModel> _attendanceData = [];
  List<AttendanceStatusModel> _filteredData = [];

  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
    _filteredData = _attendanceData;
  }

  Future<void> _fetchAttendanceData() async {
    final response = await http.get(
      Uri.parse('http://103.149.32.30:8080/ords/metaxperts/attendancedata/get/${widget.booker.bookerId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['items'];

      // Parse and sort data
      final List<AttendanceStatusModel> parsedData = data.map((item) => AttendanceStatusModel.fromJson(item)).toList();

      // Sort data by date in descending order
      parsedData.sort((a, b) {
        final dateA = DateFormat('dd-MMM-yyyy').parse(a.date);
        final dateB = DateFormat('dd-MMM-yyyy').parse(b.date);
        return dateB.compareTo(dateA); // Descending order
      });

      setState(() {
        _attendanceData = parsedData;
        _filteredData = _attendanceData; // Initialize _filteredData
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _filterData();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _filteredData = _attendanceData;
    });
  }


// Create a DateFormat instance for your date format
  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

  void _filterData() {


    setState(() {
      _filteredData = _attendanceData.where((entry) {
        DateTime? entryDate;
        try {
          entryDate = dateFormat.parse(entry.date);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing date: ${entry.date}');
          }
          return false; // Skip entries with invalid date formats
        }

        // Check if the date is within the selected range
        final isWithinDateRange = (_startDate == null || entryDate.isAtSameMomentAs(_startDate!) || entryDate.isAfter(_startDate!)) &&
            (_endDate == null || entryDate.isAtSameMomentAs(_endDate!) || entryDate.isBefore(_endDate!.add(const Duration(days: 1))));



        // Check if the status matches the selected status
        final matchesStatus = _selectedStatus == null ||
            (_selectedStatus == "Clock in" && entry.timeIn.isNotEmpty) ||
            (_selectedStatus == "Clock out" && entry.timeOut.isNotEmpty);
        // Sort data by date in descending order
        _filteredData.sort((a, b) {
          final dateA = dateFormat.parse(a.date);
          final dateB = dateFormat.parse(b.date);
          return dateB.compareTo(dateA); // Descending order
        });

        print('Matches Status: $matchesStatus');

        return isWithinDateRange && matchesStatus;
      }).toList();

    });
  }



  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontFamily: "avenir", fontSize: 14);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booker.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Text(
                        _startDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_startDate!)
                            : '',
                        style: TextStyle(
                          color: _startDate != null ? Colors.black : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "End Date",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Text(
                        _endDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_endDate!)
                            : '',
                        style: TextStyle(
                          color: _endDate != null ? Colors.black : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Status",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            _filterData();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date', style: textStyle)),
                      DataColumn(label: Text('Clock In', style: textStyle)),
                      DataColumn(label: Text('Clock Out', style: textStyle)),
                      DataColumn(label: Text('Total Time', style: textStyle)),
                      DataColumn(label: Text('Total Distance', style: textStyle)),
                    ],
                    rows: _filteredData.map((entry) { // Use _filteredData here
                      return DataRow(
                        cells: [
                          DataCell(Text(entry.date, style: textStyle)),
                          DataCell(Text(entry.timeIn, style: textStyle)),
                          DataCell(Text(entry.timeOut, style: textStyle)),
                          DataCell(Text(entry.totalTime, style: textStyle)),
                          DataCell(Text(entry.totalDistance, style: textStyle)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


