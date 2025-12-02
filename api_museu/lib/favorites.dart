import 'package:flutter/material.dart';
import './favorites_storage.dart';
import './museum_art.dart';
import './art_details.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    FavoritesStorage.load().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final favs = FavoritesStorage.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
      ),

      body: favs.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma obra favoritada ainda.",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            )

          : ListView.builder(
              itemCount: favs.length,
              itemBuilder: (context, index) {
                final MuseumArt art = favs[index];

                return Card(
                  color: Colors.blue.shade800.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        art.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(
                      art.title,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      art.author,
                      style: const TextStyle(color: Colors.white70),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtDetailsPage(art: art),
                        ),
                      );
                    },

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          FavoritesStorage.favorites.removeAt(index);
                          FavoritesStorage.save();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
