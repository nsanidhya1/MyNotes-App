import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'dart:async';

void main() {
  runApp(MyNotesApp());
}

class MyNotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyNotes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use a Timer to delay the navigation
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NotesPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Image.asset('assets/download.png'), // Load the image from assets
      ),
    );
  }
}


class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> notes = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load notes from SharedPreferences
  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotes = prefs.getStringList('notes');
    if (savedNotes != null) {
      setState(() {
        notes = savedNotes
            .map((note) => Map<String, String>.from(
            Map<String, dynamic>.from(_decodeString(note))))
            .toList();
      });
    }
  }

  // Save notes to SharedPreferences
  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedNotes = notes.map((note) => _encodeMap(note)).toList();
    prefs.setStringList('notes', encodedNotes);
  }

  // Show the dialog for adding a new note
  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(hintText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              contentController.clear();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addNote();
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // Add a new note
  void _addNote() {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      String dateTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
      setState(() {
        notes.add({
          'title': titleController.text,
          'content': contentController.text,
          'datetime': dateTime,
        });
        titleController.clear();
        contentController.clear();
        _saveNotes();
      });
    }
  }

  // Edit an existing note
  void _editNoteAtIndex(int index) {
    titleController.text = notes[index]['title']!;
    contentController.text = notes[index]['content']!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(hintText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              contentController.clear();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notes[index] = {
                  'title': titleController.text,
                  'content': contentController.text,
                  'datetime': DateFormat('yyyy-MM-dd – kk:mm')
                      .format(DateTime.now()),
                };
                _saveNotes();
              });
              titleController.clear();
              contentController.clear();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete a note
  void _deleteNoteAtIndex(int index) {
    setState(() {
      notes.removeAt(index);
      _saveNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: Text(
            'MyNotes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true, // Ensure title is centered
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _editNoteAtIndex(index),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notes[index]['title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            notes[index]['content'] ?? '',
                            style: TextStyle(fontSize: 16),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            notes[index]['datetime'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Add Note Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddNoteDialog,
              child: Text('Add Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Updated to backgroundColor
              ),
            ),
          ),
          // Footer
          Container(
            padding: EdgeInsets.all(16.0),
            //color: Colors.blue[100], // Optional: set footer background color
            child: Text(
              'Developed with love by Sanidhya Nigam ❤️ ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Utility functions to encode/decode Map to String for saving
  String _encodeMap(Map<String, String> map) {
    return map.toString();
  }

  Map<String, dynamic> _decodeString(String encoded) {
    return Map<String, dynamic>.from(Uri.splitQueryString(
        encoded.substring(1, encoded.length - 1).replaceAll(', ', '&')));
  }
}
