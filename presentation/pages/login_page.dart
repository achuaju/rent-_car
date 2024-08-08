import 'package:Rent_a_car/presentation/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/manager.dart';
import 'avaliblecar_screen_main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  bool isOTPSent = false;
  String verificationId = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'email': user?.email,
        'phoneNumber': user?.phoneNumber,
        'profileCompleted': false,
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CarListScreen1()), // Navigate to CarListScreen1
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'User not found';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else {
        message = 'Login failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> googleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'email': user?.email,
        'phoneNumber': user?.phoneNumber,
        'profileCompleted': false,
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CarListScreen1()), // Navigate to CarListScreen1
      );
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendOTP() async {
    setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CarListScreen1()), // Navigate to CarListScreen1
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Verification failed'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          isOTPSent = true;
          this.verificationId = verificationId;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
    );
  }

  Future<void> verifyOTP() async {
    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CarListScreen1()), // Navigate to CarListScreen1
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP verification failed'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Enter Phone Number'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      prefixText: '+91 ',
                      labelText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        // Update state if necessary
                      });
                    },
                  ),
                  if (isOTPSent)
                    TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                ],
              ),
              actions: [
                if (isOTPSent)
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            verifyOTP();
                            Navigator.of(context)
                                .pop(); // Close the dialog after verifying OTP
                          },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text('Verify OTP'),
                  )
                else
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            sendOTP();
                            setState(() {
                              isOTPSent =
                                  true; // Update state to show OTP field
                            });
                          },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text('Send OTP'),
                  ),
                if (isOTPSent)
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            sendOTP(); // Resend OTP
                            setState(() {
                              otpController.clear(); // Clear the OTP field
                            });
                          },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text('Try Again'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/car1.png',
                    width: 500,
                    height: 150,
                  ),
                  SizedBox(height: 0),
                  Text(
                    "Rent a Car",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      // or another font family
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.grey,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.black),
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
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 280,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text("Login",
                                style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          primary: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : googleSignIn,
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.google,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Sign in with Google",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary: Colors.blue,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width *
                                0.8, // 80% of screen width
                            50, // Fixed height
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _showPhoneNumberDialog,
                    child: Text(
                      isOTPSent
                          ? "Hide Mobile Number"
                          : "Sign in with Mobile Number",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PROJECT(), // Navigate to RegisterScreen
                          ),
                        );
                      },
                      child: Text("Register now?",
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Manage(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign up managing",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
