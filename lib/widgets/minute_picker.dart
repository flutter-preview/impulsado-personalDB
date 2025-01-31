import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class MinutePicker extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int initialValue;

  MinutePicker({required this.onChanged, required this.initialValue});

  @override
  _MinutePickerState createState() => _MinutePickerState();
}

class _MinutePickerState extends State<MinutePicker> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      value: _currentValue,
      minValue: 0,
      maxValue: 200,
      step: 5,
      onChanged: (value) {
        setState(() {
          _currentValue = value;
        });
        widget.onChanged(value);
      },
    );
  }
}