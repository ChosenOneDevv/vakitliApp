import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/auth_provider.dart' as ap;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();
  final _regPassConfirm = TextEditingController();
  bool _loginObscure = true;
  bool _regObscure = true;
  bool _regConfirmObscure = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    _regPassConfirm.dispose();
    super.dispose();
  }

  Future<void> _login(ap.AuthProvider auth) async {
    if (!_loginFormKey.currentState!.validate()) return;
    final ok = await auth.signIn(_loginEmail.text.trim(), _loginPass.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Giriş başarısız.')),
      );
    }
  }

  Future<void> _register(ap.AuthProvider auth) async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_regPass.text != _regPassConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreler eşleşmiyor.')),
      );
      return;
    }
    final ok = await auth.register(_regEmail.text.trim(), _regPass.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Kayıt başarısız.')),
      );
    }
  }

  Future<void> _googleSignIn(ap.AuthProvider auth) async {
    final ok = await auth.signInWithGoogle();
    if (!ok && mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
    }
  }

  Future<void> _forgotPassword(ap.AuthProvider auth) async {
    if (_loginEmail.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce e-posta adresinizi girin.')),
      );
      return;
    }
    final ok = await auth.sendPasswordReset(_loginEmail.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Şifre sıfırlama bağlantısı gönderildi.'
              : 'Bir hata oluştu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            _Logo(),
            const SizedBox(height: 32),
            TabBar(
              controller: _tab,
              tabs: const [
                Tab(text: 'Giriş Yap'),
                Tab(text: 'Kayıt Ol'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.gold,
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _LoginTab(
                    formKey: _loginFormKey,
                    email: _loginEmail,
                    pass: _loginPass,
                    obscure: _loginObscure,
                    onToggleObscure: () =>
                        setState(() => _loginObscure = !_loginObscure),
                    onLogin: () => _login(auth),
                    onForgot: () => _forgotPassword(auth),
                    onGoogleSignIn: () => _googleSignIn(auth),
                    loading: auth.loading,
                  ),
                  _RegisterTab(
                    formKey: _registerFormKey,
                    email: _regEmail,
                    pass: _regPass,
                    passConfirm: _regPassConfirm,
                    obscure: _regObscure,
                    confirmObscure: _regConfirmObscure,
                    onToggleObscure: () =>
                        setState(() => _regObscure = !_regObscure),
                    onToggleConfirmObscure: () =>
                        setState(() => _regConfirmObscure = !_regConfirmObscure),
                    onRegister: () => _register(auth),
                    onGoogleSignIn: () => _googleSignIn(auth),
                    loading: auth.loading,
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

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.mosque_rounded,
              color: AppColors.gold, size: 40),
        ),
        const SizedBox(height: 12),
        Text(
          'Vakitli',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hesabınıza giriş yapın',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}

class _LoginTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController pass;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onForgot;
  final VoidCallback onGoogleSignIn;
  final bool loading;

  const _LoginTab({
    required this.formKey,
    required this.email,
    required this.pass,
    required this.obscure,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onForgot,
    required this.onGoogleSignIn,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _EmailField(controller: email),
            const SizedBox(height: 16),
            _PasswordField(
              controller: pass,
              label: 'Şifre',
              obscure: obscure,
              onToggle: onToggleObscure,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgot,
                child: Text('Şifremi Unuttum',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            const SizedBox(height: 8),
            _SubmitButton(
                label: 'Giriş Yap', onPressed: onLogin, loading: loading),
            const SizedBox(height: 16),
            _Divider(),
            const SizedBox(height: 16),
            _GoogleButton(onPressed: onGoogleSignIn, loading: loading),
          ],
        ),
      ),
    );
  }
}

class _RegisterTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController pass;
  final TextEditingController passConfirm;
  final bool obscure;
  final bool confirmObscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleConfirmObscure;
  final VoidCallback onRegister;
  final VoidCallback onGoogleSignIn;
  final bool loading;

  const _RegisterTab({
    required this.formKey,
    required this.email,
    required this.pass,
    required this.passConfirm,
    required this.obscure,
    required this.confirmObscure,
    required this.onToggleObscure,
    required this.onToggleConfirmObscure,
    required this.onRegister,
    required this.onGoogleSignIn,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _EmailField(controller: email),
            const SizedBox(height: 16),
            _PasswordField(
              controller: pass,
              label: 'Şifre',
              obscure: obscure,
              onToggle: onToggleObscure,
              minLength: 6,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: passConfirm,
              label: 'Şifre Tekrar',
              obscure: confirmObscure,
              onToggle: onToggleConfirmObscure,
            ),
            const SizedBox(height: 24),
            _SubmitButton(
                label: 'Kayıt Ol', onPressed: onRegister, loading: loading),
            const SizedBox(height: 16),
            _Divider(),
            const SizedBox(height: 16),
            _GoogleButton(onPressed: onGoogleSignIn, loading: loading),
          ],
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'E-posta',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'E-posta gerekli.';
        if (!v.contains('@')) return 'Geçerli bir e-posta girin.';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final int? minLength;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.minLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Şifre gerekli.';
        if (minLength != null && v.length < minLength!) {
          return 'Şifre en az $minLength karakter olmalı.';
        }
        return null;
      },
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('veya', style: TextStyle(color: Colors.grey[500])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool loading;
  const _GoogleButton({required this.onPressed, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google_logo.png',
                width: 20, height: 20,
                errorBuilder: (_, e, s) =>
                    const Icon(Icons.g_mobiledata_rounded, size: 24)),
            const SizedBox(width: 12),
            const Text('Google ile devam et',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const _SubmitButton(
      {required this.label, required this.onPressed, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
