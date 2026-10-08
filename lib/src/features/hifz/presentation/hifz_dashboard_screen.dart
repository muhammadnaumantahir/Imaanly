import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/hifz.dart';
import '../domain/repositories/hifz_repository.dart' show HifzStats;
import 'hifz_bloc.dart';
import 'hifz_new_memorization_screen.dart';
import 'hifz_review_screen.dart';

/// Hifz Dashboard Screen — memorization progress overview.
class HifzDashboardScreen extends StatelessWidget {
  const HifzDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<HifzBloc>()
        ..add(const LoadAllProgress())
        ..add(const LoadStats())
        ..add(const LoadDueForReview()),
      child: const _HifzDashboardView(),
    );
  }
}

class _HifzDashboardView extends StatelessWidget {
  const _HifzDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Directionality.of(context) == TextDirection.rtl ? 'Memorization' : 'Hifz'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'New memorization',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HifzNewMemorizationScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: BlocBuilder<HifzBloc, HifzState>(
        builder: (context, state) {
          switch (state.status) {
            case HifzStatus.initial:
            case HifzStatus.loading:
              return const SkeletonList(itemCount: 6);
            case HifzStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load hifz data',
                onRetry: () => _reload(context),
              );
            case HifzStatus.loaded:
              return RefreshIndicator(
                onRefresh: () async => _reload(context),
                child: _HifzContent(state: state),
              );
          }
        },
      ),
    );
  }

  void _reload(BuildContext context) {
    context.read<HifzBloc>()
      ..add(const LoadAllProgress())
      ..add(const LoadStats())
      ..add(const LoadDueForReview());
  }
}

class _HifzContent extends StatelessWidget {
  final HifzState state;
  const _HifzContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (state.allProgress.isEmpty && state.stats == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSizes.paddingM.w),
        children: [
          const EmptyStateWidget(
            title: 'No memorization progress',
            subtitle: 'Start memorizing to track your progress here',
            icon: Icons.school_outlined,
          ),
          SizedBox(height: AppSizes.paddingM.h),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HifzNewMemorizationScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Start memorizing'),
          ),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppSizes.paddingM.w),
      children: [
        if (state.stats != null) ...[
          _StatsGrid(stats: state.stats!),
          SizedBox(height: AppSizes.paddingM.h),
        ],
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HifzNewMemorizationScreen()),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(isRtl ? 'Start new memorization' : 'Start new memorization'),
        ),
        SizedBox(height: AppSizes.paddingM.h),
        if (state.dueForReview.isNotEmpty) ...[
          SectionHeader(
            title: isRtl ? 'Today\'s review' : 'Due for Review',
            subtitle: '${state.dueForReview.length} ${isRtl ? 'surahs' : 'surahs'}',
          ),
          ...state.dueForReview.map((progress) => _ProgressCard(
                progress: progress,
                onReview: () => _openReview(context, progress),
              )),
          SizedBox(height: AppSizes.paddingM.h),
        ],
        SectionHeader(
          title: isRtl ? 'All progress' : 'All Progress',
          subtitle: '${state.allProgress.length} ${isRtl ? 'surahs' : 'surahs'}',
        ),
        if (state.allProgress.isEmpty)
          const EmptyStateWidget(title: 'No progress yet', icon: Icons.menu_book_outlined)
        else
          ...state.allProgress.map((progress) => _ProgressCard(
                progress: progress,
                onReview: () => _openReview(context, progress),
              )),
      ],
    );
  }

  void _openReview(BuildContext context, HifzProgress progress) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HifzReviewScreen(progress: progress)),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final HifzStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.paddingS.h,
      crossAxisSpacing: AppSizes.paddingS.w,
      childAspectRatio: 1.6,
      children: [
        _StatCard(label: 'Surahs', value: '${stats.totalSurahsMemorized}', icon: Icons.menu_book_outlined, color: accentColor),
        _StatCard(label: 'Ayat', value: '${stats.totalAyahsMemorized}', icon: Icons.format_list_numbered_outlined, color: isDark ? AppColors.successDark : AppColors.success),
        _StatCard(label: 'Mastery', value: '${stats.overallMasteryPercentage.toStringAsFixed(0)}%', icon: Icons.trending_up_outlined, color: isDark ? AppColors.warningDark : AppColors.warning),
        _StatCard(label: 'Sessions', value: '${stats.totalSessions}', icon: Icons.timer_outlined, color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [Icon(icon, size: AppSizes.iconM.w, color: color), const Spacer(), Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain))]),
          SizedBox(height: AppSizes.paddingXS.h),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final HifzProgress progress;
  final VoidCallback onReview;
  const _ProgressCard({required this.progress, required this.onReview});

  String _masteryLabel() => switch (progress.mastery) {
        HifzMasteryLevel.notStarted => 'Not Started',
        HifzMasteryLevel.learning => 'Learning',
        HifzMasteryLevel.familiar => 'Familiar',
        HifzMasteryLevel.confident => 'Confident',
        HifzMasteryLevel.mastered => 'Mastered',
      };

  Color _masteryColor(bool isDark) => switch (progress.mastery) {
        HifzMasteryLevel.notStarted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        HifzMasteryLevel.learning => isDark ? AppColors.errorDark : AppColors.error,
        HifzMasteryLevel.familiar => isDark ? AppColors.warningDark : AppColors.warning,
        HifzMasteryLevel.confident => isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        HifzMasteryLevel.mastered => isDark ? AppColors.successDark : AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final masteryColor = _masteryColor(isDark);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('Surah ${progress.surahId}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain))),
            AppChip(label: _masteryLabel(), backgroundColor: masteryColor.withValues(alpha: 0.15), textColor: masteryColor),
          ]),
          SizedBox(height: AppSizes.paddingS.h),
          Row(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(AppSizes.radiusXS.r), child: LinearProgressIndicator(value: progress.progressPercentage / 100, backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface, valueColor: AlwaysStoppedAnimation(masteryColor), minHeight: 4.h))),
            SizedBox(width: AppSizes.paddingS.w),
            Text('${progress.progressPercentage.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          ]),
          SizedBox(height: AppSizes.paddingXS.h),
          Text('Ayat ${progress.ayahStart}-${progress.ayahEnd} | Reviews: ${progress.reviewCount} | Accuracy: ${progress.masteryPercentage.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          SizedBox(height: AppSizes.paddingS.h),
          Align(alignment: AlignmentDirectional.centerEnd, child: FilledButton.tonalIcon(onPressed: onReview, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Review'))),
        ],
      ),
    );
  }
}
