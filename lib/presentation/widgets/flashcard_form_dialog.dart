import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/flashcard.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';

class FlashcardFormDialog extends StatefulWidget {
  final Flashcard? flashcard;

  const FlashcardFormDialog({super.key, this.flashcard});

  @override
  State<FlashcardFormDialog> createState() => _FlashcardFormDialogState();
}

class _FlashcardFormDialogState extends State<FlashcardFormDialog> {
  late final TextEditingController _questionCtrl;
  late final TextEditingController _answerCtrl;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.flashcard != null;

  @override
  void initState() {
    super.initState();
    _questionCtrl = TextEditingController(text: widget.flashcard?.question ?? '');
    _answerCtrl = TextEditingController(text: widget.flashcard?.answer ?? '');
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<FlashcardBloc>();

    if (isEditing) {
      bloc.add(UpdateFlashcardEvent(
        widget.flashcard!.copyWith(
          question: _questionCtrl.text.trim(),
          answer: _answerCtrl.text.trim(),
        ),
      ));
    } else {
      bloc.add(AddFlashcardEvent(
        question: _questionCtrl.text.trim(),
        answer: _answerCtrl.text.trim(),
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'Edit Flashcard' : 'New Flashcard',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _questionCtrl,
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      hintText: 'Enter your question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Question is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _answerCtrl,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Answer',
                      hintText: 'Enter the answer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Answer is required' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isEditing ? 'Save' : 'Add'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}