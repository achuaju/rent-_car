import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'bookingviewpage.dart';

class TextFieldPage extends StatefulWidget {
  @override
  _TextFieldPageState createState() => _TextFieldPageState();
}

class _TextFieldPageState extends State<TextFieldPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController gearboxController = TextEditingController();
  TextEditingController seatsController = TextEditingController();
  TextEditingController fuelCapacityController = TextEditingController();
  TextEditingController topSpeedController = TextEditingController();
  TextEditingController hourlyRentController = TextEditingController();
  TextEditingController availableDaysController = TextEditingController();

  List<File> imageFiles = [];
  bool isSaving = false;

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        imageFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('New Car Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto', // or another font family
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextField(
                controller: brandController,
                label: 'Brand',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the brand';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: modelController,
                label: 'Model',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: conditionController,
                label: 'Condition',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the condition';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: gearboxController,
                label: 'Gearbox Type',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the gearbox type';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: seatsController,
                label: 'Number of Seats',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of seats';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: fuelCapacityController,
                label: 'Fuel Capacity (L)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the fuel capacity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: topSpeedController,
                label: 'Top Speed (km/h)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the top speed';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: hourlyRentController,
                label: 'Hourly Rent',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the hourly rent';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: availableDaysController,
                label: 'Available Days',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the available days';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  pickImages();
                },
                child: Text('Pick Images'),
              ),
              SizedBox(height: 16),
              if (imageFiles.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            imageFiles[index],
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16),
              if (isSaving)
                Center(
                  child: CircularProgressIndicator(),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      saveCarData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all the required details.'),
                        ),
                      );
                    }
                  },
                  child: Text('Save Car'),
                ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DataViewPage()),
                  );
                },
                icon: Icon(Icons.verified),
                label: Text("Bookings"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  void saveCarData() async {
    setState(() {
      isSaving = true;
    });

    String brand = brandController.text;
    String model = modelController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;
    String condition = conditionController.text;
    String gearbox = gearboxController.text;
    int seats = int.tryParse(seatsController.text) ?? 0;
    double fuelCapacity = double.tryParse(fuelCapacityController.text) ?? 0.0;
    double topSpeed = double.tryParse(topSpeedController.text) ?? 0.0;
    double hourlyRent = double.tryParse(hourlyRentController.text) ?? 0.0;
    int availableDays = int.tryParse(availableDaysController.text) ?? 0;

    List<String> imageUrls = [];
    for (File image in imageFiles) {
      String imageUrl = await uploadImage(image.path);
      imageUrls.add(imageUrl);
    }

    FirebaseFirestore.instance.collection('cars').add({
      'brand': brand,
      'model': model,
      'price': price,
      'condition': condition,
      'gearbox': gearbox,
      'seats': seats,
      'fuelCapacity': fuelCapacity,
      'topSpeed': topSpeed,
      'hourlyRent': hourlyRent,
      'availableDays': availableDays,
      'images': imageUrls,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Car data saved successfully!'),
      ));
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save car data.'),
      ));
    }).whenComplete(() {
      setState(() {
        isSaving = false;
      });
    });
  }

  Future<String> uploadImage(String imagePath) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('car_images/${DateTime.now().millisecondsSinceEpoch}.png');

    UploadTask uploadTask = storageReference.putFile(File(imagePath));

    TaskSnapshot taskSnapshot = await uploadTask;

    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }
}
