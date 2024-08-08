import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return ListTile(
                title: Text('${booking['brand']} ${booking['model']}'),
                subtitle: Text('Total Price: ${booking['totalPrice'].toString()}'),
                trailing: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    booking.reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
