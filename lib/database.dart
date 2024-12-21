import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DatabaseFileRoutine {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json'); // Fixed typo in filename
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;

      // Check if the file does not exist
      if (!file.existsSync()) {
        print('File does not exist: ${file.absolute}');
        await writeJournals(
            '{"journals": []}'); // Standardized key to "journals"
      }

      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print('Error in readJournals: $e');
      return '';
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    return file.writeAsString(json);
  }

  Database databaseFromJson(String str) {
    final dataFromJson = json.decode(str);
    return Database.fromJson(dataFromJson);
  }

  String databaseToJson(Database data) {
    final dataToJson = data.toJson();
    return json.encode(dataToJson);
  }
}

class Database {
  List<Journal> journals; // Corrected property name for consistency

  Database({required this.journals});

  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      journals: List<Journal>.from(
        json['journals'].map((x) => Journal.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "journals": List<dynamic>.from(journals.map((x) => x.toJson())),
    };
  }
}

class Journal {
  String id;
  String date;
  String mood;
  String note;

  Journal(
      {required this.id,
      required this.date,
      required this.mood,
      required this.note});

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'],
      date: json['date'],
      mood: json['mood'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "mood": mood,
      "note": note,
    };
  }
}

class JournalEdit {
  String? action;
  Journal? journal;
  JournalEdit({required this.action, required this.journal});
}
