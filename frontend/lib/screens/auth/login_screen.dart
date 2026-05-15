import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rento_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final authProvider = context.read<AuthProvider>();

    bool success;
    if (_isLogin) {
      success = await authProvider.login(email, pass);
    } else {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      success = await authProvider.signUp(email, pass, name: name);
    }

    if (!mounted) return;
    if (authProvider.error != null) {
      _showError(authProvider.error!);
      authProvider.clearError();
    } else if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _submitGoogle() async {
    final authProvider = context.read<AuthProvider>();
    bool success = await authProvider.googleLogin();

    if (!mounted) return;
    if (authProvider.error != null) {
      _showError(authProvider.error!);
      authProvider.clearError();
    } else if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(_isLogin ? 'Login to\nRENTO' : 'Sign Up for\nRENTO', style: theme.textTheme.displayLarge),
                const SizedBox(height: 48),
                
                if (!_isLogin) ...[
                  Text('Full Name', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameCtrl,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(
                      hintText: 'John Doe',
                      hintStyle: const TextStyle(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (v) => !_isLogin && v!.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 20),
                ],

                Text('Email Address', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    hintText: 'user@example.com',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 20),

                Text('Password', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => RentoButton(
                    label: _isLogin ? 'Login' : 'Sign Up',
                    onPressed: _submit,
                    isLoading: auth.isLoading,
                  ),
                ),
                const SizedBox(height: 16),
                
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin ? "Don't have an account? Sign up" : "Already have an account? Login", style: const TextStyle(color: AppColors.accent)),
                  ),
                ),

                const SizedBox(height: 24),
                const Center(child: Text("OR", style: TextStyle(color: AppColors.textSecondary))),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.white),
                      label: const Text('Sign in with Google', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: auth.isLoading ? null : _submitGoogle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
