import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final Map<String, String> _imageCache = {};

  Future<String> downloadImage(String url, String fileName) async {
    try {
      if (_imageCache.containsKey(url)) {
        return _imageCache[url]!;
      }

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDocDir.path}/$fileName.jpg';
      final File file = File(localPath);

      if (await file.exists() && await file.length() > 0) {
        _imageCache[url] = localPath;
        return localPath;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        _imageCache[url] = localPath;
        return localPath;
      }

      throw Exception('Failed to download image');
    } catch (e) {
      print('Error downloading image: $e');
      return '';
    }
  }

  Future<bool> isImageValid(String path) async {
    if (path.isEmpty) return false;
    final file = File(path);
    return await file.exists() && await file.length() > 0;
  }
}