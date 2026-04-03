import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/topic_progress.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/topic_strength_badge.dart';
import '../providers/topics_provider.dart';

class TopicListScreen extends ConsumerStatefulWidget {
  const TopicListScreen({super.key});

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final topicsWithProgress = ref.watch(topicsWithProgressProvider);

    final filtered = _searchQuery.isEmpty
        ? topicsWithProgress
        : topicsWithProgress
            .where((t) =>
                t.topic.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Topics', style: AppTypography.headlineMedium),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.md,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search topics…',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textMuted),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          // Topic list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            color: AppColors.textMuted, size: 56),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No topics available'
                              : 'No results for "$_searchQuery"',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.xxxl,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _TopicCard(
                        item: item,
                        onTap: () =>
                            context.push(RouteNames.examPath(item.topic.id)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicWithProgress item;
  final VoidCallback onTap;

  const _TopicCard({required this.item, required this.onTap});

  Color get _strengthColor {
    switch (item.strength) {
      case TopicStrength.strong:
        return AppColors.strengthStrong;
      case TopicStrength.average:
        return AppColors.strengthAverage;
      case TopicStrength.weak:
        return AppColors.strengthWeak;
      case TopicStrength.untested:
        return AppColors.strengthUntested;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = item.progress;
    final accuracy = item.accuracy;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading letter avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _strengthColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _strengthColor.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    item.topic.name.substring(0, 1).toUpperCase(),
                    style: AppTypography.titleLarge
                        .copyWith(color: _strengthColor),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Topic name + stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.topic.name,
                        style: AppTypography.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${progress?.totalAttempted ?? 0} answered · '
                      '${item.topic.totalQuestions} total',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              // Strength badge
              TopicStrengthBadge(strength: item.strength),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Accuracy progress bar
          LinearPercentIndicator(
            percent: accuracy.clamp(0.0, 1.0),
            lineHeight: 6,
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.border,
            progressColor: _strengthColor,
            barRadius: const Radius.circular(3),
            trailing: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                '${(accuracy * 100).round()}%',
                style: AppTypography.labelSmall
                    .copyWith(color: _strengthColor),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Practice button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                textStyle: AppTypography.labelLarge
                    .copyWith(color: Colors.black, fontSize: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
