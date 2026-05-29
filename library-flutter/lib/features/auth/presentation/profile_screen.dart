import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).value;
    final user = auth?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Username'),
                              subtitle: Text(user.username),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text(user.email),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(user.isAdmin ? Icons.shield : Icons.badge),
                              title: const Text('Role'),
                              subtitle: Text(user.role),
                            ),
                            if (user.createdAt != null) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('Joined'),
                                subtitle: Text(
                                  DateFormat.yMMMd().add_Hm().format(user.createdAt!.toLocal()),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user.isAdmin)
                        OutlinedButton.icon(
                          onPressed: () => context.go('/admin'),
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Admin dashboard'),
                        ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Log out'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
