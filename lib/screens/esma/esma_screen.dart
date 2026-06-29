import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/esma_name.dart';
import 'package:vakitli/services/esma_service.dart';

class EsmaScreen extends StatefulWidget {
  const EsmaScreen({super.key});

  @override
  State<EsmaScreen> createState() => _EsmaScreenState();
}

class _EsmaScreenState extends State<EsmaScreen> {
  final EsmaService _service = EsmaService();
  final TextEditingController _search = TextEditingController();
  late Future<List<EsmaName>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _service.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esma-ül Hüsna')),
      body: FutureBuilder<List<EsmaName>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          final all = snapshot.data!;
          final q = _query.toLowerCase();
          final list = q.isEmpty
              ? all
              : all
                  .where((e) =>
                      e.transliteration.toLowerCase().contains(q) ||
                      e.meaning.toLowerCase().contains(q))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'İsim ara...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.navy.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _EsmaCard(esma: list[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EsmaCard extends StatelessWidget {
  final EsmaName esma;

  const _EsmaCard({required this.esma});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${esma.id}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        esma.transliteration,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                      ),
                      Text(
                        esma.arabic,
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 22),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esma.meaning,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
