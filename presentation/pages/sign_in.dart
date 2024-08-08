import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';

class PROJECT extends StatefulWidget {
  @override
  State<PROJECT> createState() => _PROJECTState();
}

class _PROJECTState extends State<PROJECT> {
  final _formKey = GlobalKey<FormState>(); // Key for the Form widget

  CollectionReference fire = FirebaseFirestore.instance.collection('project');

  void add() async {
    await fire.add({
      "name": anamecnt.text,
      "mobilenumber": banamecnt.text,
      "password": dnamecnt.text,
      "email": cnamecnt.text,
    }).then((value) {
      print("Data added");
    });
  }

  Future<void> authenticate() async {
    if (_formKey.currentState!.validate()) { // Validate all fields
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cnamecnt.text,
          password: dnamecnt.text,
        );
        // User registered successfully
        print('User registered: ${userCredential.user!.uid}');
        add();  // Add user data to Firestore

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 10),
                Text('Registered successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login page
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => LoginScreen(), // Assuming LoginPage is the login page
            ),
          );
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e.toString());
      }
    } else {
      // Show error message if form validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Complete all fields'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  var anamecnt = TextEditingController();
  var banamecnt = TextEditingController();
  var cnamecnt = TextEditingController();
  var dnamecnt = TextEditingController();
  var enamecnt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[300],

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Assign the form key here
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Image.asset(
                      'assets/images/car1.png',
                      width: 200,
                      height: 170,
                    ),
                    SizedBox(height: 30),
                    buildTextField(anamecnt, Icons.person_add_alt_1_outlined, "Name", "Please enter your name"),
                    SizedBox(height: 15),
                    buildTextField(dnamecnt, Icons.password, "Password", "Please enter your password", obscureText: true),
                    SizedBox(height: 15),
                    buildTextField(banamecnt, Icons.mobile_friendly_outlined, "Mobile Number", "Please enter your mobile number", keyboardType: TextInputType.number),
                    SizedBox(height: 15),
                    buildTextField(cnamecnt, Icons.email, "Email", "Please enter your email", keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 30),
                    buildElevatedButton("Save", authenticate),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextField(TextEditingController controller, IconData icon, String labelText, String validationMessage, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      style: TextStyle(color: Colors.white), // Change text color to white
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.9), // Change fill color to white with some opacity
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero, // Remove rounded corners
          borderSide: BorderSide.none, // Remove border
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Add padding to make it look like a box
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage; // Show validation message
        }
        return null;
      },
    );
  }

  ElevatedButton buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.white), // Change text color to white
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Change button shape to box-like
        ),
        primary: Colors.black, // Change button color to black
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
