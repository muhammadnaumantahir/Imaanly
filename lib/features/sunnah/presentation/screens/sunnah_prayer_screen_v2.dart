import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imaanly/src/theme/app_fonts.dart';
import 'package:imaanly/src/screen/mushaf/widgets/wahy_side_drawer.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../services/sunnah_share_service.dart';
import '../widgets/sunnah_intro_card.dart';
import '../widgets/sunnah_importance_card.dart';
import '../widgets/sunnah_section_header.dart';
import '../widgets/sunnah_step_card.dart';
import '../widgets/sunnah_scholar_card.dart';
import '../widgets/sunnah_benefit_card.dart';
import '../widgets/sunnah_share_bottom_sheet.dart';

/// 🕌 شاشة سنن الصلاة - النسخة المحسّنة V2
/// 
/// المميزات:
/// ✅ تطبيق ديزاين Wahy+Ayah
/// ✅ Animations محسّنة وسلسة
/// ✅ Dark mode كامل
/// ✅ Accessibility features
/// ✅ Responsive design للتابلت
/// ✅ ميزة المشاركة الفعلية (نص + صورة)
/// ✅ Staggered animations للعناصر
/// ✅ Semantic labels للـ screen readers
/// ✅ Touch targets أكبر (44dp)
class SunnahPrayerScreenV2 extends StatefulWidget {
  const SunnahPrayerScreenV2({super.key});

  @override
  State<SunnahPrayerScreenV2> createState() => _SunnahPrayerScreenV2State();
}

class _SunnahPrayerScreenV2State extends State<SunnahPrayerScreenV2>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _scrollController;
  late AnimationController _fabController;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: SunnahTheme.durationNormal),
    );
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFab) {
      setState(() => _showFab = true);
      _fabController.forward();
    } else if (_scrollController.offset <= 200 && _showFab) {
      setState(() => _showFab = false);
      _fabController.reverse();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: SunnahTheme.durationSlow),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: SunnahTheme.getBgColor(isDark),
      drawer: WahySideDrawer(
        primary: cs.primary,
        onOpenIndex: () {},
        onOpenBookmarks: () {},
        onOpenStarred: () {},
        onOpenNotes: () {},
        onJumpToAyah: (_) {},
      ),
      appBar: _buildAppBar(isDark, cs),
      body: _buildBody(isDark, isTablet),
      floatingActionButton: _buildFab(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, ColorScheme cs) {
    return AppBar(
      title: Text(
        'Sunnahs & Etiquette of Prayer',
        style: AppFonts.body(
          fontWeight: FontWeight.w900,
          fontSize: 20.sp,
        ),
        semanticsLabel: 'Sunnahs & Etiquette of Prayer',
      ),
      centerTitle: true,
      backgroundColor: SunnahTheme.getSurfaceColor(isDark),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'Main menu',
        iconSize: SunnahTheme.iconLarge,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () => _shareScreen(),
          tooltip: 'Share',
          iconSize: SunnahTheme.iconLarge,
        ),
        SizedBox(width: SunnahTheme.space8),
      ],
    );
  }

  Widget _buildBody(bool isDark, bool isTablet) {
    final maxWidth = isTablet ? 800.0 : double.infinity;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(
            isTablet ? SunnahTheme.space32 : SunnahTheme.space16,
          ),
          children: [
            // Intro Card
            SunnahIntroCard(
              icon: Icons.book_rounded,
              title: "Prayer: the Pillar of Religion",
              description: "Prayer is the second pillar of Islam and the first thing a servant will be held accountable for on the Day of Resurrection. Allah the Almighty commanded establishing it, and the Prophet ﷺ urged performing it well and perfectly.",
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                )
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            
            SizedBox(height: SunnahTheme.space16),
            
            // Importance Card
            SunnahImportanceCard(
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                  delay: Duration(milliseconds: SunnahTheme.durationStagger),
                )
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Section: أركان الصلاة وسننها
            SunnahSectionHeader(
              title: "Pillars and Sunnahs of Prayer",
              icon: Icons.format_list_numbered_rounded,
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                  delay: Duration(milliseconds: SunnahTheme.durationStagger * 2),
                )
                .slideX(begin: 0.05, end: 0),
            
            SizedBox(height: SunnahTheme.space12),
            
            // Prayer Steps
            ..._buildPrayerSteps(isDark),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Section: أقوال العلماء
            SunnahSectionHeader(
              title: "Scholars' Statements",
              icon: Icons.school_rounded,
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                )
                .slideX(begin: 0.05, end: 0),
            
            SizedBox(height: SunnahTheme.space12),
            
            // Scholars
            ..._buildScholars(isDark),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Section: فوائد وآداب
            SunnahSectionHeader(
              title: "Benefits & Etiquette",
              icon: Icons.lightbulb_rounded,
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                )
                .slideX(begin: 0.05, end: 0),
            
            SizedBox(height: SunnahTheme.space12),
            
            // Benefits
            ..._buildBenefits(isDark),
            
            SizedBox(height: SunnahTheme.space40 * 2),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrayerSteps(bool isDark) {
    return _prayerSteps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: SunnahTheme.space12),
        child: SunnahStepCard(
          number: index + 1,
          title: step.title,
          description: step.description,
          evidence: step.evidence,
          badgeText: step.type,
          badgeColor: step.type == 'Pillar' 
              ? SunnahTheme.badgeRukn 
              : SunnahTheme.badgeSunnah,
          isDark: isDark,
          onShare: () => _shareStep(step),
        ),
      )
          .animate()
          .fadeIn(
            duration: Duration(milliseconds: SunnahTheme.durationNormal),
            delay: Duration(
              milliseconds: SunnahTheme.durationStagger * (index + 3),
            ),
          )
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
    }).toList();
  }

  List<Widget> _buildScholars(bool isDark) {
    return _scholarStatements.asMap().entries.map((entry) {
      final index = entry.key;
      final scholar = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: SunnahTheme.space12),
        child: SunnahScholarCard(
          scholarName: scholar.scholar,
          scholarTitle: scholar.title,
          statement: scholar.statement,
          isDark: isDark,
        ),
      )
          .animate()
          .fadeIn(
            duration: Duration(milliseconds: SunnahTheme.durationNormal),
            delay: Duration(milliseconds: SunnahTheme.durationStagger * index),
          )
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
    }).toList();
  }

  List<Widget> _buildBenefits(bool isDark) {
    return _additionalBenefits.asMap().entries.map((entry) {
      final index = entry.key;
      final benefit = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: SunnahTheme.space12),
        child: SunnahBenefitCard(
          benefit: benefit,
          isDark: isDark,
        ),
      )
          .animate()
          .fadeIn(
            duration: Duration(milliseconds: SunnahTheme.durationNormal),
            delay: Duration(milliseconds: SunnahTheme.durationStagger * index),
          )
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
    }).toList();
  }

  Widget _buildFab(bool isDark) {
    return ScaleTransition(
      scale: _fabController,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: SunnahTheme.green,
        tooltip: 'Back to top',
        child: const Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  void _shareStep(PrayerStep step) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SunnahShareBottomSheet(
        title: step.title,
        description: step.description,
        evidence: step.evidence,
        type: "Sunnahs of prayer",
        badgeText: step.type,
        badgeColor: step.type == 'Pillar' 
            ? SunnahTheme.badgeRukn 
            : SunnahTheme.badgeSunnah,
      ),
    );
  }

  void _shareScreen() {
    SunnahShareService.shareAsText(
      title: "Sunnahs & Etiquette of Prayer",
      description: "A complete guide to the pillars, sunnahs and etiquette of prayer",
      type: "Sunnahs of prayer",
    );
  }
}

// ═══════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════

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

// ═══════════════════════════════════════════
// DATA
// ═══════════════════════════════════════════

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
    title: 'Reciting Al-Fatihah',
    description: 'He recites Surah Al-Fatihah in every rak\'ah; it is a pillar of the prayer.',
    evidence: 'The Prophet ﷺ said: "There is no prayer for one who does not recite the Opening of the Book." — Agreed upon (Bukhari & Muslim)',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Ruku (Bowing)',
    description: 'He bows saying the takbeer, keeps his head level with his back, and places his hands on his knees with fingers spread.',
    evidence: 'When the Prophet ﷺ bowed, he neither raised his head nor lowered it, but kept it in between. — Narrated by Muslim',
    type: 'Pillar',
  ),
  const PrayerStep(
    title: 'Sujud (Prostration)',
    description: 'He prostrates on seven bones: the forehead together with the nose, the two palms, the two knees, and the tips of the feet.',
    evidence: 'The Prophet ﷺ said: "I was commanded to prostrate on seven bones." — Agreed upon (Bukhari & Muslim)',
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
];

final List<String> _additionalBenefits = [
  'Prayer is a light for the believer in this world and the next. The Prophet ﷺ said: "Prayer is light." — Narrated by Muslim',
  'Prayer forbids immorality and wrongdoing. Allah the Almighty said: "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ" [Al-Ankabut 29:45]',
  'Prayer expiates sins and wrongdoings. The Prophet ﷺ said: "The five daily prayers, and Friday to Friday, are expiation for what is between them, as long as major sins are avoided." — Narrated by Muslim',
  'Prayer is a cause of entering Paradise. The Prophet ﷺ said: "Whoever prays the two cool prayers (Fajr and Asr) will enter Paradise." — Agreed upon (Bukhari & Muslim)',
  'Prayer in congregation is better than praying alone by twenty-seven degrees. — Agreed upon (Bukhari & Muslim)',
];
