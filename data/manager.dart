import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../presentation/pages/sign_in.dart';
import 'adding.dart';
import 'edite.dart';

import '../users_pages/carscreen.dart';

class Manage extends StatefulWidget {
  @override
  State<Manage> createState() => _Manage(); //hi
}

class _Manage extends State<Manage> {
  String email = '';
  String password = '';

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => CarListScree()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect password'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => CarListScree()),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 100, // Adjust the size of the icon here
                    color: Colors.black,
                  ),
                  Text(
                    "Rent_a_car ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        onChanged: (value) {},
                        controller: emailController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          labelText: "Email",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        onChanged: (value) {},
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.remove_red_eye),
                          border: OutlineInputBorder(),
                          labelText: "Password",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: login,
                        child: Text("Login"),
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(), primary: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: signInWithGoogle,
                        child: Text("Login with Google"),
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(), primary: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
