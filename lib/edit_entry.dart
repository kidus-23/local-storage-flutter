import 'package:flutter/material.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'dart:math';

/// A screen that allows the user to add or edit a single journal entry.
class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;
  const EditEntry({
    super.key,
    required this.add,
    required this.index,
    required this.journalEdit,
  });

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  /// Holds the action to perform (save or cancel) and the associated journal.
  late JournalEdit _journalEdit;

  /// Displays the title ("Add" or "Edit") based on whether we're creating or updating an entry.
  late String _title;

  /// Stores the currently selected date for this journal entry.
  late DateTime _selectedDate;

  /// Text controller for the user's mood input.
  final TextEditingController _moodController = TextEditingController();

  /// Text controller for the user's note input.
  final TextEditingController _noteController = TextEditingController();

  /// FocusNode for the mood TextField to manage keyboard focus.
  final FocusNode _moodFocus = FocusNode();

  /// FocusNode for the note TextField to manage keyboard focus.
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    /// Initialize fields and controllers depending on add/edit mode.
    _journalEdit = JournalEdit(action: 'Cancel', journal: widget.journalEdit.journal);
    _title = widget.add ? 'Add' : 'Edit';
    _journalEdit.journal = widget.journalEdit.journal;
    if (widget.add) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(_journalEdit.journal.date!);
      _moodController.text = _journalEdit.journal.mood!;
      _noteController.text = _journalEdit.journal.note!;
    }
  }

  @override
  void dispose() {
    /// Clean up controllers and focus nodes to prevent memory leaks.
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  /// Shows a calendar date picker and updates [_selectedDate] if a date was chosen.
  Future<DateTime> _selectDate(DateTime selectedDate) async {
    DateTime initialDate = selectedDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
        initialDate.second,
        initialDate.millisecond,
        initialDate.microsecond,
      );
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the UI for creating or editing a journal entry.
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Entry',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Card(
                // Card holding all the user input fields
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Column grouping mood and note input widgets
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ElevatedButton to select a date for the entry
                      ElevatedButton.icon(
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime pickerDate = await _selectDate(_selectedDate);
                          setState(() {
                            _selectedDate = pickerDate;
                          });
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat.yMMMEd().format(_selectedDate)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // TextField to capture mood data
                      TextField(
                        controller: _moodController, // Manages the text input
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        focusNode: _moodFocus, // Manages the focus state
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'How are you feeling?',
                          prefixIcon: Icon(Icons.mood,
                              color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (submitted) {
                          FocusScope.of(context).requestFocus(_noteFocus); // Moves focus to the note TextField
                        },
                      ),
                      const SizedBox(height: 24),
                      // TextField to capture notes or thoughts
                      TextField(
                        controller: _noteController, // Manages the text input
                        textInputAction: TextInputAction.newline,
                        focusNode: _noteFocus, // Manages the focus state
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Write your thoughts...',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.subject,
                              color: Theme.of(context).primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                // Row for cancel and save actions
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Button to cancel changes
                  TextButton.icon(
                    onPressed: () {
                      _journalEdit.action = 'Cancel';
                      Navigator.pop(context, _journalEdit);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Button to save changes
                  ElevatedButton.icon(
                    onPressed: () {
                      _journalEdit.action = 'Save';
                      String? id = widget.add
                          ? Random().nextInt(999999).toString()
                          : _journalEdit.journal.id;
                      _journalEdit.journal = Journal(
                        id: id,
                        date: _selectedDate.toString(),
                        mood: _moodController.text,
                        note: _noteController.text,
                      );
                      Navigator.pop(context, _journalEdit);
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
