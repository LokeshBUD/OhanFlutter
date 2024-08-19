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
  bool _isFilePickerActive = false;  // Initialize the list

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
        _dateOfBirth = docSnapshot.data()?['DOB'] ?? ''; // Fetch DOB if it exists
        _selectedDocuments = List<String>.from(docSnapshot.data()?['documents'] ?? []); // Fetch documents if they exist
      });

      // Check if DOB field exists, if not, create it
      if (_dateOfBirth.isEmpty) {
        await docRef.update({'DOB': ''});
      }
    } else {
      // If the document doesn't exist, create it with the DOB field
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

        // Update the photoURL in FirebaseAuth
        await _user.updatePhotoURL(downloadUrl);

        // Update the photo field in Firestore
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
          _selectedDocuments.add(fileName);
        });

        await _uploadDocumentToFirestore(fileName, fileBytes);
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


Future<void> _uploadDocumentToFirestore(String fileName, Uint8List? fileBytes) async {
  if (fileBytes == null) {
    print('No file bytes found. Aborting upload.');
    return;
  }

  try {
    print('Starting upload for: $fileName');
    
    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('users/${_user.email}/$fileName');

    // Upload the file to Firebase Storage
    final uploadTask = storageRef.putData(fileBytes);

    // Listen to the upload status
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Upload in progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
    });

    // Wait for the upload to complete
    final snapshot = await uploadTask.whenComplete(() {});

    // Get the download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print('File uploaded successfully. Download URL: $downloadUrl');

    // Create a reference to the Firestore document
    final docRef = FirebaseFirestore.instance.collection('users').doc(_user.email);

    // Check if the document already exists
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // If it exists, update the documents array with the download URL
      await docRef.update({
        'documents': FieldValue.arrayUnion([downloadUrl])
      });
    } else {
      // If it doesn't exist, create a new document with the documents array
      await docRef.set({
        'email': _user.email,
        'documents': [downloadUrl],
      });
    }
    
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
        _user.updateDisplayName(updatedData['name']); // Update the user's display name in FirebaseAuth
      });

      // Update the user's data in Firestore
      await _updateUserProfileInFirestore(updatedData);
    }
  }

  Future<void> _updateUserProfileInFirestore(Map<String, dynamic> updatedData) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(_user.email);

    await userRef.set({
      'name': updatedData['name'] ?? _user.displayName,
      'DOB': updatedData['DOB'] ?? _dateOfBirth, // Ensure DOB is included
    }, SetOptions(merge: true));  // Use merge to only update the fields passed
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
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                child: Text('Logout', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Use red color for logout
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            child: Text(info.isNotEmpty ? info : 'Not Provided',
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
      child: Text(name, style: TextStyle(fontSize: 16, color: Colors.blueGrey[800])),
    );
  }
}
