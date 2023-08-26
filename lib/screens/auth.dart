import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  //Declaring variables
  var _isLogin = true;
  var _isAuthanticated = false;
  var enteredEmail = '';
  var enteredPassword = '';
  var enteredUsername = '';
  File? _selectedImage;
  final form_key = GlobalKey<FormState>();

  void _launchURL() async {
    Uri _url = Uri.parse('https://www.linkedin.com/in/atharv-karne/');
    if (await launchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

  void _launchURLGT() async {
    Uri _url = Uri.parse('https://github.com/Its-Lord-Stark');
    if (await launchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

//Function that submit data to firebase
  void _submit() async {
    final _isvalid = form_key.currentState!.validate();

    if (!_isvalid || !_isLogin && _selectedImage == null) {
      return;
    }

    //Save current state of form
    form_key.currentState!.save();
    //try block for authentication

    try {
      setState(() {
        //Using logic for showing progress indicator
        _isAuthanticated = true;
      });

      //Authentication process
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        //Storing profile image to firebase storage and getting URl
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child("${userCredentials.user!.uid}.jpg");

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        //Storing user data to firebasefirestor db
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUsername,
          'email': enteredEmail,
          'image_URL': imageUrl
        });

        setState(() {
          _isAuthanticated = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white, //Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('lib/assets/images/login.png'),
                  fit: BoxFit.cover)),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('lib/assets/images/new.png'),
                ),
                if (_isLogin)
                  const SizedBox(
                    height: 10,
                  ),
                Card(
                  elevation: 0,
                  color: const Color.fromARGB(0, 255, 255, 255),
                  // color: Colors.white,

                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: form_key,
                            child: Column(
                              children: [
                                if (!_isLogin)
                                  Container(
                                    child: UserImagePicker(
                                        onPickedImage: (pickedImage) {
                                      _selectedImage = pickedImage;
                                    }),
                                  ),
                                if (!_isLogin)
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      labelText: 'Username',
                                    ),
                                    keyboardType: TextInputType.streetAddress,
                                    enableSuggestions: false,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().length < 4) {
                                        return;
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      enteredUsername = newValue!;
                                    },
                                  ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    labelText: 'Email Address',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@')) {
                                      return 'Please Enter correct value';
                                    }

                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    enteredEmail = newValue!;
                                  },
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    labelText: 'Password',
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      return 'Please Enter Valid Password';
                                    }

                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    enteredPassword = newValue!;
                                  },
                                ),
                                if (_isAuthanticated)
                                  const CircularProgressIndicator(),
                                if (!_isAuthanticated)
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 84, 190, 243)),
                                    onPressed: _submit,
                                    child: Text(
                                      _isLogin ? 'Login' : 'Signup',
                                      style: TextStyle(color: Colors.black , fontSize: 15,fontWeight: FontWeight.bold),
                                    )),
                                if (!_isAuthanticated)
                                  if (_isLogin)
                                    const SizedBox(
                                      height: 8,
                                    ),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                      child: Text(
                                        _isLogin
                                            ? 'Create an account'
                                            : 'Already have account',
                                        style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 15),
                                      ),
                                    ),
                                if (_isLogin)
                                  const SizedBox(
                                    height: 85,
                                  ),
                                if (_isLogin) const Text("Having any issues?"),
                                if (_isLogin) const Text("Feel welcome to inquire"),
                                if (_isLogin)
                                  InkWell(
                                    onTap: _launchURL,
                                    child: const Text(
                                      'Linkdein',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue,
                                        // decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                if (_isLogin)
                                  InkWell(
                                    onTap: _launchURLGT,
                                    child: const Text(
                                      'GitHub',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue,
                                        // decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
