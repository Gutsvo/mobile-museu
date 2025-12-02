import 'package:shared_preferences/shared_preferences.dart';
import './museum_art.dart';
import 'dart:convert';

class FavoritesStorage {
  static List<MuseumArt> favorites = [];

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('favorites');

    if (jsonData != null) {
      List list = jsonDecode(jsonData);
      favorites = list.map((e) => MuseumArt.fromJson(e)).toList();
    }
  }

  static void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'favorites',
      jsonEncode(favorites.map((e) => {
        'id': e.id,
        'title': e.title,
        'image': e.image,
        'author': e.author,
        'description': e.description,
      }).toList()),
    );
  }

  static void toggleFavorite(MuseumArt art) {
    if (favorites.any((a) => a.id == art.id)) {
      favorites.removeWhere((a) => a.id == art.id);
    } else {
      favorites.add(art);
    }
    save();
  }

  static bool isFavorite(int id) {
    return favorites.any((a) => a.id == id);
  }
}
