import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_entry.dart';
import 'database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _dbRoutine = DatabaseFileRoutine();
  final List<Journal> _journals = [];

  Future<List<Journal>> _loadJournals() async {
    String content = await _dbRoutine.readJournals();
    if (content.isEmpty) return [];
    Database db = _dbRoutine.databaseFromJson(content);
    return db.journals;
  }

  @override
  void initState() {
    super.initState();
    _loadAndSetJournals();
  }

  Future<void> _loadAndSetJournals() async {
    List<Journal> journals = await _loadJournals();
    setState(() {
      _journals.clear();
      _journals.addAll(journals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Journal>>(
        initialData: _journals.isEmpty ? null : _journals,
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot<List<Journal>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No journal entries found.'));
          } else {
            return _buildListViewSeparated(snapshot.data!);
          }
        },
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox.shrink(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        onPressed: () async {
          JournalEdit? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditEntry(
                add: true,
                index: -1,
                journalEdit: JournalEdit(
                  action: 'Add',
                  journal: Journal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    mood: '',
                    note: '',
                    date: DateTime.now().toString(),
                  ),
                ),
              ),
            ),
          );
          if (result != null && result.action == 'Save') {
            setState(() {
              _journals.add(result.journal!);
            });
            await _saveJournals();
            await _loadAndSetJournals(); 
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _saveJournals() async {
    Database db = Database(journals: _journals);
    String json = _dbRoutine.databaseToJson(db);
    await _dbRoutine.writeJournals(json);
  }

  //there is add/edit here
  

  void _addOrEdit(int index) async {
    JournalEdit? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntry(
          add: false,
          index: index,
          journalEdit: JournalEdit(
            action: 'Edit',
            journal: _journals[index],
          ),
        ),
      ),
    );
    if (result != null && result.action == 'Save') {
      setState(() {
        _journals[index] = result.journal!;
      });
      await _saveJournals();
      await _loadAndSetJournals(); // Reload the journals
    }
  }

  Widget _buildListViewSeparated(List<Journal> data) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        String titleDate = DateFormat.yMMMd()
            .format(DateTime.parse(data[index].date));
        String subtitle =
            data[index].mood + '\n' + data[index].note;
        return Dismissible(
          key: Key(data[index].id.toString()), // Fixed key assignment
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(24.0),
            child: const Icon(Icons.delete, color: Colors.white), // Fixed Icon usage
          ),
          child: ListTile(
            title: Text(titleDate),
            subtitle: Text(subtitle),
            onTap: () => _addOrEdit(index), // Add onTap to edit entry
          ),
        );
      },
    );
  }
}
