import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

// Provides file-based or shared_preferences-based persistence of journal entries.
class DatabaseFileRoutine {
  static Future<String> get _localPath async {
    if (kIsWeb) {
      return ''; // Not used on web
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  /// Reads journals from local storage or shared_preferences (if on web).
  ///
  /// - On web, it retrieves data from `shared_preferences`.
  /// - On other platforms, it reads from a local JSON file.
  ///
  /// Returns:
  ///   A string containing the journals JSON or an empty JSON structure if none exist.
  Future<String> readJournals() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('journals') ?? '{"journals":[]}';
      }
      final file = await _localFile;
      if (!file.existsSync()) {
        print("File doesn't exist: ${file.absolute}");
        await writeJournals('{"journals": []}');
      }
      String contents = await file.readAsString();
      if (contents.isEmpty) {
        return '{"journals":[]}';
      }
      return contents;
    } catch (e) {
      print('Error readJournals: $e');
      return '{"journals":[]}';
    }
  }

  /// Writes journals to local storage or shared_preferences (if on web).
  ///
  /// - On web, it stores data using `shared_preferences`.
  /// - On other platforms, it writes to a local JSON file.
  ///
  /// [jsonData] is the JSON string to be saved.
  Future<void> writeJournals(String jsonData) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('journals', jsonData);
        return;
      }
      final file = await _localFile;
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error writeJournals: $e');
      rethrow;
    }
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

// Holds lists of journals read from or written to storage.
class Database {
  List<Journal> journals;

  Database({required this.journals});

  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
        journals: List<Journal>.from(
            json["journals"].map((x) => Journal.fromJson(x))));
  }

  Map<String, dynamic> toJson() {
    return {
      'journals': List<dynamic>.from(journals.map((x) => x.toJson())),
    };
  }
}

// Represents a single journal entry with optional fields.
class Journal {
  String? id, date, mood, note;

  // Constructor for initializing Journal with optional fields.
  Journal({this.id, this.date, this.mood, this.note});

  // Factory method to create a Journal instance from a JSON map.
  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
        id: json["id"],
        date: json["date"],
        mood: json["mood"],
        note: json["note"],
      );

  // Method to convert a Journal instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "mood": mood,
        "note": note,
      };
}

// Helps track edit actions and the associated journal.
class JournalEdit {
  String action;
  Journal journal;
  JournalEdit({required this.action, required this.journal});
}
