import 'package:flutter/material.dart';
import './museum_art.dart';
import './favorites_storage.dart';

class ArtDetailsPage extends StatefulWidget {
  final MuseumArt art;

  ArtDetailsPage({required this.art});

  @override
  _ArtDetailsPageState createState() => _ArtDetailsPageState();
}

class _ArtDetailsPageState extends State<ArtDetailsPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = FavoritesStorage.isFavorite(widget.art.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.art.title),
      ),
      body: Column(
        children: [
          Image.network(widget.art.image),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.art.description),
          ),
          ElevatedButton.icon(
            icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text("Favoritar"),
            onPressed: () {
              setState(() {
                FavoritesStorage.toggleFavorite(widget.art);
                isFavorite = !isFavorite;
              });
            },
          )
        ],
      ),
    );
  }
}
