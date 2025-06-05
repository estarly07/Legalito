import 'package:myapp/chat/chat.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'message.dart'; // Assuming message.dart is in the same directory

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  final _chatsController = StreamController<List<Chat>>.broadcast();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chats.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chatId TEXT,
        text TEXT,
        isUser INTEGER,
        timestamp TEXT,
        FOREIGN KEY (chatId) REFERENCES chats(id) ON DELETE CASCADE
      )
    ''');
  }

  Stream<List<Chat>> getChatsStream() {
    _getAndEmitChats(); // Emit initial data
    return _chatsController.stream;
  }

  Future<List<Chat>> getChats() async {
    final db = await database;
    final List<Map<String, dynamic>> chatMaps = await db.query('chats');
    List<Chat> chats = [];
    for (var chatMap in chatMaps) {
      final List<Map<String, dynamic>> messageMaps = await db.query(
        'messages',
        where: 'chatId = ?',
        whereArgs: [chatMap['id']],
        orderBy: 'timestamp ASC',
      );
      List<Message> messages =
          messageMaps
              .map(
                (msgMap) => Message.fromMap({
                  'text': msgMap['text'],
                  'id': msgMap['id'],
                  'isUser': msgMap['isUser'] == 1,
                  'timestamp': msgMap['timestamp'],
                }),
              )
              .toList();
      chats.add(
        Chat(id: chatMap['id'], name: chatMap['name'], messages: messages),
      );
    }
    return chats;
  }

  Future<Chat?> getChat(String chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> chatMaps = await db.query(
      'chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );
    if (chatMaps.isEmpty) return null;

    final chatMap = chatMaps.first;
    final List<Map<String, dynamic>> messageMaps = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
    List<Message> messages =
        messageMaps
            .map(
              (msgMap) => Message.fromMap({
                'text': msgMap['text'],
                'id': msgMap['id'],
                'isUser': msgMap['isUser'] == 1,
                'timestamp': msgMap['timestamp'],
              }),
            )
            .toList();
    return Chat(id: chatMap['id'], name: chatMap['name'], messages: messages);
  }

  Future<void> insertChat(Chat chat) async {
    final db = await database;
    await db.insert('chats', {
      'id': chat.id,
      'name': chat.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    for (var message in chat.messages) {
      await db.insert('messages', {
        'chatId': chat.id,
        'text': message.text,
        'isUser': message.isUser ? 1 : 0,
        'timestamp': message.timestamp.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    _getAndEmitChats(); // Emit changes
  }

  Future<void> addMessageToChat(String chatId, Message message) async {
    final db = await database;
    await db.insert('messages', {
      'chatId': chatId,
      'text': message.text,
      'isUser': message.isUser ? 1 : 0,
      'timestamp': message.timestamp.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _getAndEmitChats() async {
    final chats = await getChats();
    _chatsController.sink.add(chats);
  }

  Future<void> deleteAllChats() async {
    final db = await database;
    await db.delete('chats');
  }

  void dispose() => _chatsController.close();
}
