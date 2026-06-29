import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/dua_kardesligi.dart';
import 'package:vakitli/providers/dua_kardesligi_provider.dart';
import 'package:vakitli/screens/auth/auth_screen.dart';

class DuaKardesligiScreen extends StatefulWidget {
  const DuaKardesligiScreen({super.key});

  @override
  State<DuaKardesligiScreen> createState() => _DuaKardesligiScreenState();
}

class _DuaKardesligiScreenState extends State<DuaKardesligiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DuaKardesligiProvider>();
      p.listenAll();
      p.listenMine();
    });
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    bool anon = false;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Dua İsteği Gönder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Dua metni',
                  hintText: 'Örn: Hastaların şifası için dua ederim…',
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: anon,
                onChanged: (v) => setSt(() => anon = v ?? false),
                title: const Text('Anonim gönder'),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primaryGreen,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  final ok = await context
                      .read<DuaKardesligiProvider>()
                      .addDua(duaText: text, isAnonymous: anon);
                  if (context.mounted) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(ok ? 'Dua isteğiniz gönderildi.' : 'Hata oluştu.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dua Kardeşliği'),
        actions: [
          Consumer<DuaKardesligiProvider>(
            builder: (_, p, _) => TextButton(
              onPressed: () => p.toggleShowMine(!p.showMine),
              child: Text(p.showMine ? 'Tümü' : 'Benimkiler',
                  style: const TextStyle(color: AppColors.primaryGreen)),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<DuaKardesligiProvider>(
        builder: (_, p, _) => p.isSignedIn
            ? FloatingActionButton.extended(
                onPressed: () => _showAddDialog(context),
                backgroundColor: AppColors.primaryGreen,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Dua İste',
                    style: TextStyle(color: Colors.white)),
              )
            : const SizedBox.shrink(),
      ),
      body: Consumer<DuaKardesligiProvider>(
        builder: (context, provider, _) {
          if (!provider.isSignedIn) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        size: 64, color: AppColors.gold),
                    const SizedBox(height: 16),
                    Text(
                      'Dua kardeşliğine katılmak için giriş yapmanız gerekiyor.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AuthScreen()),
                      ),
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = provider.items;
          if (items.isEmpty) {
            return Center(
              child: Text(
                provider.showMine
                    ? 'Henüz dua isteği göndermediniz.'
                    : 'Henüz dua isteği yok.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _DuaTile(item: items[i]),
          );
        },
      ),
    );
  }
}

class _DuaTile extends StatelessWidget {
  final DuaKardesligi item;

  const _DuaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = item.fromUserId == currentUid;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(item.displayName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      )),
              const Spacer(),
              if (isOwner)
                GestureDetector(
                  onTap: () =>
                      context.read<DuaKardesligiProvider>().deleteDua(item.id),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.redAccent),
                ),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Share.share(
                  'Dua kardeşim için dua edin:\n\n"${item.duaText}"\n\n— Vakitli uygulamasından',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.duaText,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.favorite, size: 14, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text('${item.prayedCount} kişi dua etti',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                      )),
              const Spacer(),
              if (!isOwner)
                TextButton.icon(
                  onPressed: () => context
                      .read<DuaKardesligiProvider>()
                      .markPrayed(item.id),
                  icon: const Icon(Icons.volunteer_activism_rounded,
                      size: 16, color: AppColors.primaryGreen),
                  label: const Text('Dua Ettim',
                      style: TextStyle(color: AppColors.primaryGreen)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
