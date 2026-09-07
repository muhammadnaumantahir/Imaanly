import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../domain/entities/entities.dart';
import 'quran_bloc.dart';

/// Local-first Quran reader backed by the feature repository.
///
/// The initial page comes from the persisted last-read position. Whenever the
/// user changes pages, the page and its first ayah are persisted so the next
/// session can resume from the same place.
class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(const LoadLastReadPosition()),
      child: const _QuranReaderView(),
    );
  }
}

class _QuranReaderView extends StatefulWidget {
  const _QuranReaderView();

  @override
  State<_QuranReaderView> createState() => _QuranReaderViewState();
}

class _QuranReaderViewState extends State<_QuranReaderView> {
  PageController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          BlocBuilder<QuranBloc, QuranState>(
            buildWhen: (previous, current) =>
                previous.lastReadPage != current.lastReadPage,
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text('Page ${state.lastReadPage}')),
            ),
          ),
        ],
      ),
      body: BlocConsumer<QuranBloc, QuranState>(
        listenWhen: (previous, current) =>
            previous.lastReadPage != current.lastReadPage ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.status == QuranStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (_controller == null) {
            _controller = PageController(
              initialPage: (state.lastReadPage - 1).clamp(0, 603),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.read<QuranBloc>().add(LoadQuranPage(state.lastReadPage));
            });
          }

          return PageView.builder(
            controller: _controller,
            itemCount: 604,
            onPageChanged: (index) {
              context.read<QuranBloc>().add(LoadQuranPage(index + 1));
            },
            itemBuilder: (context, index) {
              if (state.currentPage?.pageNumber == index + 1) {
                return _QuranPageContent(page: state.currentPage!);
              }
              if (index + 1 == state.lastReadPage && state.status == QuranStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Text(
                  'Page ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuranPageContent extends StatelessWidget {
  const _QuranPageContent({required this.page});

  final QuranPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Center(
          child: Text(
            'Juz ${page.juz}  •  Page ${page.pageNumber}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        for (final ayah in page.ayahs) ...[
          Semantics(
            label: 'Ayah ${ayah.key}',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.read<QuranBloc>().add(
                SaveLastReadPosition(
                  page: page.pageNumber,
                  ayahKey: ayah.key,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Text(
                  ayah.text,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 2.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 20),
        ],
      ],
    );
  }
}
