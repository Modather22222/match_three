// =============================================================================
// SETTINGS SCREEN (Reactive)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/providers/settings_provider.dart';
import 'package:flutter_game/providers/save_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final saveService = ref.watch(saveServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0A0A14)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'SETTINGS',
                        style: TextStyle(
                          color: Color(0xFFF0C040),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sound toggle
                _buildSettingTile(
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  value: settings.soundEnabled,
                  onChanged: (v) {
                    ref.read(settingsProvider.notifier).toggleSound(v);
                    saveService.soundEnabled = v;
                  },
                ),

                // Music toggle
                _buildSettingTile(
                  icon: Icons.music_note,
                  title: 'Background Music',
                  value: settings.musicEnabled,
                  onChanged: (v) {
                    ref.read(settingsProvider.notifier).toggleMusic(v);
                  },
                ),

                // Notifications toggle
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  value: settings.notificationsEnabled,
                  onChanged: (v) {
                    ref.read(settingsProvider.notifier).toggleNotifications(v);
                  },
                ),

                const SizedBox(height: 20),

                // Account section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundColor: Color(0xFF2C3E50)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Guest Player', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const Text('Sign in for cloud saves', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to sign-in with Supabase Auth
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Sign In', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Cloud sync
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // TODO: Implement cloud sync with actual Supabase project credentials
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cloud sync requires Supabase setup'), backgroundColor: Color(0xFFE74C3C)),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload, color: Color(0xFFF0C040)),
                      label: const Text('Sync to Cloud', style: TextStyle(color: Color(0xFFF0C040))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF0C040)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),

                // Reset data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF16213E),
                            title: const Text('Reset Data', style: TextStyle(color: Color(0xFFFF4444))),
                            content: const Text('Are you sure? This cannot be undone.', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(onPressed: () {
                                Navigator.pop(ctx);
                                saveService.resetToDefaults();
                                ref.read(saveDataProvider.notifier).reload();
                                ref.read(settingsProvider.notifier).loadFromSave(saveService);
                              }, child: const Text('RESET', style: TextStyle(color: Color(0xFFFF4444)))),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever, color: Color(0xFFFF4444)),
                      label: const Text('Reset All Data', style: TextStyle(color: Color(0xFFFF4444))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF0C040)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF2ECC71),
        activeTrackColor: const Color(0x992ECC71),
      ),
      tileColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}