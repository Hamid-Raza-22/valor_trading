import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/Bookers_RSM_SM_NSM_Models/ShopStatusModel.dart';
import 'nsm_order_details_page.dart';
import 'nsm_shopdetails.dart'; // Add this import for date formatting

class NSMShopDetailsPage extends StatelessWidget {
  final ShopStatusModel shop;

  NSMShopDetailsPage({required this.shop});

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = [
      Order(id: 1, amount: 20.0, date: DateTime.now().subtract(const Duration(days: 4))),
      Order(id: 2, amount: 30.0, date: DateTime.now().subtract(const Duration(days: 3))),
      Order(id: 3, amount: 40.0, date: DateTime.now().subtract(const Duration(days: 2))),
      Order(id: 4, amount: 50.0, date: DateTime.now().subtract(const Duration(days: 1))),
    ];
    final int totalOrders = orders.length;
    final double totalBalance = orders.fold(0, (sum, order) => sum + order.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('${shop.name} Details'),
        backgroundColor: Colors.green[700],
        elevation: 4.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Add share functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopInfo(),
            const SizedBox(height: 20),
            Expanded(child: _buildOrdersList(orders)),
            const SizedBox(height: 20),
            _buildSummary(totalOrders, totalBalance),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfo() {
    return Card(
      elevation: 5.0, // Increase elevation for better shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[700]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/icons/shop-svg-3.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shop.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildOrdersList(List<Order> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0), // Increased vertical margin
          elevation: 5.0, // Increased elevation for better shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Increased border radius
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Increased padding
            leading: CircleAvatar(
              backgroundColor: Colors.green[700],
              child: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 28, // Increased icon size
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: TextStyle(
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4), // Increased spacing
                Text(
                  DateFormat.yMMMd().format(order.date),
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            subtitle: Text(
              'Amount: ${order.amount.toStringAsFixed(2)} PKR',
              style: const TextStyle(
                fontSize: 16, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 22, // Increased icon size
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  NSMOrderDetailsPage(order: order),
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildSummary(int totalOrders, double totalBalance) {
    return Card(
      elevation: 2.0, // Minimal shadow for a subtle lift
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0), // Smaller border radius
      ),
      color: Colors.white, // Background color of the card
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0), // Match the card's border radius
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!], // Soft gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15), // Light shadow
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1), // Subtle shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Uniform padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out the elements
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_basket, // Icon for total orders
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Orders',
                          style: TextStyle(
                            fontSize: 14, // Font size for title
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Black color for text
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalOrders',
                          style: const TextStyle(
                            fontSize: 18, // Font size for value
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Black color for text
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Spacing between columns
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.money, // Icon for total balance
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 14, // Font size for title
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Black color for text
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalBalance.toStringAsFixed(2)} PKR',
                          style: const TextStyle(
                            fontSize: 18, // Font size for value
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Black color for text
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class Order {
  final int id;
  final double amount;
  final DateTime date; // Added date field

  Order({
    required this.id,
    required this.amount,
    required this.date,
  });
}
