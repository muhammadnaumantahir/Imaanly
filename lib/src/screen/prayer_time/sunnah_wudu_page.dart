import 'package:flutter/material.dart';
import 'package:imaanly/src/theme/app_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../features/sunnah/services/sunnah_share_service.dart';
import '../../../features/sunnah/presentation/screens/image_customization_screen.dart';

// Design System Colors (Wahy + Ayah Hybrid)
const _primaryGreen = Color(0xFF4A7C59);
const _accentGold = Color(0xFFC9A84C);
const _darkBg = Color(0xFF0E2E25);
const _cardDark = Color(0xFF11332A);
const _cardLight = Color(0xFFFFFFFF);
const _textLight = Color(0xFFF3F8F5);
const _textDark = Color(0xFF2C2C2C);  
const _mutedLight = Color(0xFFB8BCC2);
const _mutedDark = Color(0xFF6B6B6B); 

class SunnahWuduPage extends StatelessWidget {
  const SunnahWuduPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? _darkBg : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: Text(
          'Sunnahs & Etiquette of Wudu',
          style: AppFonts.body(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? _cardDark : _cardLight,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introduction Card
          _buildIntroCard(isDark),
          const Gap(16),
          
          // Importance Section
          _buildImportanceCard(isDark),
          const Gap(16),
          
          // Sunnah Steps
          _buildSectionHeader("Sunnah Steps of Wudu", Icons.format_list_numbered_rounded, isDark),
          const Gap(12),
          ..._wuduSteps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildStepCard(
                context: context,
                number: entry.key + 1,
                step: entry.value,
                isDark: isDark,
              ),
            );
          }),
          
          const Gap(16),
          
          // Scholarly Statements
          _buildSectionHeader("Scholars' Statements", Icons.school_rounded, isDark),
          const Gap(12),
          ..._scholarStatements.map((statement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildScholarCard(statement, isDark),
            );
          }),
          
          const Gap(16),
          
          // Additional Benefits
          _buildSectionHeader("Additional Benefits", Icons.lightbulb_rounded, isDark),
          const Gap(12),
          ..._additionalBenefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBenefitCard(benefit, isDark),
            );
          }),
          
          const Gap(80),
        ],
      ),
    );
  }

  Widget _buildIntroCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _primaryGreen.withValues(alpha: 0.15),
            _primaryGreen.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "Wudu: Purification and Worship",
                  style: AppFonts.body(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            "Wudu is one of the conditions for the validity of prayer, and it is a specific purification performed on specific parts of the body. The Prophet ﷺ urged performing wudu thoroughly and perfectly, and Allah the Almighty made great reward for it.",
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _mutedLight : _mutedDark,
              height: 1.8,
            ),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: _primaryGreen,
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    'Allah the Almighty said: "يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ..." [Al-Ma\'idah 5:6]',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                      height: 1.8,
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

  Widget _buildImportanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: _accentGold,
                  size: 24,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "The Virtue of Wudu",
                  style: AppFonts.body(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          _buildHadithBox(
            'Narrated by Abu Hurairah (may Allah be pleased with him) that the Messenger of Allah ﷺ said: "When a Muslim or believing servant performs wudu and washes his face, every sin he looked at with his eyes leaves his face with the water, or with the last drop of water. When he washes his hands, every sin his hands committed leaves his hands with the water, or with the last drop of water. When he washes his feet, every sin his feet walked toward leaves with the water, or with the last drop of water, until he comes out cleansed of sins."',
            'Narrated by Muslim',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(10),
        Icon(
          icon,
          color: _primaryGreen,
          size: 24,
        ),
        const Gap(8),
        Text(
          title,
          style: AppFonts.body(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? _textLight : _textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required int number,
    required WuduStep step,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryGreen, _primaryGreen.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: AppFonts.body(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  step.title,
                  style: AppFonts.body(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
              if (step.isSunnah)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Sunnah",
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _accentGold,
                    ),
                  ),
                ),
              const Gap(8),
              IconButton(
                onPressed: () => _shareSunnah(
                  context: context,
                  title: step.title,
                  description: step.description,
                  evidence: step.evidence,
                  type: "Sunnahs of wudu",
                ),
                icon: const Icon(Icons.share_rounded),
                iconSize: 20,
                color: const Color(0xFF10B981),
                tooltip: "Share",
              ),
            ],
          ),
          const Gap(12),
          Text(
            step.description,
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _mutedLight : _mutedDark,
              height: 1.8,
            ),
          ),
          if (step.evidence != null) ...[
            const Gap(12),
            _buildEvidenceBox(step.evidence!, isDark),
          ],
        ],
      ),
    );
  }

  // Share Sunnah Function - WORKING VERSION
  Future<void> _shareSunnah({
    required BuildContext context,
    required String title,
    required String description,
    String? evidence,
    required String type,
  }) async {
    // Show share options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? _cardDark : _cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 1)),
              const Gap(20),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      "Share Sunnah",
                      style: AppFonts.body(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.1),
                  ),
                ],
              ),
              const Gap(24),
              
              // Share as Text
              _shareOptionButton(
                icon: Icons.text_fields_rounded,
                label: "Share as text",
                subtitle: "Copy and share the text",
                color: const Color(0xFF3B82F6),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await SunnahShareService.shareAsText(
                      title: title,
                      description: description,
                      evidence: evidence,
                      type: type,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  "The text was copied and shared successfully",
                                  style: AppFonts.body(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "An error occurred while sharing",
                            style: AppFonts.body(fontWeight: FontWeight.w700),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideX(begin: 0.1),
              const Gap(12),
              
              // Share as Image
              _shareOptionButton(
                icon: Icons.image_rounded,
                label: "Share as image",
                subtitle: "Customize and create a professional image",
                color: const Color(0xFFEC4899),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  // Open customization screen
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageCustomizationScreen(
                          title: title,
                          description: description,
                          evidence: evidence,
                          type: type,
                        ),
                      ),
                    );
                  }
                },
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: 0.1),
            ],
          ),
        );
      },
    );
  }
  }

  Widget _shareOptionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? _textLight : _textDark,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceBox(String evidence, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 16,
            color: _primaryGreen,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              evidence,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryGreen,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithBox(String hadith, String source, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: _accentGold,
                size: 20,
              ),
              const Gap(8),
              Text(
                "Hadith",
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _accentGold,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            hadith,
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _textLight : _textDark,
              height: 1.9,
            ),
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              source,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarCard(ScholarStatement statement, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statement.scholar,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ),
                    if (statement.title != null) ...[
                      const Gap(2),
                      Text(
                        statement.title!,
                        style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            statement.statement,
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _mutedLight : _mutedDark,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String benefit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              benefit,
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? _mutedLight : _mutedDark,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Data Models
class WuduStep {
  final String title;
  final String description;
  final String? evidence;
  final bool isSunnah;

  const WuduStep({
    required this.title,
    required this.description,
    this.evidence,
    this.isSunnah = false,
  });
}

class ScholarStatement {
  final String scholar;
  final String? title;
  final String statement;

  const ScholarStatement({
    required this.scholar,
    this.title,
    required this.statement,
  });
}

// Data
final List<WuduStep> _wuduSteps = [
  const WuduStep(
    title: 'The Intention (Niyyah)',
    description: 'Its place is the heart, and it is not prescribed to utter it aloud. The intention is a condition for the validity of wudu.',
    evidence: 'The Prophet ﷺ said: "Actions are judged only by intentions." — Agreed upon (Bukhari & Muslim)',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'Saying Bismillah',
    description: 'He says: "Bismillah" (In the name of Allah) at the beginning of wudu. It is a confirmed sunnah according to the majority of scholars.',
    evidence: 'The Prophet ﷺ said: "There is no wudu for one who does not mention the name of Allah upon it." — Narrated by Abu Dawud and graded hasan by Al-Albani',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'Washing the Hands Three Times',
    description: 'He washes both hands three times at the beginning of wudu, before putting them into the vessel.',
    evidence: 'The Prophet ﷺ used to begin by washing his hands three times. — Agreed upon (Bukhari & Muslim)',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'Rinsing the Mouth and Nose',
    description: 'He rinses his mouth three times and sniffs water into his nose three times, doing so thoroughly unless he is fasting.',
    evidence: 'The Prophet ﷺ said: "And be thorough in sniffing water into the nose, unless you are fasting." — Narrated by At-Tirmidhi and graded sahih by Al-Albani',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'Washing the Face',
    description: 'He washes his face three times, from where the hair of the head grows down to the bottom of the chin, and from ear to ear.',
    evidence: 'Allah the Almighty said: "فَاغْسِلُوا وُجُوهَكُمْ" [Al-Ma\'idah 5:6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'Running Water Through the Beard',
    description: 'He runs water through a thick beard so that it reaches the roots of the hair.',
    evidence: 'The Prophet ﷺ used to run water through his beard during wudu. — Narrated by At-Tirmidhi and graded sahih by Al-Albani',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'Washing the Arms up to the Elbows',
    description: 'He washes his arms including the elbows three times, starting with the right and then the left.',
    evidence: 'Allah the Almighty said: "وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ" [Al-Ma\'idah 5:6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'Running Water Between the Fingers and Toes',
    description: 'He runs water between the fingers of the hands and the toes so that water reaches between them.',
    evidence: 'The Prophet ﷺ said: "And run water between the fingers." — Narrated by At-Tirmidhi and graded sahih by Al-Albani',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'Wiping the Head',
    description: 'He wipes his head once, starting from the front of the head to the back of the neck, then returns his hands to the front.',
    evidence: 'Allah the Almighty said: "وَامْسَحُوا بِرُءُوسِكُمْ" [Al-Ma\'idah 5:6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'Wiping the Ears',
    description: 'He wipes his ears once, the outside and the inside, with fresh water.',
    evidence: 'The Prophet ﷺ said: "The ears are part of the head." — Narrated by At-Tirmidhi and graded sahih by Al-Albani',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'Washing the Feet up to the Ankles',
    description: 'He washes his feet including the ankles three times, starting with the right and then the left.',
    evidence: 'Allah the Almighty said: "وَأَرْجُلَكُمْ إِلَى الْكَعْبَيْنِ" [Al-Ma\'idah 5:6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'Order and Continuity',
    description: 'He performs the parts of wudu in the order Allah mentioned them, and continuously, not delaying the washing of one part until the previous one has dried.',
    evidence: 'The Companions described the wudu of the Prophet ﷺ as ordered and continuous. — Agreed upon (Bukhari & Muslim)',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'The Supplication After Wudu',
    description: 'After finishing wudu he says: "أشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمداً عبده ورسوله" (I bear witness that there is no god but Allah alone, with no partner, and I bear witness that Muhammad is His servant and Messenger).',
    evidence: 'The Prophet ﷺ said: "Whoever performs wudu well and then says: \'I bear witness that there is no god but Allah…\' the eight gates of Paradise are opened for him, and he may enter from whichever he wishes." — Narrated by Muslim',
    isSunnah: true,
  ),
];

final List<ScholarStatement> _scholarStatements = [
  const ScholarStatement(
    scholar: 'Imam An-Nawawi',
    title: 'may Allah have mercy on him (d. 676 AH)',
    statement: 'He said in Al-Majmu\': "Perfecting wudu is part of the completion of faith. It means completing the washing of the limbs and making the water reach everything that must be washed, being thorough in that without extravagance."',
  ),
  const ScholarStatement(
    scholar: 'Ibn Al-Qayyim',
    title: 'may Allah have mercy on him (d. 751 AH)',
    statement: 'He said in Zad Al-Ma\'ad: "The Prophet ﷺ would perform wudu for every prayer most of the time, and sometimes he prayed several prayers with a single wudu. He performed wudu sometimes with one mudd of water, sometimes with two-thirds of it, and sometimes with more."',
  ),
  const ScholarStatement(
    scholar: 'Shaykh Ibn Uthaymeen',
    title: 'may Allah have mercy on him (d. 1421 AH)',
    statement: 'He said: "Wudu is a great act of worship and the key to prayer. A Muslim should be keen to master it and perform it well, and to learn its correct description as it came from the Prophet ﷺ."',
  ),
  const ScholarStatement(
    scholar: 'Shaykh Ibn Baz',
    title: 'may Allah have mercy on him (d. 1420 AH)',
    statement: 'He said: "Among the most important things a Muslim should take care of is perfecting wudu and doing it well. Many people are lax about this, and some of them neglect an obligatory part of it, which invalidates their wudu."',
  ),
];

final List<String> _additionalBenefits = [
  'Wudu is a light for the believer on the Day of Resurrection. The Prophet ﷺ said: "On the Day of Resurrection my Ummah will be called \'those with shining faces and limbs\' from the traces of wudu." — Agreed upon (Bukhari & Muslim)',
  'Wudu expiates sins and wrongdoings, as stated in the authentic hadith',
  'Keeping up wudu is a sign of faith and of good Islam',
  'Wudu is a cause of Allah\'s love. Allah the Almighty said: "إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ" [Al-Baqarah 2:222]',
  'Whoever sleeps in a state of wudu is under Allah\'s protection and care that night',
  'Wudu extinguishes the Lord\'s anger and removes worry and sadness',
  'It is recommended to renew wudu for every prayer even if it has not been broken',
  'Moderation in water is a sunnah, and wastefulness is disliked even at a flowing river',
];
