import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  final SharedPreferences _prefs;

  StorageManager(this._prefs);

  // Generic method to store any type of data
  Future<bool> saveData<T>(String key, T value) async {
    try {
      if (value is String) {
        return await _prefs.setString(key, value);
      } else if (value is int) {
        return await _prefs.setInt(key, value);
      } else if (value is double) {
        return await _prefs.setDouble(key, value);
      } else if (value is bool) {
        return await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        return await _prefs.setStringList(key, value);
      } else {
        // For complex objects, convert to JSON string
        final jsonString = json.encode(value);
        return await _prefs.setString(key, jsonString);
      }
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }

  // Generic method to retrieve data
  T? getData<T>(String key) {
    try {
      if (T == String) {
        return _prefs.getString(key) as T?;
      } else if (T == int) {
        return _prefs.getInt(key) as T?;
      } else if (T == double) {
        return _prefs.getDouble(key) as T?;
      } else if (T == bool) {
        return _prefs.getBool(key) as T?;
      } else if (T == List<String>) {
        return _prefs.getStringList(key) as T?;
      } else {
        // For complex objects, retrieve JSON string and decode
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          return json.decode(jsonString) as T?;
        }
      }
    } catch (e) {
      print('Error retrieving data: $e');
    }
    return null;
  }

  // Delete specific data
  Future<bool> deleteData(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      print('Error deleting data: $e');
      return false;
    }
  }

  // Clear all data
  Future<bool> clearAll() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      return false;
    }
  }

  // Check if key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
}
