import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          initialData: const [],
          future: _loadJournals(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return !snapshot.hasData
                ? const Center(child: CircularProgressIndicator())
                : _buildListViewSeparted(snapshot);
          }),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: EdgeInsets.all(30.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Jornal Entry',
        child: const Icon(Icons.add),
        onPressed: () {
          _addOrEditJornal(add: true, index: -1, journal: Journal());
        },
      ),
    );
  }
}
