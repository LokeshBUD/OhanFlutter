import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'edit_profile.dart'; // Import the new screen
import 'calorie_tracker_page.dart'; // Import the calorie tracker page

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;
  String _dateOfBirth = "";
  List<String> _selectedDocuments = [];
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.email)
        .get();
    if (docSnapshot.exists) {
      setState(() {
        _dateOfBirth = docSnapshot.data()!['DOB'] ?? '';
      });
    }
  }

  Future<void> _handleImageUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile.path;
      });
      print('Image path: ${pickedFile.path}');
    }
  }

  Future<void> _selectDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final file = result.files.first;
        setState(() {
          _selectedDocuments.add(file.name);
        });

        await _uploadDocumentToFirestore(file.name, file.bytes);
      }
    } catch (error) {
      print('Error selecting document: $error');
    }
  }

  Future<void> _uploadDocumentToFirestore(
      String fileName, Uint8List? fileBytes) async {
    if (fileBytes == null) return;

    // Create a reference to the Firestore document
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(_user.email);

    // Check if the document already exists
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // If it exists, update the documents array
      await docRef.update({
        'documents': FieldValue.arrayUnion([fileName])
      });
    } else {
      // If it doesn't exist, create a new document with the documents array
      await docRef.set({
        'email': _user.email,
        'documents': [fileName],
      });
    }
  }

  void _editProfile() async {
    final updatedData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          userData: {
            'email': _user.email,
            'name': _user.displayName,
            'DOB': _dateOfBirth,
          },
          onUpdate: (data) {
            setState(() {
              _dateOfBirth = data['DOB'] ?? '';
            });
          },
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _dateOfBirth = updatedData['DOB'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: _image != null
                        ? FileImage(File(_image!))
                        : _user.photoURL != null
                            ? NetworkImage(_user.photoURL!) as ImageProvider
                            : AssetImage('assets/b.png') as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _handleImageUpload,
                    child: Text('Upload Image',
                        style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue[800], // Change to a tonal blue color
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Personal Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildProfileInfo(Icons.person, _user.displayName ?? 'Name'),
            _buildProfileInfo(Icons.email, _user.email ?? 'Email'),
            _buildProfileInfo(Icons.calendar_today, _dateOfBirth),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _editProfile,
                child: Text('Edit Profile',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue[800], // Change to a tonal blue color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalorieTrackerPage()),
                  );
                },
                child: Text('Calorie Tracker',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue[800], // Change to a tonal blue color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildUploadButton(),
                  ..._selectedDocuments
                      .map((doc) => _buildDocumentItem(doc))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey[700]),
          SizedBox(width: 10),
          Expanded(
            child: Text(info,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _selectDocument,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[800], // Change to a tonal blue color
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String name) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Text(name,
          style: TextStyle(fontSize: 16, color: Colors.blueGrey[800])),
    );
  }
}
