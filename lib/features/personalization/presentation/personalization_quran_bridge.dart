import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/core/unified_quran_settings/cubit/quran_settings_cubit.dart';
import '../domain/imaanly_personalization.dart';
import 'personalization_cubit.dart';

/// Keeps the unified Quran reader settings synchronized with app-level
/// personalization. The initial value is applied as well as later changes.
class PersonalizationQuranBridge extends StatefulWidget {
  const PersonalizationQuranBridge({super.key, required this.child});

  final Widget child;

  @override
  State<PersonalizationQuranBridge> createState() =>
      _PersonalizationQuranBridgeState();
}

class _PersonalizationQuranBridgeState extends State<PersonalizationQuranBridge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync(context.read<PersonalizationCubit>().state);
    });
  }

  void _sync(ImaanlyPersonalization personalization) {
    final quran = context.read<QuranSettingsCubit>();
    final family = personalization.quranScript == 'indopak'
        ? QuranFontFamily.indopakNastaleeq
        : QuranFontFamily.kfgqpcUthmanicHafs;
    if (quran.state.fontFamily != family) {
      quran.updateFontFamily(family);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalizationCubit, ImaanlyPersonalization>(
      listenWhen: (previous, current) =>
          previous.quranScript != current.quranScript,
      listener: (context, personalization) => _sync(personalization),
      child: widget.child,
    );
  }
}
