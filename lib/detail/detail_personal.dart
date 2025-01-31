import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/trust_counter.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_personal.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';
import 'package:personaldb/widgets/date_picker.dart';

class PersonalDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  PersonalDetailPage(this.myCategory, {this.id});

  @override
  _PersonalDetailPageState createState() => _PersonalDetailPageState();
}

class _PersonalDetailPageState extends State<PersonalDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _trustController = TextEditingController();

  bool _isLoading = true;

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      DateTime date = DateTime.tryParse(_dateController.text) ?? DateTime.now();
      String formattedDate = _dateFormatter.format(date);
      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "date": formattedDate,
        "type": _typeController.text,
        "trust": _trustController.text
      };
      print("Data to save: $data");
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data);
      } else {
        await dbHelper.createItem(data);
      }
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _typeController.clear();
      _trustController.clear();
      Navigator.pop(context, "refresh");
    } else {
      print("No entro");
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!);
      if (items.isNotEmpty) {
        print("Loaded item: ${items[0]}");
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _descriptionController.text = items[0]["description"] ?? "";
          _dateController.text = items[0]["date"] ?? "";
          _typeController.text = items[0]["type"] ?? "";
          _trustController.text = items[0]["trust"] ?? "";
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.myCategory.bgColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyInputField(
                          title: "Title",
                          hint: "Enter title here.",
                          controller: _titleController,
                          height: 50),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: FieldAutocomplete(
                              controller: _typeController,
                              label: "Type",
                              dbHelper: PersonalDatabaseHelper(),
                              loadItemsFunction: () async {
                                return await PersonalDatabaseHelper().getTypes();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: CupertinoDatePickerField(
                              controller: _dateController,
                              dateFormatter: _dateFormatter,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyInputField(
                          title: "Description",
                          hint: "Enter description here.",
                          controller: _descriptionController,
                          height: 200
                      ),
                      const SizedBox(height: 27),
                      Text("Trust", style: subHeadingStyle(color: Colors.black)),
                      const SizedBox(height: 5),
                      Center(
                        child: TrustCounter(controller: _trustController),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MyButton(
        key: ValueKey("personal"),
        label: "Submit",
        onTap: () => _submitNote(context),
        bgColor: widget.myCategory.bgColor ?? Colors.black,
        iconColor: widget.myCategory.iconColor ?? Colors.white,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: widget.myCategory.bgColor,
      elevation: 0,
      title: Text(
        widget.myCategory.title ?? "Error",
        style: const TextStyle(color: Colors.black),
      ),
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}