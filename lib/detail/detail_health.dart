import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_health.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';

class HealthDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  HealthDetailPage(this.myCategory, {this.id});

  @override
  _HealthDetailPageState createState() => _HealthDetailPageState();
}

class _HealthDetailPageState extends State<HealthDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;

  _submitNote(BuildContext context) async {
    print("submit");
    if (_titleController.text.isNotEmpty) {
      print("Type: ${_typeController.text}");
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "type": _typeController.text
      };
      print("Data to save: $data");
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data);
      } else {
        await dbHelper.createItem(data);
      }
      _titleController.clear();
      _descriptionController.clear();
      _typeController.clear();
      Navigator.pop(context, "refresh");
    } else {
      print("no entro");
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!);
      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _descriptionController.text = items[0]["description"] ?? "";
          _typeController.text = items[0]["type"] ?? "";
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
                      FieldAutocomplete(
                        controller: _typeController,
                        label: "Category",
                        dbHelper: HealthDatabaseHelper(),
                        loadItemsFunction: () async {
                          return await HealthDatabaseHelper().getTypes();
                        },
                      ),
                      const SizedBox(height: 10),
                      MyInputField(
                          title: "Description",
                          hint: "Enter description here.",
                          controller: _descriptionController,
                          height: 200),
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
        label: "Submit",
        onTap: () => _submitNote(context),
        bgColor: widget.myCategory.bgColor ?? Colors.black,
        iconColor: Colors.black,
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
