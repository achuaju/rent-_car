import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bookingpayment.dart';

class BookingPage1 extends StatefulWidget {
  @override
  _BookingPage1State createState() => _BookingPage1State();
}

class _BookingPage1State extends State<BookingPage1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String pickupLocation = '';
  String selectedDate = '';
  String selectedTimeSlot = '';
  String endDate = '';
  String numberOfRiders = '';
  String car = '';
  double carPrice = 0.0;
  double totalPrice = 0.0;
  String contactNumber = '';

  final Map<String, double> carPrices = {
    'Innova': 1000,
    'Harrier': 1200,
    'Creta': 900,
    'Brezza': 800,
    'Fortuner': 1,
    'Swift': 700,
    'Seltos': 1100,
    'Nexon': 950,
    'i20': 600,
  };

  final List<String> districts = [
    'Alappuzha',
    'Ernakulam',
    'Idukki',
    'Kannur',
    'Kasaragod',
    'Kollam',
    'Kottayam',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Pathanamthitta',
    'Thiruvananthapuram',
    'Thrissur',
    'Wayanad',
  ];

  void _addBookingToFirestore() async {
    try {
      await firestore.collection('bookings').add({
        'pickupLocation': pickupLocation,
        'selectedDate': selectedDate,
        'selectedTimeSlot': selectedTimeSlot,
        'endDate': endDate,
        'numberOfRiders': numberOfRiders,
        'car': car,
        'carPrice': carPrice,
        'totalPrice': totalPrice,
        'contactNumber': contactNumber,
      });

      setState(() {
        pickupLocation = '';
        selectedDate = '';
        selectedTimeSlot = '';
        endDate = '';
        numberOfRiders = '';
        car = '';
        carPrice = 0.0;
        totalPrice = 0.0;
        contactNumber = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking successfully added')),
      );
    } catch (e) {
      print('Error adding booking: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isEndDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isEndDate) {
          endDate = pickedDate.toString();
        } else {
          selectedDate = pickedDate.toString();
        }
        _updateTotalPrice();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTimeSlot = pickedTime.format(context);
      });
    }
  }

  void _updateTotalPrice() {
    if (selectedDate.isNotEmpty && endDate.isNotEmpty && car.isNotEmpty) {
      final startDate = DateTime.parse(selectedDate);
      final endDate = DateTime.parse(this.endDate);
      final days = endDate.difference(startDate).inDays;

      if (days >= 0) {
        setState(() {
          totalPrice = (days + 1) * carPrice; // Added 1 to include the end day
        });
      }
    }
  }

  Widget buildTextField(String labelText, Function(String) onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Booking'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: pickupLocation.isEmpty ? null : pickupLocation,
                  hint: Text('Select Pickup Location'),
                  isExpanded: true,
                  items: districts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      pickupLocation = newValue!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _selectDate(context, false),
              style: ElevatedButton.styleFrom(primary: Colors.black),
              child: Text('Select Start Date'),
            ),
            Text('Selected Start Date: $selectedDate'),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              style: ElevatedButton.styleFrom(primary: Colors.black),
              child: Text('Select End Date'),
            ),
            Text('Selected End Date: $endDate'),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              style: ElevatedButton.styleFrom(primary: Colors.black),
              child: Text('Select Time Slot'),
            ),
            Text('Selected Time Slot: $selectedTimeSlot'),
            buildTextField('Number of Riders', (value) {
              setState(() {
                numberOfRiders = value;
              });
            }),
            buildTextField('Contact Number', (value) {
              setState(() {
                contactNumber = value;
              });
            }),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      car.isEmpty ? 'Select Car' : car,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showCarSelectionDialog();
                    },
                  ),
                ],
              ),
            ),
            Text('Car Price per Day: ₹$carPrice'),
            Text('Total Price: ₹$totalPrice'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addBookingToFirestore();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => BookiPage2(totalPrice: totalPrice),
                  ),
                );
              },
              child: Text('Book Now'),
              style: ElevatedButton.styleFrom(primary: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Car'),
          content: SingleChildScrollView(
            child: ListBody(
              children: carPrices.keys.map((String carName) {
                return ListTile(
                  title: Text(carName),
                  onTap: () {
                    setState(() {
                      car = carName;
                      carPrice = carPrices[carName]!;
                      _updateTotalPrice();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
