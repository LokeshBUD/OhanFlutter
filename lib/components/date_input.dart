import 'package:flutter/material.dart';

class DateInput extends StatefulWidget {
  final DateTime? selectedDate;
  final void Function()? onTap;

  DateInput({required this.selectedDate, required this.onTap});

  @override
  _DateInputState createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AbsorbPointer(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.selectedDate == null
                      ? 'DOB'
                      : '${widget.selectedDate!.month}/${widget.selectedDate!.day}/${widget.selectedDate!.year}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                height: 1,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
