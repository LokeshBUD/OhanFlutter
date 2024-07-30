import 'package:flutter/material.dart';
import 'confirmation.dart';

class ConsultationScreen extends StatefulWidget {
  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String? _selectedAppointmentType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultation Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              SizedBox(height: 16.0),
              _buildEmailField(),
              SizedBox(height: 16.0),
              _buildDateField(context),
              SizedBox(height: 16.0),
              _buildTimeField(context),
              SizedBox(height: 16.0),
              _buildAppointmentTypeDropdown(),
              SizedBox(height: 16.0),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: "Patient's Name",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter the patient's name";
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Date',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          setState(() {
            _timeController.text = pickedTime.format(context);
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Time',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildAppointmentTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAppointmentType,
      decoration: InputDecoration(
        labelText: 'Appointment Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.event),
      ),
      items: [
        DropdownMenuItem(value: 'First Time', child: Text('First Time')),
        DropdownMenuItem(value: 'Regular Checkup', child: Text('Regular Checkup')),
        DropdownMenuItem(value: 'Follow Up', child: Text('Follow Up')),
        DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAppointmentType = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an appointment type';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            String name = _nameController.text;
            String email = _emailController.text;
            String date = _dateController.text;
            String time = _timeController.text;
            String appointmentType = _selectedAppointmentType ?? '';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmationPage(
                  name: name,
                  email: email,
                  date: date,
                  time: time,
                  appointmentType: appointmentType,
                ),
              ),
            );
          }
        },
        child: Text('Submit'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
