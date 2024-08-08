import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataViewPage extends StatefulWidget {
  @override
  _DataViewPageState createState() => _DataViewPageState();
}

class _DataViewPageState extends State<DataViewPage> {
  // Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to delete a booking
  void _deleteBooking(String documentId) {
    firestore.collection('bookings').doc(documentId).delete().then((_) {
      // Booking deleted successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking successfully deleted')),
      );
    }).catchError((error) {
      print("Error deleting booking: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings'),
        backgroundColor: Colors.grey,
      ),
      body: StreamBuilder(
        stream: firestore.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
              documents[index].data() as Map<String, dynamic>;

              // Extract data from the document with default values
              String pickupLocation = data['pickupLocation'] ?? 'Not provided';
              String selectedDate = data['selectedDate'] ?? 'Not provided';
              String timeSlot = data['selectedTimeSlot'] ?? 'Not provided';
              String endDate = data['endDate'] ?? 'Not provided';
              String riderName = data['numberOfRiders'] ?? 'Not provided';
              String car = data['car'] ?? 'Not provided';
              double carPrice = (data['carPrice'] ?? 0.0) as double;
              String contactNumber = data['contactNumber'] ?? 'Not provided';

              return Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: pickupLocation),
                        decoration: InputDecoration(
                          labelText: 'Pickup Location',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: selectedDate),
                        decoration: InputDecoration(
                          labelText: 'Selected Date',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: timeSlot),
                        decoration: InputDecoration(
                          labelText: 'Selected Time Slot',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: endDate),
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: riderName),
                        decoration: InputDecoration(
                          labelText: 'Number of Riders',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: car),
                        decoration: InputDecoration(
                          labelText: 'Car',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: '₹$carPrice'),
                        decoration: InputDecoration(
                          labelText: 'Car Price',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(text: contactNumber),
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          _deleteBooking(documents[index].id);
                        },
                        icon: Icon(Icons.cancel),
                        label: Text("Cancel Booking"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
