import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 300))
          .scale(duration: const Duration(milliseconds: 300)),
    );
  }
}
