import 'dart:io';

import 'package:io/io.dart';

/// An inline code compiler.
class Inc {
  /// Create a new [Inc] compiler using some [input].
  Inc(
    this.input, {
    this.beginPattern = '|>',
    this.endPattern = '<|',
    this.ignoreErrors = false,
  });

  /// Input text to provide.
  final String input;

  /// Pattern that begins to surround the inline code.
  final String beginPattern;

  /// Pattern that finishes surrounding the inline code.
  final String endPattern;

  /// Continue execution, even if errors occur.
  final bool ignoreErrors;

  late final _beginPatternEsc = RegExp.escape(beginPattern);
  late final _endPatternEsc = RegExp.escape(endPattern);

  /// Evaluate the [input] code and return the result.
  Future<String> _evaluate(String input) async {
    final shellParts = shellSplit(input);
    final executable = shellParts[0];
    final arguments = shellParts.sublist(1);
    final process = await Process.run(executable, arguments);

    if (!ignoreErrors) {
      // Non-empty stderr output.
      if (process.stderr.toString().isNotEmpty) {
        stderr.writeln(process.stderr);
        throw OSError(
          'Finished with stderr',
          process.exitCode,
        );
      }

      // Non-success error code.
      if (process.exitCode != 0) {
        throw OSError(
          'Finished with non-zero exit code',
          process.exitCode,
        );
      }
    }

    return process.stdout.toString();
  }

  /// Compile the first pattern block we discover in [input], and return the
  /// result.
  Future<String> _compileFirstMatch(String input) async {
    final incRegEx = RegExp(
      '$_beginPatternEsc((?:(?!$_beginPatternEsc).)*?)$_endPatternEsc',
      multiLine: true,
      dotAll: true,
    );

    final incRegExMatch = incRegEx.firstMatch(input);

    // No pattern block matches.
    if (incRegExMatch == null) return input;

    final innerBlock = incRegExMatch.group(1);

    // Only compile non-empty blocks
    var output = '';
    if (innerBlock != null && innerBlock.isNotEmpty) {
      output = await _evaluate(innerBlock);
    }

    return input.replaceFirst(incRegEx, output);
  }

  /// Return the compiled output text.
  Future<String> compile() async {
    var workingInput = input;
    while (true) {
      final newWorkingInput = await _compileFirstMatch(workingInput);
      if (newWorkingInput == workingInput) break;
      workingInput = newWorkingInput;
    }

    return workingInput;
  }
}
