import 'package:inc/inc.dart';
import 'package:test/test.dart';

void main() {
  group('Inc', () {
    test('Compile test string', () async {
      final inc = Inc('Hello world, |>echo -n tester<|, thanks!');

      final result = await inc.compile();
      expect(result, 'Hello world, tester, thanks!');
    });

    test('Compile nested test strings', () async {
      final inc = Inc('|>echo -n outer with |>echo -n inner<|<|');

      final result = await inc.compile();
      expect(result, 'outer with inner');
    });

    test('Compile with adjacent test strings', () async {
      final inc = Inc('|>echo -n first<| then |>echo -n next<|');

      final result = await inc.compile();
      expect(result, 'first then next');
    });

    test('Compile with multiline test string', () async {
      final inc = Inc(
        r'''
|>bash -c "
x=10
y=5
echo -n $((x+y))
"<|''',
      );

      final result = await inc.compile();
      expect(result, '15');
    });

    test('Compile with a regular string', () async {
      final inc = Inc('regular string here!');

      final result = await inc.compile();
      expect(result, 'regular string here!');
    });

    test('Compile with no beginning pattern', () async {
      final inc = Inc('here is a non<| compile');

      final result = await inc.compile();
      expect(result, 'here is a non<| compile');
    });

    test('Compile with no ending pattern', () async {
      final inc = Inc('here |>is a non compile');

      final result = await inc.compile();
      expect(result, 'here |>is a non compile');
    });

    test('Compile with dangling beginning pattern', () async {
      final inc = Inc('here |>|>echo -n only once<|');

      final result = await inc.compile();
      expect(result, 'here |>only once');
    });

    test('Compile with dangling ending pattern', () async {
      final inc = Inc('here |>echo -n only once<|<|');

      final result = await inc.compile();
      expect(result, 'here only once<|');
    });

    test('Compile with non-default patterns', () async {
      final inc = Inc(
        'hello [echo -n world]',
        beginPattern: '[',
        endPattern: ']',
      );

      final result = await inc.compile();
      expect(result, 'hello world');
    });

    test('Compile with non-default identical patterns', () async {
      final inc = Inc(
        'hello *echo -n world*',
        beginPattern: '*',
        endPattern: '*',
      );

      final result = await inc.compile();
      expect(result, 'hello world');
    });

    test('Compile with adjacent non-default identical patterns', () async {
      final inc = Inc(
        '*echo -n first* then *echo -n next*',
        beginPattern: '*',
        endPattern: '*',
      );

      final result = await inc.compile();
      expect(result, 'first then next');
    });
  });
}
