import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        initialData: null,
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : _buildListViewSeparated(snapshot.data);
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
                    journal: Journal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  mood: '',
                  note: '',
                  date: DateTime.now().toString(),
                ),),
              ),
            ),
          );
          if (result != null && result.action == 'Save') {
            setState(() {
              _journals.add(result.journal!);
            });
            _saveJournals();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _saveJournals() async {
    Database db = Database(journals: _journals);
    String json = _dbRoutine.databaseToJson(db);
    await _dbRoutine.writeJournals(json);
  }


  
  //there is add/edit here 


  Widget _buildListViewSeparated(dynamic data) {
    return ListView.separated(
      itemCount: _journals.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_journals[index].mood),
          subtitle: Text(_journals[index].note),
        );
      },
    );
  }
}
