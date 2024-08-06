import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Add device_info_plus package for device info

class ArticleFormPage extends StatefulWidget {
  const ArticleFormPage({super.key});

  @override
  _ArticleFormPageState createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _author;
  DateTime? _publishedDate;
  String? _pdfFileName;
  bool permissionGranted = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _getStoragePermission();
  }

  Future<void> _getStoragePermission() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+
      final status = await Permission.photos.request();
      if (status.isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        setState(() {
          permissionGranted = false;
        });
      }
    } else {
      // Android < 13
      final status = await Permission.storage.request();
      if (status.isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        setState(() {
          permissionGranted = false;
        });
      }
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _publishedDate) {
      setState(() {
        _publishedDate = pickedDate;
      });
    }
  }

  Future<void> _pickPDF() async {
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required.')),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = result.files.first;
        setState(() {
          _pdfFileName = file.name;
        });
        print('File selected: ${file.name}');
      } else {
        print('No file selected.');
      }
    } catch (error) {
      print('Error selecting document: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Article'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Article Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the article title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Article Author',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the article author';
                  }
                  return null;
                },
                onSaved: (value) {
                  _author = value;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _publishedDate == null
                          ? 'No date chosen!'
                          : 'Published Date: ${_dateFormat.format(_publishedDate!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Choose Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _pdfFileName == null ? 'No file chosen!' : 'PDF: $_pdfFileName',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickPDF,
                    child: const Text('Upload PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    // Process the input data here
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
