import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  @override
  _RiwayatTransaksiScreenState createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  List<dynamic> transactions = [];
  List<dynamic> foodOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Handle the case where the token is not available
      print('Token not found');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    try {
      // Fetch courier orders
      final courierResponse = await http.get(
        Uri.parse('http://192.168.1.13:5006/api/orders'), // Ganti dengan alamat IP server Anda
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Fetch food orders
      final foodResponse = await http.get(
        Uri.parse('http://192.168.1.13:5006/api/food-orders'), // Ganti dengan alamat IP server Anda
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (courierResponse.statusCode == 200 && foodResponse.statusCode == 200) {
        final courierData = json.decode(courierResponse.body);
        final foodData = json.decode(foodResponse.body);
        if (mounted) {
          setState(() {
            transactions = courierData;
            foodOrders = foodData;
            _isLoading = false;
          });
        }
      } else {
        // Handle server error
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print('Failed to load transactions. Status code: ${courierResponse.statusCode} and ${foodResponse.statusCode}');
        print('Courier response body: ${courierResponse.body}');
        print('Food response body: ${foodResponse.body}');
      }
    } catch (e) {
      // Handle network error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error: $e');
    }
  }

  Future<void> _refreshTransactions() async {
    await _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: transactions.isEmpty && foodOrders.isEmpty
            ? Center(child: Text('Tidak ada transaksi'))
            : ListView.builder(
          itemCount: transactions.length + foodOrders.length,
          itemBuilder: (context, index) {
            if (index < transactions.length) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction, 'Kurir Order');
            } else {
              final foodOrder = foodOrders[index - transactions.length];
              return _buildTransactionCard(foodOrder, 'Food Order');
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(dynamic transaction, String type) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        title: Text(
          transaction['recipient_address'] ?? transaction['delivery_location'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction['recipient_phone'] ?? transaction['user_phone'],
              style: TextStyle(fontSize: 16),
            ),
            Text(
              type,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: transaction['status'] == 0 ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            transaction['status'] == 0 ? 'Pending' : 'Selesai',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
