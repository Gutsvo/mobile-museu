import 'package:flutter/material.dart';
import './museum_art.dart';
import './museum_api.dart';
import './art_details.dart';
import './favorites_storage.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController controller = TextEditingController();

  List<MuseumArt> artworks = [];
  List<MuseumArt> filtered = [];
  List<String> suggestions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadArtworks();
  }

  Future<void> loadArtworks() async {
    try {
      final data = await MuseumAPI.fetchArtworks();

      setState(() {
        artworks = data;
        filtered = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Erro: $e");
    }
  }

  void search(String value) {
    final text = value.toLowerCase();

    // FILTRAR LISTA
    filtered = artworks.where((art) {
      return art.title.toLowerCase().contains(text) ||
          art.author.toLowerCase().contains(text);
    }).toList();

    // SUGESTÕES
    suggestions = artworks
        .map((art) => art.title)
        .where((title) => title.toLowerCase().contains(text))
        .take(6)
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("Pesquisar"),
        backgroundColor: Color(0xFF161B22),
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // CAMPO DE BUSCA
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: controller,
                    onChanged: search,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Buscar título ou autor...",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Color(0xFF21262D),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // SUGESTÕES
                if (controller.text.isNotEmpty && suggestions.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: suggestions.map((s) {
                        return GestureDetector(
                          onTap: () {
                            controller.text = s;
                            search(s);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              s,
                              style: TextStyle(
                                // menos transparente → mais parecido
                                color: Colors.white.withOpacity(
                                  controller.text.toLowerCase() == s.toLowerCase()
                                      ? 1
                                      : 0.45,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                SizedBox(height: 10),

                // LISTA DE RESULTADOS
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final art = filtered[i];
                      final isFav = FavoritesStorage.isFavorite(art.id);

                      return ListTile(
                        tileColor: Color(0xFF161B22),
                        contentPadding: EdgeInsets.all(12),

                        leading: Image.network(
                          art.image,
                          width: 60,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.image_not_supported, color: Colors.white70),
                        ),

                        title: Text(
                          art.title,
                          style: TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          art.author,
                          style: TextStyle(color: Colors.white54),
                        ),

                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtDetailsPage(art: art),
                          ),
                        ),

                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.lightBlueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              FavoritesStorage.toggleFavorite(art);
                            });
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}