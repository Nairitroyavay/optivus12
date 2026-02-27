import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';

/// AI Coach Chat screen — "Liquid Glass" design inspired by Dribbble reference.
///
/// Displays a chat conversation with the AI coach persona (Father/Arjun),
/// glassmorphism message bubbles, action card pills, Chat/Voice toggle,
/// and a redesigned "Ask anything" input bar with shortcut buttons.
class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  /// Current mode: 0 = Chat, 1 = Voice
  int _modeIndex = 0;

  // Demo messages
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          "Good morning, son. I saw you got some solid rest last night. That's good. You ready to tackle that big project today? ☀️",
      isUser: false,
    ),
    _ChatMessage(
      text:
          'Yeah, dad. I feel pretty good. Thinking of breaking down the marketing plan first.',
      isUser: true,
    ),
    _ChatMessage(
      text:
          "Smart move. Don't try to swallow the whole ocean at once. You've got a couple of hours open now. Let's look at who we're actually selling to first, alright?",
      isUser: false,
    ),
  ];

  static const _actionCards = [
    _ActionCardData(title: 'Analyze Week', icon: Icons.analytics_rounded),
    _ActionCardData(title: 'Adjust Plan', icon: Icons.tune_rounded),
    _ActionCardData(title: 'Quick Goals', icon: Icons.flag_rounded),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────
          _buildHeader(),

          // ── Action Cards Row ───────────────────────────
          _buildActionCardsRow(),

          // ── Messages ───────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildDateSeparator();
                final msg = _messages[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: msg.isUser
                      ? _buildUserBubble(msg.text)
                      : _buildAiBubble(msg.text),
                );
              },
            ),
          ),

          // ── Input Area ─────────────────────────────────
          _buildInputArea(bottomPadding),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Header — Avatar, Chat/Voice toggle, History icon
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: CustomPaint(
          painter: _HeaderGlassPainter(),
          child: Container(
            padding: const EdgeInsets.only(
              top: 56,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF99E9FF).withValues(alpha: 0.85),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.50),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row — Avatar + Chat/Voice toggle + History
                Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.face_6_rounded,
                        size: 24,
                        color: OptivusTheme.primaryText,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Chat / Voice toggle pill
                    Expanded(child: _buildModeToggle()),

                    const SizedBox(width: 12),

                    // History icon
                    GestureDetector(
                      onTap: () {},
                      child: HomeLiquidGlass(
                        shape: BoxShape.circle,
                        borderRadius: 20,
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 22,
                          color: OptivusTheme.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title row — name + online status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coach Arjun',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: OptivusTheme.primaryText,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '(Father)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: OptivusTheme.secondaryText.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: OptivusTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Chat / Voice mode toggle (frosted glass pill)
  // ═══════════════════════════════════════════════════════════
  Widget _buildModeToggle() {
    return HomeLiquidGlass(
      borderRadius: 28,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            isActive: _modeIndex == 0,
            onTap: () => setState(() => _modeIndex = 0),
          ),
          _buildToggleOption(
            icon: Icons.graphic_eq_rounded,
            label: 'Voice',
            isActive: _modeIndex == 1,
            onTap: () => setState(() => _modeIndex = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isActive
                ? Colors.white.withValues(alpha: 0.85)
                : Colors.transparent,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? OptivusTheme.primaryText
                    : OptivusTheme.secondaryText.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? OptivusTheme.primaryText
                      : OptivusTheme.secondaryText.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Action Cards — horizontally scrollable frosted glass pills
  // ═══════════════════════════════════════════════════════════
  Widget _buildActionCardsRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SizedBox(
        height: 56,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _actionCards.length + 1, // +1 for the leading "+" button
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {},
                  child: HomeLiquidGlass(
                    shape: BoxShape.circle,
                    borderRadius: 28,
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: OptivusTheme.primaryText.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }
            final card = _actionCards[index - 1];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {},
                child: HomeLiquidGlass(
                  borderRadius: 28,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        card.icon,
                        size: 20,
                        color: OptivusTheme.primaryText.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OptivusTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Date separator
  // ═══════════════════════════════════════════════════════════
  Widget _buildDateSeparator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 4),
        child: HomeLiquidGlass(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            'Today, 9:41 AM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: OptivusTheme.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AI Bubble (left-aligned, with avatar)
  // ═══════════════════════════════════════════════════════════
  Widget _buildAiBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.face_6_rounded,
            size: 22,
            color: OptivusTheme.secondaryText,
          ),
        ),
        // Bubble
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: CustomPaint(
                painter: _BubbleGlassPainter(borderRadius: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFFAEB).withValues(alpha: 0.80),
                        const Color(0xFFFFFAEB).withValues(alpha: 0.45),
                        const Color(0xFFFFFAEB).withValues(alpha: 0.40),
                        const Color(0xFFFFFAEB).withValues(alpha: 0.65),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: OptivusTheme.primaryText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // User Bubble (right-aligned)
  // ═══════════════════════════════════════════════════════════
  Widget _buildUserBubble(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: CustomPaint(
                painter: _BubbleGlassPainter(borderRadius: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.92),
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.48),
                        Colors.white.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.80),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: OptivusTheme.accentGold.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: OptivusTheme.primaryText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Input Area — cyan accent glow + "Ask anything" field
  //              + shortcut buttons (plus, camera, gallery)
  //              + Upgrade pill on the right
  // ═══════════════════════════════════════════════════════════
  Widget _buildInputArea(double bottomInset) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: CustomPaint(
          painter: _InputBarGlassPainter(),
          child: Container(
            padding: EdgeInsets.only(
              bottom: bottomInset > 0 ? bottomInset : 90,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.80),
                  Colors.white.withValues(alpha: 0.50),
                  Colors.white.withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Cyan accent glow line ──
                _buildCyanGlowLine(),
                const SizedBox(height: 10),

                // ── "Ask anything" text field ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HomeLiquidGlass(
                    borderRadius: 28,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Ask anything…',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: OptivusTheme.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                left: 20,
                                top: 14,
                                bottom: 14,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: OptivusTheme.primaryText,
                            ),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                        // Microphone icon
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              child: Icon(
                                Icons.mic_none_rounded,
                                color: OptivusTheme.secondaryText.withValues(
                                  alpha: 0.6,
                                ),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Shortcut buttons row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Plus button
                      _buildShortcutCircle(
                        icon: Icons.add_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      // Camera button
                      _buildShortcutCircle(
                        icon: Icons.camera_alt_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      // Gallery button
                      _buildShortcutCircle(
                        icon: Icons.photo_library_outlined,
                        onTap: () {},
                      ),
                      const Spacer(),
                      // Upgrade pill
                      GestureDetector(
                        onTap: () {},
                        child: HomeLiquidGlass(
                          borderRadius: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Upgrade',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: OptivusTheme.primaryText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: OptivusTheme.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A thin glowing cyan accent line — mimics the reference's neon focus bar
  Widget _buildCyanGlowLine() {
    return Center(
      child: Container(
        width: 60,
        height: 4,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: const Color(0xFF22D3EE),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.50),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  /// Frosted glass circular shortcut button
  Widget _buildShortcutCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: HomeLiquidGlass(
        shape: BoxShape.circle,
        borderRadius: 22,
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: OptivusTheme.primaryText.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header glass painter — specular highlight
// ─────────────────────────────────────────────────────────────
class _HeaderGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.45),
      topGlow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
// Bubble glass painter — top specular for chat bubbles
// ─────────────────────────────────────────────────────────────
class _BubbleGlassPainter extends CustomPainter {
  final double borderRadius;
  _BubbleGlassPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.save();
    canvas.clipRRect(rr);

    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      topGlow,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BubbleGlassPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
// Input bar glass painter — glow edge
// ─────────────────────────────────────────────────────────────
class _InputBarGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topEdge = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.1, 0.5, 0.9],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 1.5));
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, 1.0),
      topEdge,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _ActionCardData {
  final String title;
  final IconData icon;

  const _ActionCardData({required this.title, required this.icon});
}
