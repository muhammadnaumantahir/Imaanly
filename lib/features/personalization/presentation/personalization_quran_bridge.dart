import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/core/unified_quran_settings/cubit/quran_settings_cubit.dart';
import '../domain/imaanly_personalization.dart';
import 'personalization_cubit.dart';

/// Keeps the unified Quran reader settings synchronized with Imaanly's
/// app-level personalization preferences.
class PersonalizationQuranBridge extends StatelessWidget {
  const PersonalizationQuranBridge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalizationCubit, ImaanlyPersonalization>(
      listenWhen: (previous, current) =>
          previous.quranScript != current.quranScript,
      listener: (context, personalization) {
        final quran = context.read<QuranSettingsCubit>();
        final family = personalization.quranScript == 'indopak'
            ? QuranFontFamily.indopakNastaleeq
            : QuranFontFamily.kfgqpcUthmanicHafs;
        quran.updateFontFamily(family);
      },
      child: child,
    );
  }
}
