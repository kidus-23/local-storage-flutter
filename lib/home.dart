import 'package:flutter/material.dart';
import 'edit_entry.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; 

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Database _database;

  Future<List<Journal>> _loadJournals() async {
    final journalJson = await DatabaseFileRoutine().readJournals();
    _database = Database.fromJson(json.decode(journalJson));
    _database.journals.sort((a, b) => b.date!.compareTo(a.date!));
    return _database.journals;
  }

  @override
  void initState() {
    super.initState();
    _loadJournals().then((_) => setState(() {}));
  }

  void addOrEditJournal({
    required bool add,
    required int index,
    required Journal journal,
  }) async {
    JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
    _journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntry(
          add: add,
          index: index,
          journalEdit: _journalEdit,
        ),
        fullscreenDialog: true,
      ),
    );
    switch (_journalEdit.action) {
      case 'Save':
        setState(() {
          if (add) {
            _database.journals.add(_journalEdit.journal);
          } else {
            _database.journals[index] = _journalEdit.journal;
          }
        });
        DatabaseFileRoutine()
            .writeJournals(json.encode(_database.toJson()));
        break;
      case 'Cancel':
        break;
    }
  }

  Widget _buildListViewSeparated(AsyncSnapshot<List<Journal>> snapshot) {
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Text(
          'No entries yet. Tap + to add one!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, int index) {
        final journal = snapshot.data![index];
        final date = DateTime.parse(journal.date!);

        return Dismissible(
          key: Key(journal.id!),
          background: Container(
            color: Colors.red[400],
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red[400],
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: InkWell(
            onTap: () => addOrEditJournal(
              add: false,
              index: index,
              journal: journal,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateColumn(date),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEntryDetails(journal, date),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _database.journals.removeAt(index);
            });
            DatabaseFileRoutine()
                .writeJournals(json.encode(_database.toJson()));
          },
        );
      },
    );
  }

  Widget _buildDateColumn(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Text(
            DateFormat.d().format(date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            DateFormat.E().format(date),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryDetails(Journal journal, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMEd().format(date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (journal.mood?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            journal.mood!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (journal.note?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            journal.note!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        elevation: 1,
      ),
      body: FutureBuilder<List<Journal>>(
        initialData: const [],
        future: _loadJournals(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildListViewSeparated(snapshot);
        },
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: EdgeInsets.all(32.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        onPressed: () => addOrEditJournal(
          add: true,
          index: -1,
          journal: Journal(
            id: '',
            date: DateTime.now().toIso8601String(),
            mood: '',
            note: '',
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
