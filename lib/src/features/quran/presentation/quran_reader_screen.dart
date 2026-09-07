import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../domain/entities/entities.dart';
import 'quran_bloc.dart';
import 'quran_reading_progress_screen.dart';

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
          IconButton(
            tooltip: 'Reading progress',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranReadingProgressScreen())),
            icon: const Icon(Icons.insights_outlined),
          ),
          BlocBuilder<QuranBloc, QuranState>(
            buildWhen: (a, b) => a.lastReadPage != b.lastReadPage,
            builder: (context, state) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Center(child: Text('Page ${state.lastReadPage}'))),
          ),
        ],
      ),
      body: BlocConsumer<QuranBloc, QuranState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == QuranStatus.error) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) {
          final initialPage = (state.lastReadPage - 1).clamp(0, 603).toInt();
          _controller ??= PageController(initialPage: initialPage);
          return PageView.builder(
            controller: _controller,
            itemCount: 604,
            onPageChanged: (index) => context.read<QuranBloc>().add(LoadQuranPage(index + 1)),
            itemBuilder: (context, index) {
              if (state.currentPage?.pageNumber == index + 1) return _QuranPageContent(page: state.currentPage!);
              if (index + 1 == state.lastReadPage && state.status == QuranStatus.loading) return const Center(child: CircularProgressIndicator());
              return Center(child: Text('Page ${index + 1}'));
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Center(child: Text('Juz ${page.juz}  •  Page ${page.pageNumber}')),
        const SizedBox(height: 20),
        for (final ayah in page.ayahs) ...[
          InkWell(
            onTap: () => context.read<QuranBloc>().add(SaveLastReadPosition(page: page.pageNumber, ayahKey: ayah.key)),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), child: Text(ayah.text, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 2))),
          ),
          const Divider(height: 20),
        ],
      ],
    );
  }
}
