import 'package:flutter/material.dart';
import '../../domain/entities/flashcard.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final bool isAnswerVisible;
  final VoidCallback onToggleAnswer;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.isAnswerVisible,
    required this.onToggleAnswer,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showingAnswer = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnswerVisible != oldWidget.isAnswerVisible) {
      if (widget.isAnswerVisible) {
        _controller.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showingAnswer = true);
        });
      } else {
        _controller.reverse();
        setState(() => _showingAnswer = false);
      }
    }
    if (widget.flashcard.id != oldWidget.flashcard.id) {
      _controller.reset();
      setState(() => _showingAnswer = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159;
        final isBack = _flipAnimation.value > 0.5;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: widget.onToggleAnswer,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 280),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isBack
                      ? [
                          colorScheme.secondaryContainer,
                          colorScheme.secondaryContainer.withOpacity(0.8),
                        ]
                      : [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withOpacity(0.8),
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isBack
                            ? colorScheme.secondary
                            : colorScheme.primary)
                        .withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Transform(
                transform:
                    isBack ? (Matrix4.identity()..rotateY(3.14159)) : Matrix4.identity(),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isBack
                                  ? colorScheme.secondary
                                  : colorScheme.primary)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isBack ? 'ANSWER' : 'QUESTION',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isBack
                                ? colorScheme.secondary
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isBack
                            ? widget.flashcard.answer
                            : widget.flashcard.question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: isBack
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!isBack) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Tap to reveal answer',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
