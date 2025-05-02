import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Layout.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authService.init();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserProfile();
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWrapper(
      title: 'Perfil',
      child: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.person, size: 70, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _userData['name'] ?? 'Sense nom',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userData['email'] ?? 'Sense email',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  _buildProfileItem(
                                    context,
                                    Icons.badge,
                                    'ID',
                                    _userData['id'] ?? 'No disponible',
                                  ),
                                  const Divider(),
                                  _buildProfileItem(
                                    context,
                                    Icons.cake,
                                    'Edat',
                                    _userData['age']?.toString() ?? 'No disponible',
                                  ),
                                  const Divider(),
                                  _buildProfileItem(
                                    context,
                                    Icons.email,
                                    'Email',
                                    _userData['email'] ?? 'No disponible',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Configuració del compte',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSettingItem(
                                    context,
                                    Icons.edit,
                                    'Editar Perfil',
                                    'Actualitza la teva informació personal',
                                    () async {
                                      final result = await context.push('/profile/edit');
                                      if (result == true) {
                                        _loadUserData();
                                      }
                                    },
                                  ),
                                  _buildSettingItem(
                                    context,
                                    Icons.lock,
                                    'Canviar contrasenya',
                                    'Actualitzar la contrasenya',
                                    () async {
                                      final result = await context.push('/profile/change-password');
                                      if (result == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Contrasenya actualitzada correctament'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await _authService.logout();
                                if (mounted) {
                                  context.go('/login');
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al tancar sessió: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('TANCAR SESSIÓ'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
