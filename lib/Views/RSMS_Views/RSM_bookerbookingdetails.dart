import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../NSM/NSM_bookerbookingdetails.dart';

class RSMBookingBookPage extends StatefulWidget {
  @override
  _RSMBookingBookPageState createState() => _RSMBookingBookPageState();
}

class _RSMBookingBookPageState extends State<RSMBookingBookPage> {
  final List<String> _shopOptions = ["Shop 1", "Shop 2", "Shop 3", "Shop 4", "Shop 5", "Shop 6", "Shop 7"];
  final List<String> _orderOptions = ["Order 1", "Order 2", "Order 3", "Order 4", "Order 5"];
  final List<String> _statusOptions = ["Dispatched", "Rescheduled", "Canceled", "Pending"];

  String? _selectedShop;
  String? _selectedOrder;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showData = false;

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
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedShop = null;
      _selectedOrder = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _showData = false;
    });
  }

  void _handleSearch() {
    setState(() {
      _showData = true;
    });
  }

  void _openDetailsPage(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsPage(title: title)),
    );
  }



    @override
    Widget build(BuildContext context) {
      final textStyle = TextStyle(fontFamily: 'avenir next', fontSize: 12);
      final screenWidth = MediaQuery.of(context).size.width;

      return Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text('Booker Order Detail',
                  style: TextStyle(fontFamily: 'avenir next', fontSize: 17, color: Colors.black))),
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Shop",
                        filled: true,
                        fillColor: Colors.green.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      value: _selectedShop,
                      items: _shopOptions
                          .map((shop) => DropdownMenuItem(
                        value: shop,
                        child: Text(shop),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedShop = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Order",
                        filled: true,
                        fillColor: Colors.green.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      value: _selectedOrder,
                      items: _orderOptions
                          .map((order) => DropdownMenuItem(
                        value: order,
                        child: Text(order),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrder = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onTap: () => _selectDate(context, true),
                      controller: TextEditingController(
                        text: _startDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_startDate!)
                            : '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onTap: () => _selectDate(context, false),
                      controller: TextEditingController(
                        text: _endDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_endDate!)
                            : '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Status",
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                value: _selectedStatus,
                items: _statusOptions
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSearch,
                      child: const Text('Search', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _showData
                        ? DataTable(
                      columnSpacing: screenWidth * 0.05,
                      columns: [
                        DataColumn(label: Text('Visit Date', style: textStyle)),
                        DataColumn(label: Text('User ID', style: textStyle)),
                        DataColumn(label: Text('Booker Name', style: textStyle)),
                        DataColumn(label: Text('Total Shop Visits', style: textStyle)),
                        DataColumn(label: Text('Total Orders', style: textStyle)),
                        DataColumn(label: Text('Total Booking', style: textStyle)),
                        DataColumn(label: Text('Designation', style: textStyle)),
                      ],
                      rows: List<DataRow>.generate(
                        10,
                            (index) => DataRow(
                          cells: [
                            DataCell(Text('2024-07-20', style: textStyle)),
                            DataCell(Text('User ${index + 1}', style: textStyle)),
                            DataCell(Text('Booker ${index + 1}', style: textStyle)),
                            DataCell(
                              Text('${(index + 1) * 2}', style: textStyle),
                              onTap: () => _openDetailsPage('Total Shop Visits'),
                            ),
                            DataCell(
                              Text('${(index + 1) * 3}', style: textStyle),
                              onTap: () => _openDetailsPage('Total Orders'),
                            ),
                            DataCell(Text('\$${(index + 1) * 10}', style: textStyle)),
                            DataCell(Text('SO', style: textStyle)),
                          ],
                        ),
                      ),
                    )
                        : Container(), // Show empty container if no data to display
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


