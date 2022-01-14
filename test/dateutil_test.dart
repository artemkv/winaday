// @dart=2.9
// The directive above disables sound null safety.
// This is required because Google didn't update their sign-in package to null safery.
import 'package:test/test.dart';
import 'package:winaday/dateutil.dart';

void main() {
  test('isSameDate', () {
    expect(
        DateTime(2021, 12, 17, 11, 25, 30)
            .isSameDate(DateTime(2021, 12, 17, 15, 45, 00)),
        true);

    expect(
        DateTime(2021, 12, 17, 11, 25, 30)
            .isSameDate(DateTime(2021, 12, 18, 10, 05, 00)),
        false);
  });

  test('isSameMonth', () {
    expect(
        DateTime(2021, 12, 17, 11, 25, 30)
            .isSameMonth(DateTime(2021, 12, 17, 15, 45, 00)),
        true);

    expect(
        DateTime(2021, 12, 17, 11, 25, 30)
            .isSameMonth(DateTime(2021, 12, 18, 10, 05, 00)),
        true);

    expect(
        DateTime(2022, 01, 02, 16, 10, 00)
            .isSameMonth(DateTime(2021, 12, 18, 10, 05, 00)),
        false);
  });

  test('toCompact', () {
    expect(DateTime(2021, 12, 17, 11, 25, 30).toCompact(), "20211217");
  });

  test('fromCompact', () {
    expect(fromCompact("20211217"), DateTime(2021, 12, 17));
  });

  test('getPreviousMonth', () {
    expect(DateTime(2022, 1, 1), getPreviousMonth(DateTime(2022, 2, 15)));
    expect(DateTime(2021, 12, 1), getPreviousMonth(DateTime(2022, 1, 25)));
  });

  test('getFirstDayOfMonth', () {
    expect(DateTime(2022, 2, 1), getFirstDayOfMonth(DateTime(2022, 2, 15)));
    expect(DateTime(2022, 1, 1), getFirstDayOfMonth(DateTime(2022, 1, 25)));
  });

  test('getLastDayOfMonth', () {
    expect(DateTime(2022, 2, 28), getLastDayOfMonth(DateTime(2022, 2, 15)));
    expect(DateTime(2022, 1, 31), getLastDayOfMonth(DateTime(2022, 1, 25)));
  });
}
