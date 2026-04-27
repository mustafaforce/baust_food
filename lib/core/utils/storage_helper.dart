import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageHelper {
  final SupabaseClient _client;

  StorageHelper(this._client);

  Future<String> uploadFoodImage(String filePath) async {
    final ext = _getExtension(filePath);
    final fileName = generateFileName(ext);

    await _client.storage.from('food-images').upload(
      fileName,
      File(filePath),
    );

    return _client.storage.from('food-images').getPublicUrl(fileName);
  }

  String _getExtension(String filePath) {
    final parts = filePath.split('.');
    final ext = parts.isNotEmpty ? parts.last.toLowerCase() : 'jpg';
    return ext == 'jpeg' ? 'jpg' : ext;
  }

  static String generateFileName(String extension) {
    const uuid = Uuid();
    return '${uuid.v4()}.$extension';
  }
}
