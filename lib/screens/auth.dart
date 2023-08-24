import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

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
      backgroundColor: Colors.white, //Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('lib/assets/images/cream.jpg'),
                  fit: BoxFit.cover)),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('lib/assets/images/ch.png'),
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                Card(
                  elevation: 0,
                  color: Colors.transparent,
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: form_key,
                            child: Column(
                              children: [
                                if (!_isLogin)
                                  UserImagePicker(onPickedImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                    
                                  }),
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
                                    height: 20,
                                  ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 244, 201, 123)),
                                    onPressed: _submit,
                                    child: Text(
                                      _isLogin ? 'Login' : 'Signup',
                                      style: TextStyle(color: Colors.black),
                                    )),
                                if (!_isAuthanticated)
                                  const SizedBox(
                                    height: 12,
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
                                      style: TextStyle(color: Colors.black),
                                    ))
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
