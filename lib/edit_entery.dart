import 'package:flutter/material.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EditEntry extends StatefulWidget {
  final bool? add;
  final int? index;
  final JournalEdit? journalEdit;

  const EditEntry({super.key, this.add, this.index, this.journalEdit});

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit journalEdit;
  late String _title;
  late DateTime _selectedDate;
  late final TextEditingController _moodController = TextEditingController();
  late final TextEditingController _noteController = TextEditingController();
  final FocusNode _moodFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    journalEdit =
        JournalEdit(action: "Cancel", journal: widget.journalEdit!.journal);
    _title = widget.add! ? 'Add' : 'Edit';
    journalEdit.journal = widget.journalEdit!.journal;

    if (widget.add!) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(journalEdit.journal!.date);
      _moodController.text = journalEdit.journal!.mood;
      _noteController.text = journalEdit.journal!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
