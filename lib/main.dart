import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laba3/phone_contact.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];
  String createAt(doc) {
    late DateTime createdAt;
    FirebaseFirestore.instance.collection('users').doc(doc).get().then((value) {
      createdAt = value.data()?['createdAt'];
    });
    return createdAt.toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('No elements');
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(snapshot.data!.docs[index].id),
                child: ListTile(
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditUserPage(snapshot.data?.docs[index])));
                    },
                  ),
                  title: Text(
                      '${snapshot.data?.docs[index].get('id')} \n'
                      '${snapshot.data?.docs[index].get('lastname')} \n'
                      '${snapshot.data?.docs[index].get('firstname')} \n'
                      '${snapshot.data?.docs[index].get('middlename')}\n'
                      '(${snapshot.data?.docs[index].get('datecreate')})'
                  ),

                ),
                onDismissed: (direction){
                  FirebaseFirestore.instance.collection('users').doc(snapshot.data!.docs[index].id).delete();
                },
              );
            },

          );
        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserPage()));
        },
        child: Icon(Icons.add),

      ),
    );
  }
}

class EditUserPage extends StatelessWidget {
  late var doc;
  EditUserPage(doc) {
    this.doc = doc;
    firstnamecontroller = TextEditingController(text: doc.get('firstname'));
    lastnamecontroller = TextEditingController(text: doc.get('lastname'));
    middlenamecontroller = TextEditingController(text: doc.get('middlename'));
  }

  late TextEditingController firstnamecontroller;
  late TextEditingController lastnamecontroller;
  late TextEditingController middlenamecontroller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(controller:lastnamecontroller,),
            TextFormField(controller: firstnamecontroller,),
            TextFormField(controller: middlenamecontroller,),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (){
              FirebaseFirestore.instance.collection('users').doc(doc.id).update({
                'lastname' : lastnamecontroller.text.trim(),
                'firstname' : firstnamecontroller.text.trim(),
                'middlename' : middlenamecontroller.text.trim(),
              });
              Navigator.pop(context);
            }, child: Text("Update"))
          ],
        ),
      ),
    );
  }
}

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {

  TextEditingController firstnamecontroller = TextEditingController();
  TextEditingController lastnamecontroller = TextEditingController();
  TextEditingController middlenamecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(controller: firstnamecontroller,),
            TextFormField(controller: lastnamecontroller,),
            TextFormField(controller: middlenamecontroller,),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (){
              Uuid uuid = Uuid();
              var id = uuid.v4();
              FirebaseFirestore.instance.collection('users').doc(id)
                  .set({
                'id': id,
                'lastname': firstnamecontroller.text.trim(),
                'firstname': lastnamecontroller.text.trim(),
                'middlename': middlenamecontroller.text.trim(),
                'datecreate' : DateTime.now().toString(),
              });
              Navigator.pop(context);
            }, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}