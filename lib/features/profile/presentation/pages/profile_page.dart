import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/hero_band.dart';
import 'package:baust_food/app/widgets/section_eyebrow.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String _role = 'customer';

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final existing = await _client
          .from('profiles')
          .select('full_name, phone, department, bio, role')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': user.userMetadata?['full_name'] as String? ?? '',
        }, onConflict: 'id');
      }

      final profile = existing ??
          {
            'full_name': user.userMetadata?['full_name'] as String? ?? '',
            'phone': '',
            'department': '',
            'bio': '',
            'role': 'customer',
          };

      if (!mounted) return;
      setState(() {
        _fullNameController.text = (profile['full_name'] as String?) ?? '';
        _phoneController.text = (profile['phone'] as String?) ?? '';
        _departmentController.text = (profile['department'] as String?) ?? '';
        _bioController.text = (profile['bio'] as String?) ?? '';
        _role = (profile['role'] as String?) ?? 'customer';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final fullName = _fullNameController.text.trim();

      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'phone': _nullIfEmpty(_phoneController.text),
        'department': _nullIfEmpty(_departmentController.text),
        'bio': _nullIfEmpty(_bioController.text),
      }, onConflict: 'id');

      await _client.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context, rootNavigator: true);
              await _client.auth.signOut();
              if (!context.mounted) return;
              navigator.popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroBand(
                    eyebrow: _role.toUpperCase(),
                    headline: (_fullNameController.text.isEmpty
                            ? 'Your\nProfile'
                            : _fullNameController.text)
                        .toUpperCase(),
                    subhead: user?.email,
                    trailing: const SpeechmarkOrb(icon: Icons.person),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl2),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionEyebrow(text: 'Edit Details'),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _departmentController,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _bioController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.notes_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: const Text('Save Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
