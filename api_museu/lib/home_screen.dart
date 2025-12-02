import 'package:flutter/material.dart';
import './museum_api.dart';
import './museum_art.dart';
import './art_details.dart';
import './favorites.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MuseumArt> artworks = [];
  List<String> suggestions = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadArtworks();
  }

  void loadArtworks() async {
    final result = await MuseumAPI.fetchArtworks();
    setState(() {
      artworks = result;
      suggestions = artworks.map((e) => e.title).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = artworks.where((art) {
      return art.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Museu Móvel"),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritesPage()),
            ),
          )
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                TextField(
                  onChanged: (text) {
                    setState(() => searchQuery = text);
                  },
                  decoration: InputDecoration(
                    hintText: "Buscar obra...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.blue.shade700.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                if (searchQuery.isNotEmpty)
                  Positioned(
                    top: 55,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[900]!.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: suggestions
                            .where((s) => s
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()))
                            .take(5)
                            .map((s) => ListTile(
                                  title: Text(
                                    s,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      searchQuery = s;
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final art = filtered[i];
                return Card(
                  color: Colors.blue.shade800.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Image.network(art.image, width: 60),
                    title: Text(art.title,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(art.author,
                        style: const TextStyle(color: Colors.white54)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtDetailsPage(art: art),
                        ),
                      );
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
