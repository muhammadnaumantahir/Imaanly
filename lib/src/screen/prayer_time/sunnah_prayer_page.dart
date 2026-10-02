import 'package:flutter/material.dart';
import 'package:imaanly/src/theme/app_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../features/sunnah/services/sunnah_share_service.dart';
import '../../../features/sunnah/presentation/screens/image_customization_screen.dart';

// Design System Colors (Wahy + Ayah Hybrid)
const _primaryGreen = Color(0xFF0F7A5C);
const _accentGold = Color(0xFFC9A24B);
const _darkBg = Color(0xFF0E2E25);
const _cardDark = Color(0xFF11332A);
const _cardLight = Color(0xFFFFFFFF);
const _textLight = Color(0xFFF3F8F5);
const _textDark = Color(0xFF17392F);  
const _mutedLight = Color(0xFFB8BCC2);
const _mutedDark = Color(0xFF6B7F77); 

class SunnahPrayerPage extends StatelessWidget {
  const SunnahPrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? _darkBg : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: Text(
          'Sunnahs & Etiquette of Prayer',
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
          _buildIntroCard(isDark),
          const Gap(16),
          _buildImportanceCard(isDark),
          const Gap(16),
          _buildSectionHeader("Pillars and Sunnahs of Prayer", Icons.format_list_numbered_rounded, isDark),
          const Gap(12),
          _buildPrayerStepsSection(context, isDark),
          const Gap(16),
          _buildSectionHeader("Scholars' Statements", Icons.school_rounded, isDark),
          const Gap(12),
          _buildScholarsSection(isDark),
          const Gap(16),
          _buildSectionHeader("Benefits & Etiquette", Icons.lightbulb_rounded, isDark),
          const Gap(12),
          _buildBenefitsSection(isDark),
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
                  Icons.book_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "Prayer: the Pillar of Religion",
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
            "Prayer is the second pillar of Islam and the first thing a servant will be held accountable for on the Day of Resurrection. Allah the Almighty commanded establishing it, and the Prophet ﷺ urged performing it well and perfectly.",
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
                  "Virtue of prayer",
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
            'Abu Hurairah (may Allah be pleased with him) said: I heard the Messenger of Allah ﷺ say: "Do you think that if there were a river at the door of one of you in which he bathed five times every day, any dirt would remain on him?" They said: "No dirt would remain on him." He said: "That is like the five daily prayers; Allah wipes away sins through them."',
            'Agreed upon',
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

  Widget _buildPrayerStepsSection(BuildContext context, bool isDark) {
    return Column(
      children: _prayerSteps.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStepCard(
            context: context,
            number: entry.key + 1,
            step: entry.value,
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required int number,
    required PrayerStep step,
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
              if (step.type != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: step.type == 'Pillar' 
                        ? const Color(0xFFDC2626).withValues(alpha: 0.15)
                        : _accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    step.type!,
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: step.type == 'Pillar' 
                          ? const Color(0xFFDC2626)
                          : _accentGold,
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
                  type: "Sunnahs of prayer",
                ),
                icon: const Icon(Icons.share_rounded),
                iconSize: 20,
                color: const Color(0xFF12906A),
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
                        colors: [const Color(0xFF12906A), const Color(0xFF12906A).withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF12906A).withValues(alpha: 0.3),
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
                color: const Color(0xFF2F9BB5),
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
                          backgroundColor: const Color(0xFF2F9BB5),
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
                color: const Color(0xFFD9573A),
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

  Widget _buildScholarsSection(bool isDark) {
    return Column(
      children: _scholarStatements.map((statement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildScholarCard(statement, isDark),
        );
      }).toList(),
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
                  color: const Color(0xFF6A4FC4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF6A4FC4),
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

  Widget _buildBenefitsSection(bool isDark) {
    return Column(
      children: _additionalBenefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildBenefitCard(benefit, isDark),
        );
      }).toList(),
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
              color: const Color(0xFF12906A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF12906A),
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
}

class PrayerStep {
  final String title;
  final String description;
  final String? evidence;
  final String? type;

  const PrayerStep({
    required this.title,
    required this.description,
    this.evidence,
    this.type,
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


// Prayer Steps Data
final List<PrayerStep> _prayerSteps = [
  const PrayerStep(
    title: 'Standing, if able',
    description: 'Standing in the obligatory prayer is a pillar of the prayer for whoever is able. If he cannot, he prays sitting; if he cannot, then on his side.',
    evidence: 'The Prophet ﷺ said to Imran ibn Husayn: "Pray standing; if you cannot, then sitting; if you cannot, then on your side." — Narrated by Al-Bukhari',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Takbirat al-Ihram (Opening Takbeer)',
    description: 'He says: "Allahu Akbar" (Allah is the Greatest). It is a pillar of the prayer, and the prayer does not begin without it.',
    evidence: 'The Prophet ﷺ said: "The key to prayer is purification, its beginning is the takbeer, and its conclusion is the taslim." — Narrated by Abu Dawud and graded sahih by Al-Albani',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Raising the Hands with the Takbeer',
    description: 'He raises his hands level with his shoulders or the tips of his ears at the opening takbeer, at ruku, when rising from it, and when standing up from the first tashahhud.',
    evidence: 'The Prophet ﷺ used to raise his hands in these places. — Agreed upon (Bukhari & Muslim)',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Placing the Right Hand over the Left',
    description: 'He places his right hand over his left on his chest after the opening takbeer.',
    evidence: 'When the Prophet ﷺ stood in prayer, he would place his right hand over his left. — Narrated by Al-Bukhari',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'The Opening Supplication',
    description: 'After the opening takbeer he says: "سبحانك اللهم وبحمدك، وتبارك اسمك، وتعالى جدك، ولا إله غيرك" (Glory and praise be to You, O Allah; blessed is Your name, exalted is Your majesty, and there is no god but You).',
    evidence: 'The Prophet ﷺ used to open the prayer with this supplication. — Narrated by Muslim',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Seeking Refuge and the Basmalah',
    description: 'He seeks refuge in Allah from the accursed Satan, then says the Basmalah silently, in both loud and silent prayers.',
    evidence: 'Allah the Almighty said: "فَإِذَا قَرَأْتَ الْقُرْآنَ فَاسْتَعِذْ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ" [An-Nahl 16:98]',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Reciting Al-Fatihah',
    description: 'He recites Surah Al-Fatihah in every rak\'ah; it is a pillar of the prayer.',
    evidence: 'The Prophet ﷺ said: "There is no prayer for one who does not recite the Opening of the Book." — Agreed upon (Bukhari & Muslim)',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Saying Ameen',
    description: 'He says "Ameen" after Al-Fatihah, aloud in the loud prayers and silently in the silent prayers.',
    evidence: 'The Prophet ﷺ said: "When the imam says Ameen, say Ameen, for whoever\'s Ameen coincides with the Ameen of the angels will be forgiven his previous sins." — Agreed upon (Bukhari & Muslim)',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Reciting a Surah After Al-Fatihah',
    description: 'He recites a surah or verses from the Quran after Al-Fatihah in the first two rak\'ahs of every prayer.',
    evidence: 'The Prophet ﷺ used to recite Al-Fatihah and a surah in the first two rak\'ahs. — Agreed upon (Bukhari & Muslim)',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Ruku (Bowing)',
    description: 'He bows saying the takbeer, keeps his head level with his back, and places his hands on his knees with fingers spread.',
    evidence: 'When the Prophet ﷺ bowed, he neither raised his head nor lowered it, but kept it in between. — Narrated by Muslim',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Glorification in Ruku',
    description: 'He says in his ruku: "سبحان ربي العظيم" (Glory be to my Lord, the Magnificent) three times or more.',
    evidence: 'The Prophet ﷺ said: "As for ruku, glorify the Lord in it." — Narrated by Muslim',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Rising from Ruku',
    description: 'He rises from ruku saying: "سمع الله لمن حمده" (Allah hears whoever praises Him), then after standing upright says: "ربنا ولك الحمد" (Our Lord, and to You belongs all praise).',
    evidence: 'When the Prophet ﷺ raised his head from ruku he would say: "سمع الله لمن حمده، ربنا ولك الحمد" (Allah hears whoever praises Him; our Lord, to You belongs all praise). — Agreed upon (Bukhari & Muslim)',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Sujud (Prostration)',
    description: 'He prostrates on seven bones: the forehead together with the nose, the two palms, the two knees, and the tips of the feet.',
    evidence: 'The Prophet ﷺ said: "I was commanded to prostrate on seven bones." — Agreed upon (Bukhari & Muslim)',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Glorification in Sujud',
    description: 'He says in his sujud: "سبحان ربي الأعلى" (Glory be to my Lord, the Most High) three times or more.',
    evidence: 'The Prophet ﷺ said: "As for sujud, strive in supplication, for it is most fitting that you will be answered." — Narrated by Muslim',
    type: 'Sunnah',
  ),
  const PrayerStep(
    title: 'Sitting Between the Two Prostrations',
    description: 'He sits between the two prostrations with his left foot laid flat and his right foot upright, saying: "رب اغفر لي" (My Lord, forgive me).',
    evidence: 'The Prophet ﷺ used to say between the two prostrations: "رب اغفر لي، رب اغفر لي" (My Lord, forgive me; my Lord, forgive me). — Narrated by Abu Dawud and graded sahih by Al-Albani',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'The First Tashahhud',
    description: 'He sits for the first tashahhud after the second rak\'ah and recites At-Tahiyyat.',
    evidence: 'When the Prophet ﷺ sat after two rak\'ahs he would say: "التحيات لله والصلوات والطيبات..." (All greetings, prayers and good words are for Allah…). — Agreed upon (Bukhari & Muslim)',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'The Final Tashahhud',
    description: 'He sits for the final tashahhud and recites At-Tahiyyat and the Ibrahimi prayer (salawat upon the Prophet ﷺ).',
    evidence: 'The Prophet ﷺ said: "When one of you finishes the tashahhud, let him seek refuge in Allah from four things…" — Narrated by Muslim',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'The Taslim',
    description: 'He gives salam to his right and left, saying: "السلام عليكم ورحمة الله" (Peace and the mercy of Allah be upon you).',
    evidence: 'The Prophet ﷺ used to give salam to his right and to his left. — Narrated by Muslim',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Tranquility in All the Pillars',
    description: 'Tranquility (tuma\'ninah) is obligatory in all the pillars of prayer; it means stillness and not rushing.',
    evidence: 'The Prophet ﷺ said to the man who prayed incorrectly: "Go back and pray, for you have not prayed." — Agreed upon (Bukhari & Muslim)',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Khushu\' in Prayer',
    description: 'Khushu\' is presence of the heart and humility before Allah the Almighty; it is the soul and essence of prayer.',
    evidence: 'Allah the Almighty said: "قَدْ أَفْلَحَ الْمُؤْمِنُونَ * الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ" [Al-Mu\'minun 23:1-2]',
    type: 'Sunnah',
  ),
];

final List<ScholarStatement> _scholarStatements = [
  const ScholarStatement(
    scholar: 'Imam Ibn Al-Qayyim',
    title: 'may Allah have mercy on him (d. 751 AH)',
    statement: 'He said in his book on prayer: "Prayer is the delight of the eyes of those who love Allah, the joy of the souls of the monotheists, the pleasure of the souls of those who know Him, the garden of the worshippers, the pleasure of the humble souls, and the touchstone of the states of the truthful."',
  ),
  const ScholarStatement(
    scholar: 'Imam An-Nawawi',
    title: 'may Allah have mercy on him (d. 676 AH)',
    statement: 'He said in Al-Majmu\': "The one praying should bring his heart to all the words and actions of the prayer and reflect on what he says and does, for that is the soul and essence of prayer."',
  ),
  const ScholarStatement(
    scholar: 'Shaykh Ibn Uthaymeen',
    title: 'may Allah have mercy on him (d. 1421 AH)',
    statement: 'He said: "Prayer is the pillar of Islam and the link between the servant and his Lord. A Muslim should take the utmost care of it and perform it in the way Allah the Almighty prescribed."',
  ),
  const ScholarStatement(
    scholar: 'Shaykh Ibn Baz',
    title: 'may Allah have mercy on him (d. 1420 AH)',
    statement: 'He said: "Prayer is the greatest pillar of Islam after the two testimonies of faith, and it is the pillar of the religion. Whoever establishes it has established the religion, and whoever destroys it has destroyed the religion."',
  ),
  const ScholarStatement(
    scholar: 'Imam Ahmad ibn Hanbal',
    title: 'may Allah have mercy on him (d. 241 AH)',
    statement: 'He said: "Prayer is the best of deeds after the two testimonies, and it is the first thing a servant will be held accountable for on the Day of Resurrection. If it is sound, the rest of his deeds are sound; if it is corrupt, the rest of his deeds are corrupt."',
  ),
];

final List<String> _additionalBenefits = [
  'Prayer is a light for the believer in this world and the next. The Prophet ﷺ said: "Prayer is light." — Narrated by Muslim',
  'Prayer forbids immorality and wrongdoing. Allah the Almighty said: "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ" [Al-Ankabut 29:45]',
  'Prayer expiates sins and wrongdoings. The Prophet ﷺ said: "The five daily prayers, and Friday to Friday, are expiation for what is between them, as long as major sins are avoided." — Narrated by Muslim',
  'Prayer is a cause of entering Paradise. The Prophet ﷺ said: "Whoever prays the two cool prayers (Fajr and Asr) will enter Paradise." — Agreed upon (Bukhari & Muslim)',
  'Prayer in congregation is better than praying alone by twenty-seven degrees. — Agreed upon (Bukhari & Muslim)',
  'Keeping up the five daily prayers is a sign of faith and of good Islam',
  'Prayer is rest for the heart and tranquility for the soul. The Prophet ﷺ said: "Give us rest through it, O Bilal." — Narrated by Abu Dawud',
  'Sujud is when a servant is closest to his Lord. The Prophet ﷺ said: "The closest a servant is to his Lord is when he is prostrating." — Narrated by Muslim',
  'Supplication in sujud is likely to be answered, so one should make much supplication in it',
  'Night prayer is the honor of the believer. The Prophet ﷺ said: "Hold fast to the night prayer, for it was the practice of the righteous before you." — Narrated by At-Tirmidhi',
];
