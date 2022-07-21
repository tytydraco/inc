import 'dart:io';

/// Evaluates source code blocks and gets the result.
class Evaluator {
  /// Create a new [Evaluator] using some [input] code.
  Evaluator({
    required this.input,
  });

  /// Input code to evaluate.
  final String input;

  /// Evaluate the code and return the result.
  Future<String> evaluate() async {
    final process = await Process.run(
      'python',
      [
        '-c',
        input,
      ],
    );

    return process.stdout.toString();
  }
}
