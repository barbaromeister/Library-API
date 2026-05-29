import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/async_value_widget.dart';
import '../providers/book_providers.dart';

class BookDetailScreen extends ConsumerWidget {
  final int id;
  const BookDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/books'),
        ),
      ),
      body: AsyncValueWidget(
        value: book,
        data: (b) {
          final cover = b.covers?.best;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cover != null && cover.isNotEmpty)
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: cover.replaceFirst('http://', 'https://'),
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.menu_book, size: 96),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(b.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(b.author, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (b.publishDate != null)
                          _chip(context, Icons.calendar_today,
                              DateFormat.y().format(b.publishDate!)),
                        if (b.pageCount != null)
                          _chip(context, Icons.menu_book, '${b.pageCount} pages'),
                        if (b.publisher != null)
                          _chip(context, Icons.business, b.publisher!),
                        if (b.isbn != null) _chip(context, Icons.qr_code, b.isbn!),
                        if (b.language != null)
                          _chip(context, Icons.language, b.language!),
                      ],
                    ),
                    if (b.description != null) ...[
                      const SizedBox(height: 24),
                      Text('Description', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(b.description!),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(text),
      );
}
