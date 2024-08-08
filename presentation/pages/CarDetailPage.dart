import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../users_pages/bookingpage.dart';


class CarDetailPage extends StatelessWidget {
  final List<String> imageUrls;
  final String brand;
  final String model;
  final String condition;
  final double price;
  final String gearbox;
  final int seats;
  final double fuelCapacity;
  final double topSpeed;
  final double hourlyRent;
  final int availableDays;

  CarDetailPage({
    required this.imageUrls,
    required this.brand,
    required this.model,
    required this.condition,
    required this.price,
    required this.gearbox,
    required this.seats,
    required this.fuelCapacity,
    required this.topSpeed,
    required this.hourlyRent,
    required this.availableDays,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$brand $model'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display car images
            Container(
              height: 250,
              child: PageView.builder(
                itemCount: imageUrls.isNotEmpty ? imageUrls.length : 1,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          imageUrls.isNotEmpty ? imageUrls[index] : 'assets/placeholder.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to booking page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : 'assets/placeholder.png',
                            brand: brand,
                            model: model,
                            hourlyRent: hourlyRent,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Car details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$brand $model',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 8),
                  DetailRow(
                    icon: Icons.star,
                    label: 'Condition',
                    value: condition.isNotEmpty ? condition : 'N/A',
                  ),
                  DetailRow(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: '\$${price.toString()}',
                  ),
                  DetailRow(
                    icon: Icons.settings,
                    label: 'Gearbox',
                    value: gearbox.isNotEmpty ? gearbox : 'N/A',
                  ),
                  DetailRow(
                    icon: Icons.event_seat,
                    label: 'Seats',
                    value: seats.toString(),
                  ),
                  DetailRow(
                    icon: Icons.local_gas_station,
                    label: 'Fuel Capacity',
                    value: '${fuelCapacity.toString()} L',
                  ),
                  DetailRow(
                    icon: Icons.speed,
                    label: 'Top Speed',
                    value: '${topSpeed.toString()} km/h',
                  ),
                  DetailRow(
                    icon: Icons.access_time,
                    label: 'Hourly Rent',
                    value: '${hourlyRent.toString()}',
                  ),
                  DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Available Days',
                    value: availableDays.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.0, color: Colors.black54),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
