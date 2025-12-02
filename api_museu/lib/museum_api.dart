import 'dart:convert';
import 'package:http/http.dart' as http;
import './museum_art.dart';

class MuseumAPI {
  static const String baseUrl =
      "https://api.artic.edu/api/v1/artworks?limit=20";

  static Future<List<MuseumArt>> fetchArtworks() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List artworks = data["data"];

      return artworks.map((art) {
        return MuseumArt(
          id: art["id"],
          title: art["title"] ?? "Sem título",
          author: art["artist_title"] ?? "Desconhecido",
          description: art["thumbnail"]?["alt_text"] ?? "Sem descrição",
          image:
              "https://www.artic.edu/iiif/2/${art['image_id']}/full/843,/0/default.jpg",
        );
      }).toList();
    } else {
      throw Exception("Erro ao carregar obras");
    }
  }
}
