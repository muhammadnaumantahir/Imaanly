import 'package:flutter/material.dart';

import 'imaanly_tokens.dart';

/// Reusable Material 3 components for the Imaanly surface language.
///
/// These primitives intentionally wrap standard Flutter widgets so existing
/// feature code can migrate incrementally without adopting a new framework.
class ImaanlyCard extends StatelessWidget {
  const ImaanlyCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(ImaanlySpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}

class ImaanlySection extends StatelessWidget {
  const ImaanlySection({
    required this.title,
    required this.child,
    super.key,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: ImaanlyTypography.title),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: ImaanlySpacing.sm),
        child,
      ],
    );
  }
}

class ImaanlyProgress extends StatelessWidget {
  const ImaanlyProgress({
    required this.value,
    super.key,
    this.label,
  });

  final double value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: ImaanlyTypography.caption),
          const SizedBox(height: ImaanlySpacing.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(ImaanlyRadius.pill),
          child: LinearProgressIndicator(
            value: safeValue,
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

class ImaanlyEmptyState extends StatelessWidget {
  const ImaanlyEmptyState({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.auto_awesome_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ImaanlySpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: ImaanlySpacing.md),
            Text(
              title,
              style: ImaanlyTypography.title,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: ImaanlySpacing.xs),
              Text(
                message!,
                style: ImaanlyTypography.body,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: ImaanlySpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
