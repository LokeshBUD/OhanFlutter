import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'edit_profile.dart';
import 'calorie_tracker_page.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  ProfileScreen({Key? key, this.userData}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String? _image;
  late String _dateOfBirth;
  late User _user;
  List<String> _selectedDocuments = [];
  List<Map<String, dynamic>> _newDocuments = []; // To store selected documents before submission
  bool _isFilePickerActive = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _image = widget.userData?['photo'];
    _dateOfBirth = widget.userData?['DOB'] ?? '';
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(_user.email);
    final docSnapshot = await docRef.get();
    
    if (docSnapshot.exists) {
      setState(() {
        _dateOfBirth = docSnapshot.data()?['DOB'] ?? ''; 
        _selectedDocuments = List<String>.from(docSnapshot.data()?['documents'] ?? []); 
      });

      if (_dateOfBirth.isEmpty) {
        await docRef.update({'DOB': ''});
      }
    } else {
      await docRef.set({
        'email': _user.email,
        'DOB': '',
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

      try {
        final storageRef = FirebaseStorage.instance.ref().child('users/${_user.email}/profile_image');
        final uploadTask = storageRef.putFile(File(_image!));
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await _user.updatePhotoURL(downloadUrl);
        final docRef = FirebaseFirestore.instance.collection('users').doc(_user.email);
        await docRef.update({'photo': downloadUrl});

        print('Image uploaded and reference updated in Firestore: $downloadUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _selectDocument() async {
    if (_isFilePickerActive) {
      print('File picker is already active.');
      return;
    }

    setState(() {
      _isFilePickerActive = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(withData: true);

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileBytes = file.bytes;

        if (fileBytes == null) {
          print('No file bytes found. Aborting upload.');
          return;
        }

        setState(() {
          _newDocuments.add({'name': fileName, 'bytes': fileBytes});
        });
      } else {
        print('No file selected.');
      }
    } catch (error) {
      print('Error selecting document: $error');
    } finally {
      setState(() {
        _isFilePickerActive = false;
      });
    }
  }
  

  Future<void> _deleteDocument(String docUrl) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(docUrl);
      await storageRef.delete(); // Delete from Firebase Storage

      final docRef = FirebaseFirestore.instance.collection('users').doc(_user.email);
      await docRef.update({
        'documents': FieldValue.arrayRemove([docUrl])
      });

      setState(() {
        _selectedDocuments.remove(docUrl); // Remove from local list
      });

      print('Document deleted successfully.');
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  Future<void> _submitDocuments() async {
    for (var doc in _newDocuments) {
      await _uploadDocumentToFirestore(doc['name'], doc['bytes']);
    }

    setState(() {
      _newDocuments.clear(); // Clear the list after submission
    });
  }

  Future<void> _uploadDocumentToFirestore(String fileName, Uint8List? fileBytes) async {
    if (fileBytes == null) {
      print('No file bytes found. Aborting upload.');
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('users/${_user.email}/$fileName');
      final uploadTask = storageRef.putData(fileBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final docRef = FirebaseFirestore.instance.collection('users').doc(_user.email);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          'documents': FieldValue.arrayUnion([downloadUrl])
        });
      } else {
        await docRef.set({
          'email': _user.email,
          'documents': [downloadUrl],
        });
      }

      setState(() {
        _selectedDocuments.add(downloadUrl);
      });

      print('Document updated successfully in Firestore.');
    } catch (error) {
      print('Error uploading document: $error');
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
        _user.updateDisplayName(updatedData['name']);
      });

      await _updateUserProfileInFirestore(updatedData);
    }
  }

  Future<void> _updateUserProfileInFirestore(Map<String, dynamic> updatedData) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(_user.email);

    await userRef.set({
      'name': updatedData['name'] ?? _user.displayName,
      'DOB': updatedData['DOB'] ?? _dateOfBirth,
    }, SetOptions(merge: true));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
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
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalorieTrackerPage()),
                  );
                },
                child: Text('Calorie Tracker',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // List of selected documents
            ..._selectedDocuments.map((docUrl) {
              return ListTile(
                title: Text(docUrl.split('/').last), // Display the file name
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteDocument(docUrl),
                ),
              );
            }).toList(),
            // List of newly selected documents (not yet uploaded)
            ..._newDocuments.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _newDocuments.remove(doc);
                    });
                  },
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _selectDocument,
                child: Text('Select Document',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitDocuments,
                child: Text('Submit Documents',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                child: Text('Logout',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey[800]),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}