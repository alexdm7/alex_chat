import 'package:alex_chat/widgits/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';


final _fireBase=FirebaseAuth.instance;



class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  File? _selecteImage;
  var _isLogin = true;
  var _enterdEmail = '';
  var _username='';
    var _enterdPass = '';
    var _isAuthintcate=false;
  void _submit()async {
    final isVild = _form.currentState!.validate();
    if(!isVild || ! _isLogin && _selecteImage==null){
      return;
    }


      _form.currentState!.save();
    try{
      setState(() {
        _isAuthintcate=true;
      });
       if(_isLogin){
         final usercredntil=await _fireBase.signInWithEmailAndPassword(
             email: _enterdEmail, password: _enterdPass);


       }else{

           final usercredntil=await _fireBase.
           createUserWithEmailAndPassword(email: _enterdEmail, password: _enterdPass);
           final storgeRef= FirebaseStorage.instance
               .ref().child('user_images')
               .child('${usercredntil
               .user!.uid}.jpg');
           await storgeRef.putFile(_selecteImage!);
           final imageUrl=await storgeRef.getDownloadURL();
           await FirebaseFirestore
                .instance
                .collection('users')
                .doc(usercredntil
                .user!.uid).set({
             'username': _username,
             'email': _enterdEmail,
             'image_url': imageUrl
           });

       }

         }on FirebaseAuthException catch(erorr){
           if(erorr.code=='email-already-in-use'){

           }
           ScaffoldMessenger.of(context).clearSnackBars();
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
               content:Text(erorr.message??'killed') )

           );
           setState(() {
             _isAuthintcate=false;
           });


       }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(!_isLogin)
                              UserImagePicker(onPickImage: (pickedImage) {
                                _selecteImage=pickedImage;
                              },),
                            TextFormField(
                              decoration:const InputDecoration(
                                label: Text('Email'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'please use @ and make sure ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enterdEmail = value!;
                              },
                            ),
                            if(!_isLogin)
                            TextFormField(
                              decoration:const InputDecoration(
                                label: Text('username'),
                              ),

                            enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||value.isEmpty|| value.trim().length < 4) {
                                  return 'username has to be 4 ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            ),
                            TextFormField(
                              decoration:const InputDecoration(
                                label: Text('password'),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'password has to be 6 ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enterdPass = value!;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if(_isAuthintcate)
                              CircularProgressIndicator(),
                            if(!_isAuthintcate)
                            ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? 'login' : 'sign up')),
                            if(!_isAuthintcate)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'create Acount'
                                    : 'i have aredy acount')),
                          ],
                        ),
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
