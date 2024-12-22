import 'package:flutter/material.dart';
import 'database.dart';
import 'package:intl/intl.dart';

class EditEntry extends StatefulWidget {
  final bool? add;
  final int? index;
  final JournalEdit journalEdit;

  const EditEntry(
      {super.key,
      required this.add,
      required this.index,
      required this.journalEdit});

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit _journalEdit;
  late String _title;
  late DateTime _selectedDate;
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _moodFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _journalEdit = JournalEdit(
      action: 'Cancel',
      journal: widget.journalEdit.journal,
    );
    _title = widget.add! ? 'Add' : 'Edit';

    if (widget.add!) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(_journalEdit.journal!.date);
      _moodController.text = _journalEdit.journal!.mood;
      _noteController.text = _journalEdit.journal!.note;
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    super.dispose(); // Call the overridden method
  }

  Future<DateTime> _selectDate(DateTime selectedDate) async {
    /// The initial date that is shown in the dialog.
    DateTime initialDate = selectedDate;

    /// The date that the user selected.
    final DateTime? selectDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    /// Return the date that the user selected, or the initial date if
    /// the user did not select a date.
    if (selectDate != null) {
      return DateTime(
          selectDate.year,
          selectDate.month,
          selectDate.day,
          initialDate.hour,
          initialDate.minute,
          initialDate.second,
          initialDate.millisecond,
          initialDate.microsecond);
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Entry'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime pickerDate = await _selectDate(_selectedDate);
                  setState(() {
                    _selectedDate = pickerDate;
                  });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 40,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 30),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
              TextField(
                controller: _moodController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                focusNode: _moodFocus,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  hintText: 'Enter your mood',
                  icon: Icon(Icons.mood),
                ),
                onSubmitted: (submitted) {
                  FocusScope.of(context).requestFocus(_noteFocus);
                },
              ),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.done,
                focusNode: _noteFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Enter your note',
                  icon: Icon(Icons.note),
                ),
                onSubmitted: (submitted) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          _journalEdit.action = 'Save';
          _journalEdit.journal = Journal(
            id: widget.journalEdit.journal!.id,
            date: _selectedDate.toString(),
            mood: _moodController.text,
            note: _noteController.text,
          );
          Navigator.pop(context, _journalEdit);
        },
      ),
    );
  }
}
