import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MetCollectionApp());
}

class MetCollectionApp extends StatelessWidget {
  const MetCollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Met Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const SearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MetApi {
  static const String base = 'https://collectionapi.metmuseum.org/public/collection/v1';

  static Future<List<int>> search(String q, {bool hasImages = true, int maxResults = 100}) async {
    if (q.trim().isEmpty) return [];
    final uri = Uri.parse('$base/search').replace(queryParameters: {
      'q': q.trim(),
      if (hasImages) 'hasImages': 'true',
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Falha no search: ${resp.statusCode}');
    }
    final data = json.decode(resp.body);
    if (data == null) return [];
    final total = data['total'] as int? ?? 0;
    final ids = (data['objectIDs'] as List<dynamic>?)?.cast<int>() ?? <int>[];

    if (ids.length > maxResults) {
      return ids.sublist(0, maxResults);
    }
    return ids;
  }


  static Future<MetObject?> getObject(int objectID) async {
    final uri = Uri.parse('$base/objects/$objectID');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {

      return null;
    }
    final data = json.decode(resp.body);
    return MetObject.fromJson(data as Map<String, dynamic>);
  }


  static Future<List<Department>> getDepartments() async {
    final uri = Uri.parse('$base/departments');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao buscar departamentos');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final list = (data['departments'] as List<dynamic>? ?? []);
    return list.map((e) => Department.fromJson(e)).toList();
  }
}


class Department {
  final int departmentId;
  final String displayName;
  Department({required this.departmentId, required this.displayName});
  factory Department.fromJson(dynamic j) {
    return Department(
      departmentId: j['departmentId'] as int,
      displayName: j['displayName'] as String,
    );
  }
}


class MetObject {
  final int objectID;
  final bool isHighlight;
  final String accessionNumber;
  final String accessionYear;
  final bool isPublicDomain;
  final String primaryImage;
  final String primaryImageSmall;
  final List<String> additionalImages;
  final String department;
  final String title;
  final String artistDisplayName;
  final String objectDate;
  final String medium;
  final String culture;
  final String creditLine;
  final String objectURL;

  MetObject({
    required this.objectID,
    required this.isHighlight,
    required this.accessionNumber,
    required this.accessionYear,
    required this.isPublicDomain,
    required this.primaryImage,
    required this.primaryImageSmall,
    required this.additionalImages,
    required this.department,
    required this.title,
    required this.artistDisplayName,
    required this.objectDate,
    required this.medium,
    required this.culture,
    required this.creditLine,
    required this.objectURL,
  });

  factory MetObject.fromJson(Map<String, dynamic> j) {
    List<dynamic>? addImgs = j['additionalImages'] as List<dynamic>?;
    return MetObject(
      objectID: j['objectID'] as int? ?? 0,
      isHighlight: j['isHighlight'] as bool? ?? false,
      accessionNumber: j['accessionNumber'] as String? ?? '',
      accessionYear: j['accessionYear'] as String? ?? '',
      isPublicDomain: j['isPublicDomain'] as bool? ?? false,
      primaryImage: j['primaryImage'] as String? ?? '',
      primaryImageSmall: j['primaryImageSmall'] as String? ?? '',
      additionalImages: addImgs?.cast<String>() ?? <String>[],
      department: j['department'] as String? ?? '',
      title: j['title'] as String? ?? '',
      artistDisplayName: j['artistDisplayName'] as String? ?? '',
      objectDate: j['objectDate'] as String? ?? '',
      medium: j['medium'] as String? ?? '',
      culture: j['culture'] as String? ?? '',
      creditLine: j['creditLine'] as String? ?? '',
      objectURL: j['objectURL'] as String? ?? '',
    );
  }
}


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _onlyWithImage = true;
  bool _isLoading = false;
  String? _error;

  void _doSearch() async {
    final q = _ctrl.text;
    if (q.trim().isEmpty) {
      setState(() => _error = 'Digite um termo para buscar.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ids = await MetApi.search(q, hasImages: _onlyWithImage, maxResults: 50);

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultsScreen(
          query: q,
          objectIDs: ids,
        ),
      ));
    } catch (e) {
      setState(() => _error = 'Erro ao buscar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openDepartments() async {
    try {
      setState(() => _isLoading = true);
      final deps = await MetApi.getDepartments();
      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: deps.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final d = deps[i];
              return ListTile(
                title: Text(d.displayName),
                subtitle: Text('id: ${d.departmentId}'),
                onTap: () {
                  Navigator.of(context).pop();
                  _ctrl.text = d.displayName;
                },
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Coleção - The Met'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'The Met Explorer',
                applicationVersion: '1.0',
                children: const [
                  Text('Busca e visualização usando The Met Collection API (pública).'),
                ],
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
              decoration: InputDecoration(
                labelText: 'Buscar obras, artista, tema...',
                hintText: 'ex: sunflowers, van gogh, egypt',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.account_tree_outlined),
                  tooltip: 'Departamentos (opcional)',
                  onPressed: _openDepartments,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: _onlyWithImage,
                  onChanged: (v) => setState(() => _onlyWithImage = v),
                ),
                const SizedBox(width: 8),
                const Text('Apenas obras com imagem'),
                const Spacer(),
                ElevatedButton.icon(
                  icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                  onPressed: _isLoading ? null : _doSearch,
                ),
              ],
            ),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.red)),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: Center(
                child: Text('Digite um termo e pressione Buscar.\nDica: use termos em inglês para melhores resultados.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ResultsScreen extends StatefulWidget {
  final String query;
  final List<int> objectIDs;
  const ResultsScreen({super.key, required this.query, required this.objectIDs});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<MetObject?>> _futureObjects;
  static const int fetchLimit = 30; 

  @override
  void initState() {
    super.initState();
    _futureObjects = _loadObjects();
  }

  Future<List<MetObject?>> _loadObjects() async {
    final ids = widget.objectIDs;
    if (ids.isEmpty) return [];
    final limit = ids.length < fetchLimit ? ids.length : fetchLimit;
    final futures = <Future<MetObject?>>[];
    for (var i = 0; i < limit; i++) {
      futures.add(MetApi.getObject(ids[i]));
    }
    final results = await Future.wait(futures);
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados: "${widget.query}"'),
      ),
      body: FutureBuilder<List<MetObject?>>(
        future: _futureObjects,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          } else {
            final objs = snap.data ?? [];
            if (objs.isEmpty) {
              return const Center(child: Text('Nenhum resultado encontrado.'));
            }
            return ListView.separated(
              itemCount: objs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final o = objs[index];
                if (o == null) {
                  return ListTile(title: Text('Objeto ${widget.objectIDs[index]} - sem dados'));
                }
                return ListTile(
                  leading: SizedBox(
                    width: 72,
                    height: 72,
                    child: o.primaryImageSmall.isNotEmpty
                        ? Image.network(
                            o.primaryImageSmall,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(o.title.isNotEmpty ? o.title : 'Untitled'),
                  subtitle: Text(o.artistDisplayName.isNotEmpty ? o.artistDisplayName : 'Artist unknown'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(objectID: o.objectID)));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final int objectID;
  const DetailScreen({super.key, required this.objectID});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<MetObject?> _futureObject;

  @override
  void initState() {
    super.initState();
    _futureObject = MetApi.getObject(widget.objectID);
  }

  Widget _labelValue(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text('$label', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes - ${widget.objectID}'),
      ),
      body: FutureBuilder<MetObject?>(
        future: _futureObject,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
          final o = snap.data;
          if (o == null) return const Center(child: Text('Objeto não encontrado.'));
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (o.primaryImage.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        o.primaryImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 64)),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
                    ),
                  const SizedBox(height: 12),
                  Text(o.title.isNotEmpty ? o.title : 'Untitled', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (o.artistDisplayName.isNotEmpty)
                    Text('Artista: ${o.artistDisplayName}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          _labelValue('Ano:', o.objectDate),
                          _labelValue('Departamento:', o.department),
                          _labelValue('Medium:', o.medium),
                          _labelValue('Cultura:', o.culture),
                          _labelValue('Accession #:', o.accessionNumber),
                          _labelValue('Accession Year:', o.accessionYear),
                          _labelValue('Domínio Público:', o.isPublicDomain ? 'Sim' : 'Não'),
                          const SizedBox(height: 6),
                          if (o.objectURL.isNotEmpty)
                            Row(children: [
                              const Text('URL:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(o.objectURL, overflow: TextOverflow.ellipsis)),
                            ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (o.additionalImages.isNotEmpty) ...[
                    const Text('Imagens adicionais', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: o.additionalImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final url = o.additionalImages[idx];
                          return Image.network(url, width: 160, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
