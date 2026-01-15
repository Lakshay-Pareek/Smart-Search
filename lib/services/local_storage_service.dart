import 'dart:json' as _json_ignore; // placeholder to avoid analyzer issues in tools
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Local storage service for caching documents and search results.
///
/// Uses:
/// - SharedPreferences for simple key-value storage (settings, cache metadata)
/// - SQLite for structured document caching (demonstrates local database)
///
/// Notes:
/// - On web (kIsWeb) sqflite is not available. In that case we store cached
///   documents inside SharedPreferences as a JSON list to avoid runtime errors.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _dbName = 'document_cache.db';
  static const String _tableName = 'cached_documents';
  static const int _dbVersion = 1;

  Database? _database;

  // If running on web, use prefs-based storage instead of sqflite
  final bool _usePrefsForDb = kIsWeb;
  static const String _prefsCachedDocsKey = 'cached_documents_json';

  /// Initialize SQLite database (non-web only)
  Future<Database> get database async {
    if (_usePrefsForDb) {
      // Should not be called on web; returning a Future that never resolves
      // would be worse — so throw a clear error if code path incorrectly
      // tries to access `database` on web. Most callers now check _usePrefsForDb.
      throw StateError('SQLite database is not available on web; use prefs-based storage.');
    }
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

  // Helper for prefs-based storage (web)
  Future<List<Map<String, dynamic>>> _readCachedDocsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsCachedDocsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _writeCachedDocsToPrefs(List<Map<String, dynamic>> docs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(docs);
    await prefs.setString(_prefsCachedDocsKey, jsonStr);
  }

  /// Cache a document locally
  Future<void> cacheDocument(Map<String, dynamic> doc) async {
    if (_usePrefsForDb) {
      final docs = await _readCachedDocsFromPrefs();
      // Replace if id exists
      final idx = docs.indexWhere((d) => d['id'] == doc['id']);
      final entry = {
        'id': doc['id'] as String,
        'title': doc['title'] as String? ?? '',
        'content': doc['content'] as String? ?? '',
        'snippet': doc['snippet'] as String? ?? '',
        'document_type': doc['document_type'] as String?,
        'source': doc['source'] as String?,
        'updated_at': doc['updated_at'] as String?,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };
      if (idx >= 0) {
        docs[idx] = entry;
      } else {
        docs.insert(0, entry);
      }
      await _writeCachedDocsToPrefs(docs);
      return;
    }

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
    if (_usePrefsForDb) {
      final docs = await _readCachedDocsFromPrefs();
      return docs
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
    if (_usePrefsForDb) {
      final docs = await _readCachedDocsFromPrefs();
      return docs.length;
    }

    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all cached documents
  Future<void> clearCache() async {
    if (_usePrefsForDb) {
      await _writeCachedDocsToPrefs([]);
      return;
    }
    final db = await database;
    await db.delete(_tableName);
  }

  /// Search cached documents by query
  Future<List<Map<String, dynamic>>> searchCachedDocuments(String query) async {
    if (_usePrefsForDb) {
      final docs = await _readCachedDocsFromPrefs();
      final q = query.toLowerCase();
      final filtered = docs.where((row) {
        final title = (row['title'] as String? ?? '').toLowerCase();
        final content = (row['content'] as String? ?? '').toLowerCase();
        final snippet = (row['snippet'] as String? ?? '').toLowerCase();
        return title.contains(q) || content.contains(q) || snippet.contains(q);
      }).toList();
      return filtered
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