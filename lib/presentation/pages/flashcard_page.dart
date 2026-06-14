import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../widgets/flashcard_form_dialog.dart';
import '../widgets/flashcard_widget.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: BlocConsumer<FlashcardBloc, FlashcardState>(
        listener: (context, state) {
          if (state is FlashcardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FlashcardLoading || state is FlashcardInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FlashcardLoaded) {
            if (state.flashcards.isEmpty) return _buildEmptyState(context);
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Card'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.style_rounded, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 10),
          Text(
            'FlashCards',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<FlashcardBloc, FlashcardState>(
          builder: (context, state) {
            if (state is! FlashcardLoaded || state.currentCard == null) {
              return const SizedBox.shrink();
            }
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit card',
                  onPressed: () => _showForm(context, state.currentCard),
                ),
                IconButton(
                  icon: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
                  tooltip: 'Delete card',
                  onPressed: () => _confirmDelete(context, state.currentCard!.id),
                ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FlashcardLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildProgressBar(context, state),
            const SizedBox(height: 12),

            // Flashcard
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: FlashcardWidget(
                  key: ValueKey(state.currentCard!.id),
                  flashcard: state.currentCard!,
                  isAnswerVisible: state.isAnswerVisible,
                  onToggleAnswer: () => context
                      .read<FlashcardBloc>()
                      .add(const ToggleAnswerEvent()),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Show / Hide Answer
            SizedBox(
              width: double.infinity,
              child: state.isAnswerVisible
                  ? OutlinedButton.icon(
                onPressed: () => context
                    .read<FlashcardBloc>()
                    .add(const ToggleAnswerEvent()),
                icon: const Icon(Icons.visibility_off_rounded, size: 18),
                label: const Text('Hide Answer',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              )
                  : FilledButton.tonalIcon(
                onPressed: () => context
                    .read<FlashcardBloc>()
                    .add(const ToggleAnswerEvent()),
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('Show Answer',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Navigation
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.hasPrevious
                        ? () => context
                        .read<FlashcardBloc>()
                        .add(const PreviousCardEvent())
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.hasNext
                        ? () => context
                        .read<FlashcardBloc>()
                        .add(const NextCardEvent())
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, FlashcardLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (state.currentIndex + 1) / state.flashcards.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Card ${state.currentIndex + 1} of ${state.flashcards.length}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.style_outlined,
                  size: 64, color: colorScheme.primary.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Text('No flashcards yet',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Card" to create your first flashcard and start studying.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first card'),
            ),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, [dynamic flashcard]) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<FlashcardBloc>(),
        child: FlashcardFormDialog(flashcard: flashcard),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<FlashcardBloc>().add(DeleteFlashcardEvent(id));
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}