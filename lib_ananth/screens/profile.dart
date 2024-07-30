import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'edit_profile.dart'; // Import the new screen

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfileScreen({required this.userData});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;
  String _dateOfBirth = "";
  List<String> _selectedDocuments = [];
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _dateOfBirth = _userData['DOB'] ?? "";
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
      }
    } catch (error) {
      print('Error selecting document: $error');
    }
  }

  void _editProfile() async {
    final updatedData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          userData: _userData,
          onUpdate: (data) {
            setState(() {
              _userData = data;
              _dateOfBirth = data['DOB'] ?? '';
            });
          },
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _userData = updatedData;
        _dateOfBirth = _userData['DOB'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
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
                        : _userData['photo'] != null
                            ? NetworkImage(_userData['photo']) as ImageProvider
                            : AssetImage('lib/assets/images/b.png') as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _handleImageUpload,
                    child: Text('Upload Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Personal Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildProfileInfo(Icons.person, _userData['name'] ?? 'Name'),
            _buildProfileInfo(Icons.email, _userData['email'] ?? 'Email'),
            _buildProfileInfo(Icons.calendar_today, _dateOfBirth),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _editProfile,
                child: Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
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
                  ..._selectedDocuments.map((doc) => _buildDocumentItem(doc)).toList(),
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
          Text(info, style: TextStyle(fontSize: 16, color: Colors.blueGrey[800])),
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
          color: Colors.blueGrey[800],
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Text(name, style: TextStyle(fontSize: 16, color: Colors.blueGrey[800])),
    );
  }
}
