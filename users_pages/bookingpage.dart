import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'bookingpayment.dart';

class BookingPage extends StatefulWidget {
  final String imageUrl;
  final String brand;
  final String model;
  final double hourlyRent;

  BookingPage({
    required this.imageUrl,
    required this.brand,
    required this.model,
    required this.hourlyRent,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;
  final TextEditingController _licenseController = TextEditingController();

  void _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        if (_startDate != null && _endDate != null) {
          int days = _endDate!.difference(_startDate!).inDays + 1;
          _totalPrice = days * widget.hourlyRent;
        }
      });
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  void _storeBooking() {
    if (_startDate != null && _endDate != null && _licenseController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('bookings').add({
        'imageUrl': widget.imageUrl,
        'brand': widget.brand,
        'model': widget.model,
        'hourlyRent': widget.hourlyRent,
        'startDate': _startDate,
        'endDate': _endDate,
        'totalPrice': _totalPrice,
        'licenseNumber': _licenseController.text,
      });
    }
  }

  void _navigateToPayment() {
    _storeBooking();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookiPage2(
          totalPrice: _totalPrice ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking ${widget.brand} ${widget.model}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Text(
                '${widget.brand} ${widget.model}',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(_startDate == null ? 'Start Date' : DateFormat('yyyy-MM-dd').format(_startDate!)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(_endDate == null ? 'End Date' : DateFormat('yyyy-MM-dd').format(_endDate!)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _licenseController,
                decoration: InputDecoration(
                  labelText: 'Driving Licence Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              if (_totalPrice != null)
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Total Price: ${_totalPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _totalPrice == null ? null : _navigateToPayment,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Text('Pay now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
