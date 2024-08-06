import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onUpdate;

  EditProfileScreen({required this.userData, required this.onUpdate});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _changePassword = false;
  String _password = '';
  String _repeatPassword = '';
  String _name = '';
  String _email = '';
  String _dateOfBirth = '';

  @override
  void initState() {
    super.initState();
    _name = widget.userData['name'] ?? '';
    _email = widget.userData['email'] ?? '';
    _dateOfBirth = widget.userData['DOB'] ?? '';
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    if (_dateOfBirth.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dateOfBirth);
      } catch (e) {
        // If parsing fails, use the current date
      }
    }
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (newDate != null && newDate != initialDate) {
      setState(() {
        _dateOfBirth = "${newDate.toLocal().toIso8601String().split('T')[0]}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your name',
                ),
                onSaved: (value) => _name = value ?? '',
              ),
              SizedBox(height: 20),
              Text('Email', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email',
                ),
                onSaved: (value) => _email = value ?? '',
              ),
              SizedBox(height: 20),
              Text('Date of Birth', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: _dateOfBirth),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select your date of birth',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _changePassword,
                    onChanged: (value) {
                      setState(() {
                        _changePassword = value ?? false;
                      });
                    },
                  ),
                  Text('Change Password'),
                ],
              ),
              if (_changePassword) ...[
                SizedBox(height: 20),
                Text('New Password', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter new password',
                  ),
                  onSaved: (value) => _password = value ?? '',
                ),
                SizedBox(height: 20),
                Text('Repeat Password', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Repeat new password',
                  ),
                  onSaved: (value) => _repeatPassword = value ?? '',
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_changePassword && _password != _repeatPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      // Handle profile update logic here
      final updatedData = {
        'name': _name,
        'email': _email,
        'DOB': _dateOfBirth,
        // Include other updated fields if necessary
      };

      widget.onUpdate(updatedData);

      // Navigate back to the profile screen
      Navigator.pop(context);
    }
  }
}
