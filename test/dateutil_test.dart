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

  test('prevDay', () {
    expect(DateTime(2022, 2, 15).prevDay(), DateTime(2022, 2, 14));
    expect(DateTime(2021, 10, 31).prevDay(), DateTime(2021, 10, 30));
    expect(DateTime(2021, 11, 1).prevDay(), DateTime(2021, 10, 31));
  });

  test('nextDay', () {
    expect(DateTime(2022, 2, 14).nextDay(), DateTime(2022, 2, 15));
    expect(DateTime(2021, 10, 30).nextDay(), DateTime(2021, 10, 31));
    expect(DateTime(2021, 10, 31).nextDay(), DateTime(2021, 11, 1));
  });

  test('prevWeek', () {
    expect(DateTime(2022, 1, 14).prevWeek(), DateTime(2022, 1, 7));
    expect(DateTime(2021, 10, 31).prevWeek(), DateTime(2021, 10, 24));
    expect(DateTime(2021, 11, 7).prevWeek(), DateTime(2021, 10, 31));
  });

  test('nextWeek', () {
    expect(DateTime(2022, 1, 7).nextWeek(), DateTime(2022, 1, 14));
    expect(DateTime(2021, 10, 24).nextWeek(), DateTime(2021, 10, 31));
    expect(DateTime(2021, 10, 31).nextWeek(), DateTime(2021, 11, 7));
  });

  test('getPreviousMonth', () {
    expect(getPreviousMonth(DateTime(2022, 2, 15)), DateTime(2022, 1, 1));
    expect(getPreviousMonth(DateTime(2022, 1, 25)), DateTime(2021, 12, 1));
  });

  test('getNextMonth', () {
    expect(getNextMonth(DateTime(2022, 1, 15)), DateTime(2022, 2, 1));
    expect(getNextMonth(DateTime(2021, 12, 10)), DateTime(2022, 1, 1));
  });

  test('getFirstDayOfMonth', () {
    expect(getFirstDayOfMonth(DateTime(2022, 2, 15)), DateTime(2022, 2, 1));
    expect(getFirstDayOfMonth(DateTime(2022, 1, 25)), DateTime(2022, 1, 1));
  });

  test('getLastDayOfMonth', () {
    expect(getLastDayOfMonth(DateTime(2022, 2, 15)), DateTime(2022, 2, 28));
    expect(getLastDayOfMonth(DateTime(2022, 1, 25)), DateTime(2022, 1, 31));
  });

  test('getDaysInInterval', () {
    expect(getDaysInInterval(DateTime(2022, 1, 5), DateTime(2022, 1, 5)), 1);
    expect(getDaysInInterval(DateTime(2022, 1, 5), DateTime(2022, 1, 7)), 3);
    expect(getDaysInInterval(DateTime(2021, 12, 30), DateTime(2022, 1, 5)), 7);
    expect(getDaysInInterval(DateTime(2022, 1, 5), DateTime(2022, 1, 4)), 0);
    expect(
        getDaysInInterval(DateTime(2021, 10, 30), DateTime(2021, 10, 31)), 2);
  });
}
