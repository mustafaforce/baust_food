import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SignupRole { customer, vendor }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  SignupRole _selectedRole = SignupRole.customer;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final fullName = _fullNameController.text.trim();
      final isVendor = _selectedRole == SignupRole.vendor;
      final role = isVendor ? 'vendor' : 'customer';

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      // For vendors, update profile to set is_approved = false
      if (isVendor) {
        await Supabase.instance.client.from('profiles').update({
          'is_approved': false,
        }).eq('id', response.user!.id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVendor
                ? 'Account created. Admin will approve your vendor account.'
                : 'Account created. Please check your email to verify.',
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('signup-form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return 'Enter your full name';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Enter your email';
              if (!email.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              final password = (value ?? '').trim();
              if (password.isEmpty) return 'Enter a password';
              if (password.length < 6) {
                return 'Password must be at least 6 chars';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
            validator: (value) {
              final confirm = (value ?? '').trim();
              if (confirm.isEmpty) return 'Confirm your password';
              if (confirm != _passwordController.text.trim()) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Select your role:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<SignupRole>(
            segments: const [
              ButtonSegment(
                value: SignupRole.customer,
                label: Text('Customer'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment(
                value: SignupRole.vendor,
                label: Text('Vendor'),
                icon: Icon(Icons.storefront),
              ),
            ],
            selected: {_selectedRole},
            onSelectionChanged: (Set<SignupRole> selection) {
              setState(() {
                _selectedRole = selection.first;
              });
            },
          ),
          if (_selectedRole == SignupRole.vendor) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vendor accounts require admin approval before accessing the dashboard.',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),
          ),
        ],
      ),
    );
  }
}