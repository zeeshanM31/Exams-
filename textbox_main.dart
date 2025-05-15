//main.dart



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Text Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TextStorageScreen(),
    );
  }
}

class TextStorageScreen extends StatefulWidget {
  const TextStorageScreen({super.key});

  @override
  State<TextStorageScreen> createState() => _TextStorageScreenState();
}

class _TextStorageScreenState extends State<TextStorageScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _texts = [];

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  Future<void> _loadTexts() async {
    final texts = await DatabaseHelper.instance.getAllTexts();
    setState(() {
      _texts = texts;
    });
  }

  Future<void> _saveText() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text first!')),
      );
      return;
    }

    await DatabaseHelper.instance.insertText(_textController.text.trim());
    _textController.clear();
    await _loadTexts();
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Text Storage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter your text',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveText,
              child: const Text('Save to SQLite'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Stored Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _texts.isEmpty
                  ? const Center(child: Text('No records yet'))
                  : ListView.builder(
                      itemCount: _texts.length,
                      itemBuilder: (context, index) {
                        final text = _texts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(text['content']),
                            subtitle: Text(_formatTimestamp(text['timestamp'])),
                            trailing: Text('#${text['id']}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    DatabaseHelper.instance.close();
    super.dispose();
  }
}











//database_helper.dart


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('texts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE texts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertText(String text) async {
    final db = await instance.database;
    
    return await db.insert('texts', {
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllTexts() async {
    final db = await instance.database;
    return await db.query('texts', orderBy: 'timestamp DESC');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}




//home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample enrolled subjects data
    final List<Map<String, dynamic>> enrolledSubjects = [
      {
        'name': 'Mobile Application Development',
        'teacher': 'Dr. Smith',
        'credits': 4,
        'code': 'CS-501'
      },
      {
        'name': 'Database Systems',
        'teacher': 'Prof. Johnson',
        'credits': 3,
        'code': 'CS-502'
      },
      {
        'name': 'Artificial Intelligence',
        'teacher': 'Dr. Williams',
        'credits': 4,
        'code': 'CS-503'
      },
      {
        'name': 'Software Engineering',
        'teacher': 'Prof. Brown',
        'credits': 3,
        'code': 'CS-504'
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // University image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              alignment: Alignment.center,
              child: const Text(
                'Welcome to Your University',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Enrolled Subjects',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: enrolledSubjects.length,
            itemBuilder: (context, index) {
              final subject = enrolledSubjects[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      subject['code'],
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  title: Text(
                    subject['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Teacher: ${subject['teacher']}'),
                      const SizedBox(height: 4),
                      Text('Credit Hours: ${subject['credits']}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Add subject details navigation here
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}




