import 'package:Rent_a_car/presentation/pages/CarDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../users_pages/car_booking_main_page.dart';
import '../Provider/CarListProvider.dart';


class CarListScreen1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('rent a car',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.grey,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        onChanged: (query) => context.read<CarListProvider>().updateSearchQuery(query),
                        decoration: InputDecoration(
                          hintText: 'Search cars...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.sort, color: Colors.white),
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          MediaQuery.of(context).size.width - 120,
                          100,
                          0,
                          0,
                        ),
                        items: [
                          PopupMenuItem(
                            value: 'Price: Low to High',
                            child: Text('Price: Low to High'),
                          ),
                          PopupMenuItem(
                            value: 'Price: High to Low',
                            child: Text('Price: High to Low'),
                          ),
                          PopupMenuItem(
                            value: 'Newest First',
                            child: Text('Newest First'),
                          ),
                          PopupMenuItem(
                            value: 'Oldest First',
                            child: Text('Oldest First'),
                          ),
                        ],
                        elevation: 8.0,
                      ).then((value) {
                        if (value != null) {
                          context.read<CarListProvider>().updateSortOption(value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<CarListProvider>(
              builder: (context, carListProvider, child) {
                return CarGrid(
                  searchQuery: carListProvider.searchQuery,
                  sortOption: carListProvider.selectedSortOption,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gpp_good_outlined),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/booking');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

class CarGrid extends StatelessWidget {
  final String searchQuery;
  final String sortOption;
  final CollectionReference carsCollection = FirebaseFirestore.instance.collection('cars');

  CarGrid({required this.searchQuery, required this.sortOption});

  @override
  Widget build(BuildContext context) {
    final carListProvider = context.read<CarListProvider>();
    final orderByQuery = carListProvider.sortedQuery;

    return StreamBuilder<QuerySnapshot>(
      stream: orderByQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cars available.'));
        }

        var filteredDocs = carListProvider.filterCars(snapshot.data!.docs);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          padding: EdgeInsets.all(10),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var carData = filteredDocs[index].data() as Map<String, dynamic>;
            var carImages = carData['images'] as List<dynamic>;
            var carBrand = carData['brand'];
            var carModel = carData['model'];
            var carCondition = carData['condition'];
            var carPrice = carData['price'];
            var carGearbox = carData['gearbox'];
            var carSeats = carData['seats'];
            var carFuelCapacity = carData['fuelCapacity'];
            var carTopSpeed = carData['topSpeed'];
            var carHourlyRent = carData['hourlyRent'];
            var carAvailableDays = carData['availableDays'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarDetailPage(
                      imageUrls: carImages.isNotEmpty ? List<String>.from(carImages) : ['assets/placeholder.png'],
                      brand: carBrand,
                      model: carModel,
                      condition: carCondition,
                      price: carPrice,
                      gearbox: carGearbox,
                      seats: carSeats,
                      fuelCapacity: carFuelCapacity,
                      topSpeed: carTopSpeed,
                      hourlyRent: carHourlyRent,
                      availableDays: carAvailableDays,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          image: DecorationImage(
                            image: carImages.isNotEmpty
                                ? NetworkImage(carImages[0])
                                : AssetImage('assets/placeholder.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$carBrand $carModel',
                            style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Condition: $carCondition',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Price: ${carPrice.toString()}/day',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => BookingPage1(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                onPrimary: Colors.white,
                                minimumSize: Size(80, 36),
                              ),
                              child: Text('Book Now', style: TextStyle(color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
