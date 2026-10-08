import 'dart:ui' as ui;
import 'package:imaanly/l10n/app_localizations.dart';
import 'package:imaanly/src/theme/controller/theme_cubit.dart';
import 'package:imaanly/src/theme/controller/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  String _appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(
        () => _appVersion = "Version ${info.version} (${info.buildNumber})",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = themeState.primary;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF3F8F5),
      body: Stack(
        children: [
          // ── Premium Animated Background ──
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.15),
                ),
              ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOutSine,
                  ),
            ),
          if (isDark)
            Positioned(
              bottom: -150,
              left: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.08),
                ),
              ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: const Duration(seconds: 6),
                    curve: Curves.easeInOutSine,
                  ),
            ),

          // ── Main Content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                stretch: true,
                expandedHeight: 280,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Subtly blurred backdrop for the top
                      Positioned.fill(
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Gap(40),
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                "assets/img/Quran_Logo_v3.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                curve: Curves.easeOutBack,
                                duration: const Duration(milliseconds: 700),
                              )
                              .fadeIn(),
                          const Gap(16),
                          Text(
                            l10n.appFullName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _appVersion,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Mission Statement Glass Card ──
                    _buildGlassCard(
                      isDark: isDark,
                      primary: primary,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_rounded, color: primary, size: 24),
                              const Gap(8),
                              const Text(
                                "App message",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          Text(
                            "This work is a pure ongoing charity (sadaqah jariyah) for the sake of Allah. The app is completely free, has no ads, and is available to everyone to benefit from the Book of Allah.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.2).fadeIn(duration: const Duration(milliseconds: 500)),
                    
                    const Gap(24),
                    
.animate().slideY(begin: 0.2).fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 500)),

                    const Gap(32),

                    // ── Features Grid ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "App features",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const Gap(16),
                    _buildFeatureCategory(
                      icon: Icons.menu_book_rounded,
                      title: "Reading & browsing",
                      items: [
                        "Print-matching Mushaf mode",
                        "Advanced ayah-by-ayah interaction",
                        "Quranic fonts (Hafs, Warsh, Tajweed)",
                        "Instant search with interactive precision",
                      ],
                      primary: primary,
                      isDark: isDark,
                    ),
                    const Gap(16),
                    _buildFeatureCategory(
                      icon: Icons.headset_rounded,
                      title: "Audio & recitation",
                      items: [
                        "40+ verified reciters",
                        "Recite ayat or words with smart selection",
                        "Download audio to use offline",
                      ],
                      primary: primary,
                      isDark: isDark,
                    ),
                    const Gap(16),
                    _buildFeatureCategory(
                      icon: Icons.library_books_rounded,
                      title: "Resources & tafsirs",
                      items: [
                        "Multiple tafsirs (Muyassar, Ibn Kathir for specialists)",
                        "Complete grammatical analysis of the ayat",
                        "Translations in many living languages",
                      ],
                      primary: primary,
                      isDark: isDark,
                    ),

                    const Gap(40),

                    // ── Credits ──
                    _buildCreditsCard(themeState, isDark),

                    const Gap(40),

                    // ── Footer ──
                    _buildFooter(isDark),
                    const Gap(40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required bool isDark,
    required Color primary,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFeatureCategory({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color primary,
    required bool isDark,
  }) {
    return _buildGlassCard(
      isDark: isDark,
      primary: primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
            ],
          ),
          const Gap(16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: primary.withValues(alpha: 0.5), blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().slideY(begin: 0.1).fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildCreditsCard(ThemeState themeState, bool isDark) {
    final primary = themeState.primary;
    final muted = isDark ? Colors.white60 : Colors.black54;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11332A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFD3E2DA)),
      ),
      child: Column(
        children: [
          Text(
            "REDESIGNED & MAINTAINED BY",
            style: TextStyle(fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: muted),
          ),
          const Gap(8),
          Text(
            "RumiTech Solution",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primary),
          ),
          const Gap(18),
          Divider(color: isDark ? Colors.white12 : const Color(0xFFD3E2DA)),
          const Gap(14),
          Text(
            "ORIGINAL APP BY",
            style: TextStyle(fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: muted),
          ),
          const Gap(6),
          Text(
            "IDRISIUM Corp",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
          ),
          const Gap(2),
          Text("Founder: Idris Ghamid", style: TextStyle(fontSize: 13, color: muted)),
          const Gap(16),
          Text(
            "Released under the Apache License 2.0 with a Waqf condition: the app must stay free for everyone and must never be sold or monetised.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: muted),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 40, height: 1, color: isDark ? Colors.white24 : Colors.black26),
            const Gap(12),
            Icon(Icons.star_rounded, size: 14, color: isDark ? Colors.white38 : Colors.black38),
            const Gap(12),
            Container(width: 40, height: 1, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
        const Gap(16),
        Text(
          "\u00a9 2026 RUMITECH SOLUTION",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
