import "package:imaanly/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:imaanly/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:imaanly/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:imaanly/src/utils/quran_resources/word_info_models.dart";
import "package:imaanly/src/utils/quran_resources/word_info_repository.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class WordInfoResourcesView extends StatefulWidget {
  const WordInfoResourcesView({super.key});

  @override
  State<WordInfoResourcesView> createState() => _WordInfoResourcesViewState();
}

class _WordInfoResourcesViewState extends State<WordInfoResourcesView> {
  final WordInfoRepository _wordInfoRepo = WordInfoRepository();
  final Map<WordInfoKind, int?> _sizes = {};
  List<String> _downloadedOrderIds = const [];

  @override
  void initState() {
    super.initState();
    _loadSizes();
    _loadOrder();
  }

  void _loadOrder() {
    _downloadedOrderIds = _wordInfoRepo.getDownloadedOrderIds();
  }

  Future<void> _saveDownloadedOrder(List<ManagedResourceItem> ordered) async {
    await _wordInfoRepo.setDownloadedOrderIds(
      ordered.map((e) => e.id).toList(),
    );
    if (!mounted) return;
    setState(() {
      _downloadedOrderIds = _wordInfoRepo.getDownloadedOrderIds();
    });
  }

  Future<void> _loadSizes() async {
    for (final kind in WordInfoKind.values) {
      _sizes[kind] = await _wordInfoRepo.getRemoteZipSizeBytes(kind);
    }
    if (mounted) setState(() {});
  }

  String _label(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.eerab:
        return "I'rab";
      case WordInfoKind.tasreef:
        return "Morphology";
      case WordInfoKind.recitations:
        return "Qira'at";
    }
  }

  bool _isBusy(ResourcesProgressCubitState state, WordInfoKind kind) {
    if (state.onProcess != true) return false;
    return state.progressMap.containsKey(kind.name);
  }

  Future<void> _downloadKind(WordInfoKind kind) async {
    final cubit = context.read<ResourcesProgressCubit>();
    final totalBytes = _sizes[kind];
    cubit.onProcess();
    cubit.updateProgress(
      0.0,
      _label(kind),
      activeResourceId: kind.name,
      transferredBytes: 0,
      totalBytes: totalBytes,
    );
    try {
      await _wordInfoRepo.downloadKind(
        kind: kind,
        onProgress: (progress) {
          final percentage = progress / 100;
          final transferred = totalBytes == null
              ? null
              : (totalBytes * percentage).round();
          cubit.updateProgress(
            percentage,
            _label(kind),
            activeResourceId: kind.name,
            transferredBytes: transferred,
            totalBytes: totalBytes,
          );
        },
      );
      cubit.updateProgress(
        1.0,
        _label(kind),
        activeResourceId: kind.name,
        transferredBytes: totalBytes ?? 1,
        totalBytes: totalBytes ?? 1,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      cubit.success(activeResourceId: kind.name);
      if (mounted) setState(() {});
    } catch (_) {
      cubit.failure("Couldn't load ${_label(kind)}", activeResourceId: kind.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Couldn't load ${_label(kind)} right now. Please try again."),
        ),
      );
    }
  }

  Future<void> _deleteKind(WordInfoKind kind) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete resource", textAlign: TextAlign.right),
        content: Text(
          "${_label(kind)} will be deleted from the device.",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _wordInfoRepo.deleteKind(kind);
    if (mounted) setState(() {});
  }

  List<ManagedResourceItem> _buildItems(ResourcesProgressCubitState state) {
    final orderMap = <String, int>{
      for (int i = 0; i < _downloadedOrderIds.length; i++)
        _downloadedOrderIds[i]: i,
    };
    return WordInfoKind.values.map((kind) {
      final downloaded = _wordInfoRepo.isKindDownloaded(kind);
      final busy = _isBusy(state, kind);
      return ManagedResourceItem(
        id: kind.name,
        title: _label(kind),
        group: "Language resources",
        subtitle: null,
        badges: const [],
        isDownloaded: downloaded,
        isBusy: busy,
        progress: busy ? (state.progressMap[kind.name] ?? 0.0) : 0,
        orderIndex: downloaded ? orderMap[kind.name] : null,
        sizeBytes: downloaded ? null : _sizes[kind],
        onLoadSize: downloaded ? () => _wordInfoRepo.getLocalKindSizeBytes(kind) : null,
        transferredBytes: busy ? state.transferredBytesMap[kind.name] : null,
        totalBytes: busy ? state.totalBytesMap[kind.name] : null,
        onDownload: downloaded ? null : () => _downloadKind(kind),
        onDelete: downloaded ? () => _deleteKind(kind) : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        return ManagedResourcesCatalog(
          title: "Word info",
          description:
              "Linguistic sources that add i'rab, morphology, and qira'at for the selected word.",
          emptyMessage: "No results.",
          activationBehavior: ResourceActivationBehavior.none,
          items: _buildItems(state),
          onRefresh: () async => setState(() {}),
          onReorderDownloaded: _saveDownloadedOrder,
        );
      },
    );
  }
}
