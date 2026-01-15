import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local storage service for caching documents and search results.
///
/// Uses:
/// - SharedPreferences for simple key-value storage (settings, cache metadata)
/// - SQLite for structured document caching (demonstrates local database)
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _dbName = 'document_cache.db';
  static const String _tableName = 'cached_documents';
  static const int _dbVersion = 1;

  Database? _database;

  /// Initialize SQLite database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT,
            snippet TEXT,
            document_type TEXT,
            source TEXT,
            updated_at TEXT,
            cached_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Cache a document locally
  Future<void> cacheDocument(Map<String, dynamic> doc) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': doc['id'] as String,
        'title': doc['title'] as String? ?? '',
        'content': doc['content'] as String? ?? '',
        'snippet': doc['snippet'] as String? ?? '',
        'document_type': doc['document_type'] as String?,
        'source': doc['source'] as String?,
        'updated_at': doc['updated_at'] as String?,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all cached documents
  Future<List<Map<String, dynamic>>> getCachedDocuments() async {
    final db = await database;
    final results = await db.query(
      _tableName,
      orderBy: 'cached_at DESC',
    );
    return results
        .map((row) => {
              'id': row['id'] as String,
              'title': row['title'] as String,
              'content': row['content'] as String? ?? '',
              'snippet': row['snippet'] as String? ?? '',
              'document_type': row['document_type'] as String?,
              'source': row['source'] as String?,
              'updated_at': row['updated_at'] as String?,
            })
        .toList();
  }

  /// Get count of cached documents
  Future<int> getCachedDocumentCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all cached documents
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Search cached documents by query
  Future<List<Map<String, dynamic>>> searchCachedDocuments(String query) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'title LIKE ? OR content LIKE ? OR snippet LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'cached_at DESC',
      limit: 50,
    );
    return results
        .map((row) => {
              'id': row['id'] as String,
              'title': row['title'] as String,
              'content': row['content'] as String? ?? '',
              'snippet': row['snippet'] as String? ?? '',
              'document_type': row['document_type'] as String?,
              'source': row['source'] as String?,
              'updated_at': row['updated_at'] as String?,
            })
        .toList();
  }

  /// Store search history locally (using SharedPreferences for simplicity)
  Future<void> saveSearchHistory(String query, int resultCount) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('search_history') ?? [];
    final entry = jsonEncode({
      'query': query,
      'resultCount': resultCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
    historyJson.insert(0, entry);
    // Keep only last 100 entries
    if (historyJson.length > 100) {
      historyJson.removeRange(100, historyJson.length);
    }
    await prefs.setStringList('search_history', historyJson);
  }

  /// Get local search history
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('search_history') ?? [];
    return historyJson.map((entry) {
      final data = jsonDecode(entry) as Map<String, dynamic>;
      return {
        'query': data['query'] as String,
        'resultCount': data['resultCount'] as int,
        'timestamp': data['timestamp'] as String,
      };
    }).toList();
  }

  /// Clear local search history
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
  }

  /// Get storage permission status (for demo purposes)
  Future<bool> hasStoragePermission() async {
    // On web, we can use IndexedDB/localStorage without explicit permission
    // On mobile, this would check actual storage permissions
    return true;
  }

  /// Request storage permission (for demo purposes)
  Future<bool> requestStoragePermission() async {
    // On web, always return true
    // On mobile, this would show a permission dialog
    return true;
  }
}
