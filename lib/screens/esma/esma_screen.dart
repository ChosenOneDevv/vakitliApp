import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/esma_name.dart';
import 'package:vakitli/services/esma_service.dart';

class EsmaScreen extends StatefulWidget {
  const EsmaScreen({super.key});

  @override
  State<EsmaScreen> createState() => _EsmaScreenState();
}

class _EsmaScreenState extends State<EsmaScreen>
    with SingleTickerProviderStateMixin {
  final EsmaService _service = EsmaService();
  late final TabController _tabController;
  List<EsmaName> _names = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _service.load().then((names) {
      if (mounted) setState(() { _names = names; _loaded = true; });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esma-ül Hüsna'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Liste'),
            Tab(text: 'Ezber'),
          ],
        ),
      ),
      body: !_loaded
          ? Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _ListTab(names: _names),
                _EzberTab(names: _names),
              ],
            ),
    );
  }
}

// ─── Liste Sekmesi ────────────────────────────────────────────────────────────

class _ListTab extends StatefulWidget {
  final List<EsmaName> names;
  const _ListTab({required this.names});

  @override
  State<_ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<_ListTab> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = q.isEmpty
        ? widget.names
        : widget.names
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${esma.id}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        esma.arabic,
                        style:
                            const TextStyle(fontFamily: 'Amiri', fontSize: 22),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(esma.meaning,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ezber Sekmesi ────────────────────────────────────────────────────────────

class _EzberTab extends StatefulWidget {
  final List<EsmaName> names;
  const _EzberTab({required this.names});

  @override
  State<_EzberTab> createState() => _EzberTabState();
}

class _EzberTabState extends State<_EzberTab> {
  static const _prefKey = 'esma_memorized';

  int _index = 0;
  bool _flipped = false;
  Set<int> _memorized = {};

  @override
  void initState() {
    super.initState();
    _loadMemorized();
  }

  Future<void> _loadMemorized() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_prefKey);
    if (str != null) {
      try {
        final list = (jsonDecode(str) as List).cast<int>();
        if (mounted) setState(() => _memorized = list.toSet());
      } catch (_) {}
    }
  }

  Future<void> _toggleMemorized(int id) async {
    setState(() {
      if (_memorized.contains(id)) {
        _memorized.remove(id);
      } else {
        _memorized.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(_memorized.toList()));
  }

  void _prev() => setState(() {
        _flipped = false;
        _index =
            (_index - 1 + widget.names.length) % widget.names.length;
      });

  void _next() => setState(() {
        _flipped = false;
        _index = (_index + 1) % widget.names.length;
      });

  @override
  Widget build(BuildContext context) {
    if (widget.names.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }
    final esma = widget.names[_index];
    final isMemorized = _memorized.contains(esma.id);
    final progress =
        widget.names.isNotEmpty ? _memorized.length / widget.names.length : 0.0;

    return Column(
      children: [
        // İlerleme
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_index + 1} / ${widget.names.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${_memorized.length} ezberlendi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),

        // Kart
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => setState(() => _flipped = !_flipped),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: _flipped
                      ? _CardBack(
                          key: const ValueKey('back'),
                          esma: esma,
                          isMemorized: isMemorized,
                          onToggle: () => _toggleMemorized(esma.id),
                        )
                      : _CardFront(
                          key: const ValueKey('front'),
                          esma: esma,
                          isMemorized: isMemorized,
                        ),
                ),
              ),
            ),
          ),
        ),

        // Navigasyon
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.outlined(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: _prev,
              ),
              Column(
                children: [
                  Text(
                    esma.transliteration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'Çevirmek için dokun',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
              IconButton.outlined(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: _next,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardFront extends StatelessWidget {
  final EsmaName esma;
  final bool isMemorized;

  const _CardFront({super.key, required this.esma, required this.isMemorized});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMemorized)
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(height: 12),
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${esma.id}',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              esma.arabic,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 52,
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final EsmaName esma;
  final bool isMemorized;
  final VoidCallback onToggle;

  const _CardBack({
    super.key,
    required this.esma,
    required this.isMemorized,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              esma.arabic,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 36),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              esma.transliteration,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              esma.meaning,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onToggle,
              icon: Icon(
                isMemorized
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 20,
              ),
              label: Text(isMemorized ? 'Ezberledim ✓' : 'Ezberlendi olarak işaretle'),
              style: FilledButton.styleFrom(
                backgroundColor: isMemorized
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                foregroundColor:
                    isMemorized ? Colors.white : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
