import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/location_provider.dart';
import 'package:vakitli/providers/profile_provider.dart';
import 'package:vakitli/screens/location/city_selection_screen.dart';
import 'package:vakitli/services/cloud_sync_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  final _nameController = TextEditingController();
  bool _saving = false;

  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prev() {
    if (_page > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  bool _canProceed() {
    return switch (_page) {
      0 => _nameController.text.trim().isNotEmpty,
      _ => true,
    };
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final location = context.read<LocationProvider>();
    final profile = context.read<ProfileProvider>();

    await CloudSyncService.saveProfile(
      displayName: _nameController.text.trim(),
      gender: profile.gender == Gender.female ? 'female' : 'male',
      city: location.currentLocation?.cityName ?? 'İstanbul',
      lat: location.currentLocation?.latitude ?? 41.0082,
      lng: location.currentLocation?.longitude ?? 28.9784,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _page, total: _totalPages),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _NamePage(controller: _nameController, onChanged: () => setState(() {})),
                  const _GenderPage(),
                  const _CityPage(),
                ],
              ),
            ),
            _NavBar(
              page: _page,
              total: _totalPages,
              canProceed: _canProceed(),
              saving: _saving,
              onPrev: _prev,
              onNext: _next,
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= current ? Theme.of(context).colorScheme.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int page;
  final int total;
  final bool canProceed;
  final bool saving;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _NavBar({
    required this.page,
    required this.total,
    required this.canProceed,
    required this.saving,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page == total - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (page > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Geri'),
              ),
            ),
          if (page > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (canProceed && !saving)
                  ? (isLast ? onFinish : onNext)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isLast ? 'Başlayalım!' : 'İleri',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: İsim ───────────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _NamePage({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Hoş Geldiniz! 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Sizi nasıl çağıralım?',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 40),
          TextFormField(
            controller: controller,
            onChanged: (_) => onChanged(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Adınız',
              hintText: 'örn. Ahmet',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Cinsiyet ────────────────────────────────────────────────────────

class _GenderPage extends StatelessWidget {
  const _GenderPage();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Cinsiyetiniz',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Bazı özellikler cinsiyete göre farklılaşır.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 40),
          _GenderCard(
            icon: Icons.male_rounded,
            label: 'Erkek',
            selected: !profile.isFemale,
            onTap: () => profile.setGender(Gender.male),
          ),
          const SizedBox(height: 16),
          _GenderCard(
            icon: Icons.female_rounded,
            label: 'Kadın',
            selected: profile.isFemale,
            onTap: () => profile.setGender(Gender.female),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderCard(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Theme.of(context).colorScheme.primary : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: selected ? Theme.of(context).colorScheme.primary : null,
                )),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Şehir ───────────────────────────────────────────────────────────

class _CityPage extends StatelessWidget {
  const _CityPage();

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final cityName = location.currentLocation?.cityName ?? 'Seçilmedi';

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Şehriniz',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Namaz vakitleri konumunuza göre hesaplanır.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () async {
              await location.detectCurrentLocation();
            },
            icon: location.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.gps_fixed_rounded),
            label: const Text('GPS ile Otomatik Bul'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CitySelectionScreen()));
            },
            icon: const Icon(Icons.location_city_rounded),
            label: const Text('Şehir Listesinden Seç'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (location.currentLocation != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(cityName,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

