import 'dart:io';

import 'package:args/args.dart';
import 'package:inc/inc.dart';

Future<void> main(List<String> args) async {
  final argParser = ArgParser();
  argParser
    ..addFlag(
      'help',
      help: 'Show the usage for this program.',
      abbr: 'h',
      negatable: false,
      callback: (value) {
        if (value) {
          stdout.writeln(argParser.usage);
          exit(0);
        }
      },
    )
    ..addOption(
      'input',
      help: 'Input file path to compile from. If none is provide, '
          'the standard input is used.',
      abbr: 'i',
    )
    ..addOption(
      'output',
      help: 'Output file path to write to. If none is provide, '
          'the standard output is used.',
      abbr: 'o',
    )
    ..addOption(
      'begin',
      help: 'Beginning pattern to match with.',
      defaultsTo: '|>',
      abbr: '1',
    )
    ..addOption(
      'end',
      help: 'Ending pattern to match with.',
      defaultsTo: '<|',
      abbr: '2',
    )
    ..addFlag(
      'ignore-errors',
      help: 'Continue execution even if stderr contains errors or '
          'the exit code is non-zero.',
      abbr: 'I',
    );

  try {
    final results = argParser.parse(args);
    final inputFilePath = results['input'] as String?;
    final outputFilePath = results['output'] as String?;
    final beginPattern = results['begin'] as String;
    final endPattern = results['end'] as String;
    final ignoreErrors = results['ignore-errors'] as bool;

    // Read input file if one was given, else use stdin.
    final String inputText;
    if (inputFilePath != null && inputFilePath.isNotEmpty) {
      final inputFile = File(inputFilePath);
      if (!inputFile.existsSync()) {
        throw ArgumentError('File not found', inputFilePath);
      }

      inputText = await inputFile.readAsString();
    } else {
      inputText = stdin.readLineSync() ?? '';
    }

    // Compile with [Inc].
    final inc = Inc(
      inputText,
      beginPattern: beginPattern,
      endPattern: endPattern,
      ignoreErrors: ignoreErrors,
    );
    final outputText = await inc.compile();

    // Write output file if one was given, else use stdout.
    if (outputFilePath != null && outputFilePath.isNotEmpty) {
      final outputFile = File(outputFilePath);
      await outputFile.writeAsString(outputText);
    } else {
      stdout.writeln(outputText);
    }
  } catch (e) {
    stdout.writeln(e);
    exit(1);
  }
}
