import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SMBookingBookPage extends StatefulWidget {
  @override
  _SMBookingBookPageState createState() => _SMBookingBookPageState();
}

class _SMBookingBookPageState extends State<SMBookingBookPage> {
  final List<String> _shopOptions = ["Shop 1", "Shop 2", "Shop 3", "Shop 4", "Shop 5", "Shop 6", "Shop 7"];
  final List<String> _orderOptions = ["Order 1", "Order 2", "Order 3", "Order 4", "Order 5"];
  final List<String> _statusOptions = ["Dispatched", "Rescheduled", "Canceled", "Pending"];
  final List<String> _designationOptions = ["Booker", "RSM", "SM"];

  String? _selectedShop;
  String? _selectedOrder;
  String? _selectedStatus;
  String? _selectedDesignation;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showData = false;

  List<Map<String, dynamic>> _allData = []; // List to store all data
  List<Map<String, dynamic>> _filteredData = []; // List to store filtered data

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // Sample data generation
    _allData = List.generate(
      10,
          (index) => {
        'visitDate': DateTime.now().subtract(Duration(days: index * 2)),
        'userId': 'User $index',
        'bookerName': 'Booker $index',
        'totalShopVisits': '10',
        'totalOrders': '5',
        'totalAmount': '15',
        'designation': _designationOptions[index % _designationOptions.length],
      },
    );

    // Filter data based on the selected date range
    if (_startDate != null && _endDate != null) {
      _filteredData = _allData.where((data) {
        DateTime visitDate = data['visitDate'];
        return visitDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            visitDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      _filteredData = _allData;
    }

    setState(() {
      _showData = true; // Show data after filtering
    });
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
        _fetchData(); // Refresh data when date changes
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedShop = null;
      _selectedOrder = null;
      _selectedStatus = null;
      _selectedDesignation = null;
      _startDate = null;
      _endDate = null;
      _showData = false; // Hide data when filters are cleared
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(fontFamily: "avenir", fontSize: 10); // Reduced text size
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Reduced spacing
            const Center(
              child: Text(
                'Booker Order Detail',
                style: TextStyle(
                  fontFamily: 'avenir next',
                  fontSize: 14, // Reduced text size
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16), // Reduced spacing

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Designation",
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
                    ),
                    value: _selectedDesignation,
                    items: _designationOptions
                        .map((designation) => DropdownMenuItem(
                      value: designation,
                      child: Text(designation, style: textStyle),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDesignation = value;
                        _fetchData();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Shop",
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
                    ),
                    value: _selectedShop,
                    items: _shopOptions
                        .map((shop) => DropdownMenuItem(
                      value: shop,
                      child: Text(shop, style: textStyle),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedShop = value;
                        _fetchData();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced spacing
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Order",
                filled: true,
                fillColor: Colors.green.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
              ),
              value: _selectedOrder,
              items: _orderOptions
                  .map((order) => DropdownMenuItem(
                value: order,
                child: Text(order, style: textStyle),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOrder = value;
                  _fetchData();
                });
              },
            ),
            const SizedBox(height: 12), // Reduced spacing
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
                    ),
                    onTap: () => _selectDate(context, true),
                    controller: TextEditingController(
                      text: _startDate != null
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "End Date",
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
                    ),
                    onTap: () => _selectDate(context, false),
                    controller: TextEditingController(
                      text: _endDate != null
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced spacing
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Status",
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
                    ),
                    value: _selectedStatus,
                    items: _statusOptions
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: textStyle),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _fetchData();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced spacing
            if (_showData)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Booker')),
                      DataColumn(label: Text('Attendance')),
                      DataColumn(label: Text('Total')),
                    ],
                    rows: _filteredData.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(data['visitDate']))),
                        DataCell(Text(data['bookerName'])),
                        DataCell(Text(data['totalShopVisits'])),
                        DataCell(Text(data['totalOrders'])),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}