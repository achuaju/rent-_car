import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edite.dart';

class CarListScree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: CarList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TextFieldPage()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }
}

class CarList extends StatelessWidget {
  final CollectionReference carsCollection = FirebaseFirestore.instance.collection('cars');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: carsCollection.snapshots(),
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

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var carData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var carId = snapshot.data!.docs[index].id;
            var carImages = carData['images'];
            var carBrand = carData['brand'];
            var carModel = carData['model'];
            var carCondition = carData['condition'];
            var carPrice = carData['price'];

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      carImages.isNotEmpty ? carImages[0] : '',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$carBrand $carModel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Condition: $carCondition'),
                          Text('Price: \$${carPrice.toString()}'),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CarEditScree(
                                        carId: carId,
                                        initialBrand: carBrand,
                                        initialModel: carModel,
                                        initialPrice: carPrice,
                                        initialCondition: carCondition,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Delete'),
                                        content: Text('Are you sure you want to delete this car?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              primary: Colors.deepPurple,
                                            ),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              carsCollection.doc(carId).delete();
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              primary: Colors.deepPurple,
                                            ),
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Delete'),
                              ),
                            ],
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

class CarEditScree extends StatefulWidget {
  final String carId;
  final String initialBrand;
  final String initialModel;
  final double initialPrice;
  final String initialCondition;

  CarEditScree({
    required this.carId,
    required this.initialBrand,
    required this.initialModel,
    required this.initialPrice,
    required this.initialCondition,
  });

  @override
  _CarEditScreeState createState() => _CarEditScreeState();
}

class _CarEditScreeState extends State<CarEditScree> {
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _priceController;
  late TextEditingController _conditionController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.initialBrand);
    _modelController = TextEditingController(text: widget.initialModel);
    _priceController = TextEditingController(text: widget.initialPrice.toString());
    _conditionController = TextEditingController(text: widget.initialCondition);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Car'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _brandController, decoration: InputDecoration(labelText: 'Brand')),
            TextField(controller: _modelController, decoration: InputDecoration(labelText: 'Model')),
            TextField(controller: _conditionController, decoration: InputDecoration(labelText: 'Condition')),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price')),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final carsCollection = FirebaseFirestore.instance.collection('cars');
                await carsCollection.doc(widget.carId).update({
                  'brand': _brandController.text,
                  'model': _modelController.text,
                  'condition': _conditionController.text,
                  'price': double.parse(_priceController.text),
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _brandController = TextEditingController();
    TextEditingController _modelController = TextEditingController();
    TextEditingController _conditionController = TextEditingController();
    TextEditingController _priceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Add New Car'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _brandController, decoration: InputDecoration(labelText: 'Brand')),
            TextField(controller: _modelController, decoration: InputDecoration(labelText: 'Model')),
            TextField(controller: _conditionController, decoration: InputDecoration(labelText: 'Condition')),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price')),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final carsCollection = FirebaseFirestore.instance.collection('cars');
                await carsCollection.add({
                  'brand': _brandController.text,
                  'model': _modelController.text,
                  'condition': _conditionController.text,
                  'price': double.parse(_priceController.text),
                  'images': [], // Add appropriate image upload logic here
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(primary: Colors.black),
              child: Text('Add Car'),
            ),
          ],
        ),
      ),
    );
  }
}
