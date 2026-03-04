import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';

/// User Profile screen — Stitch "Optivus User Profile" design.
///
/// Shows avatar, identity statement, strengths/areas‐to‐improve
/// tags, and a preferences settings list.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ── Top Bar ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 56,
                left: 20,
                right: 20,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {},
                  ),
                  Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: OptivusTheme.secondaryText,
                    ),
                  ),
                  _GlassBtn(icon: Icons.more_horiz_rounded, onTap: () {}),
                ],
              ),
            ),
          ),

          // ── Avatar + Name ─────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Avatar with edit badge
                Stack(
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            OptivusTheme.accentGold.withValues(alpha: 0.3),
                            Colors.grey.shade300,
                          ],
                        ),
                      ),
                      child: const ClipOval(
                        child: Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: OptivusTheme.accentGold.withValues(
                            red: 0.85,
                            green: 0.55,
                            blue: 0.12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nairit',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: OptivusTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@nairit_optivus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: OptivusTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Identity Statement ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildIdentityCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Strengths ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTagSection(
                label: 'STRENGTHS',
                tags: const [
                  ('Strategic', Icons.bolt_rounded),
                  ('Focused', Icons.gps_fixed_rounded),
                  ('Creative', Icons.lightbulb_outline_rounded),
                ],
                isStrength: true,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Areas to Improve ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTagSection(
                label: 'AREAS TO IMPROVE',
                tags: const [
                  ('Impatient', Icons.hourglass_top_rounded),
                  ('Perfectionist', Icons.architecture_rounded),
                ],
                isStrength: false,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Preferences ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildPreferences(),
            ),
          ),

          // ── Version ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 120),
              child: Center(
                child: Text(
                  'Optivus v2.4.0 (Build 302)',
                  style: TextStyle(
                    fontSize: 12,
                    color: OptivusTheme.secondaryText.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Identity Statement Card
  // ═══════════════════════════════════════════════════════════
  Widget _buildIdentityCard() {
    return HomeLiquidGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fingerprint_rounded,
                size: 20,
                color: OptivusTheme.accentGold.withValues(
                  red: 0.85,
                  green: 0.55,
                  blue: 0.12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'IDENTITY STATEMENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"Optimizing life through clarity and purpose. Driven by data, fueled by ambition."',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: OptivusTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Tags Section (Strengths / Areas to Improve)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTagSection({
    required String label,
    required List<(String, IconData)> tags,
    required bool isStrength,
  }) {
    final Color fg = isStrength
        ? const Color(0xFF065F46)
        : const Color(0xFF92400E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.4),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return HomeLiquidGlass(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tag.$2, size: 16, color: fg),
                  const SizedBox(width: 6),
                  Text(
                    tag.$1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Preferences Card
  // ═══════════════════════════════════════════════════════════
  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'PREFERENCES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.4),
            ),
          ),
        ),
        HomeLiquidGlass(
          borderRadius: 24,
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.cloud_download_rounded,
                iconBg: const Color(0xFFDBEAFE),
                iconFg: const Color(0xFF137FEC),
                label: 'Export Data',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                showDivider: true,
                onTap: () {},
              ),
              _SettingsRow(
                icon: Icons.lock_rounded,
                iconBg: const Color(0xFFD1FAE5),
                iconFg: const Color(0xFF059669),
                label: 'Privacy & Security',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                showDivider: true,
                onTap: () {},
              ),
              _SettingsRow(
                icon: Icons.dark_mode_rounded,
                iconBg: const Color(0xFFE0E7FF),
                iconFg: const Color(0xFF4F46E5),
                label: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  activeTrackColor: const Color(0xFF137FEC),
                ),
                showDivider: true,
              ),
              _SettingsRow(
                icon: Icons.help_outline_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconFg: const Color(0xFFD97706),
                label: 'Help & Support',
                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                showDivider: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Settings Row
// ─────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final Widget trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.trailing,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, size: 18, color: iconFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: OptivusTheme.primaryText,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Glass Button
// ─────────────────────────────────────────────────────────────
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: HomeLiquidGlass(
          shape: BoxShape.circle,
          child: Icon(icon, size: 18, color: OptivusTheme.primaryText),
        ),
      ),
    );
  }
}
