import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> _generatePDF(List<Map<String, dynamic>> orders) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        children: [
          pw.Text('Order Details', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return pw.Text(
                'Order No: ${order['order_no']}, Product: ${order['product_name']}, Quantity: ${order['quantity_booked']}',
              );
            },
          ),
        ],
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/order_details.pdf");
  await file.writeAsBytes(await pdf.save());
  // Now you can share the PDF file or open it
}
