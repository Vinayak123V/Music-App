import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_providers.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(preferredLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Devotional Profile Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.creamCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.saffronContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🕉️', style: TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null ? (user.displayName ?? 'Devotee') : 'Devotee Guest',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user != null ? user.email : 'Free Devotional Streaming Mode',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ADMINISTRATOR ACCESS',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Preference Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Text(
              'CONTENT & LANGUAGE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.saffronDark, letterSpacing: 0.8),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.saffronPrimary),
            title: const Text('Primary Devotional Language'),
            subtitle: Text(selectedLanguage),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              _showLanguagePicker(context, ref, selectedLanguage);
            },
          ),

          const Divider(indent: 56, color: AppColors.dividerLight),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'ADMINISTRATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.saffronDark, letterSpacing: 0.8),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.saffronDark),
            title: Text(isAdmin ? 'Admin Console & Song Manager' : 'Administrator Login'),
            subtitle: Text(isAdmin ? 'Manage catalog, uploads, and streaming licenses' : 'Authorized publishers & content team'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              if (isAdmin) {
                context.push('/admin/dashboard');
              } else {
                context.push('/admin/login');
              }
            },
          ),

          const Divider(indent: 56, color: AppColors.dividerLight),

          // Legal & About
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'ABOUT & LEGAL',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.saffronDark, letterSpacing: 0.8),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
            title: const Text('About Bhakti Music'),
            subtitle: const Text('Version 1.0.0 (MVP Release)'),
            onTap: () => _showAboutDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Minimal personal data collection & privacy commitments'),
            onTap: () => _showPrivacyPolicy(context),
          ),

          ListTile(
            leading: const Icon(Icons.gavel_rounded, color: AppColors.textSecondary),
            title: const Text('Terms of Service & Licensing Notice'),
            subtitle: const Text('Devotional audio streaming policies'),
            onTap: () => _showTermsDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: AppColors.textSecondary),
            title: const Text('Content Inquiries & Support'),
            subtitle: const Text('support@bhaktimusic.app'),
            onTap: () => _showSupportDialog(context),
          ),

          if (user != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed),
                label: const Text('Sign Out', style: TextStyle(color: AppColors.errorRed)),
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Devotional Language',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: AppConstants.supportedLanguages.map((lang) {
                    return ListTile(
                      title: Text(lang),
                      trailing: lang == current ? const Icon(Icons.check, color: AppColors.saffronPrimary) : null,
                      onTap: () {
                        ref.read(preferredLanguageProvider.notifier).setLanguage(lang);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Text('🕉️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Bhakti Music'),
          ],
        ),
        content: const Text(
          'Bhakti Music is an authentic, dedicated spiritual streaming application bringing sacred bhajans, aartis, mantras, and meditative chants to devotees worldwide. Focused on peace, reverence, and spiritual upliftment.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Bhakti Music respects your spiritual journey and personal privacy. We do not sell user data to advertising brokers. Anonymous playback metrics are used solely to improve streaming reliability and catalog discovery. Audio files are streamed securely via Firebase Cloud Storage.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('I Understand')),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terms of Service & Rights Notice'),
        content: const SingleChildScrollView(
          child: Text(
            'All devotional audio tracks available on Bhakti Music are streamed under authorized agreements, copyright licenses, or traditional public domain devotional compendiums. Commercial copying or unauthorized ripping is strictly prohibited.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Support & Rights Inquiries'),
        content: const Text(
          'For rights holders, artist collaborations, or technical streaming support:\n\nEmail: support@bhaktimusic.app\nOffice: Bangalore & Varanasi, India',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
