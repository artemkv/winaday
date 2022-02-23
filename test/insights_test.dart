// @dart=2.9
// The directive above disables sound null safety.
// This is required because Google didn't update their sign-in package to null safery.
import 'package:test/test.dart';
import 'package:winaday/domain.dart';
import 'package:winaday/insights.dart';

void main() {
  test('empty win list result in empty priority combination', () {
    var winList = WinListShortData.empty();
    var priorityList = PriorityListData.empty();

    expect(getMostPopularPriorityCombination(winList, priorityList), []);
  });

  test('get combinations', () {
    expect(getCombinations({'aa', 'bb', 'cc'}), [
      const Combination('aa', 'bb'),
      const Combination('aa', 'cc'),
      const Combination('bb', 'cc')
    ]);

    expect(getCombinations({'aa', 'bb', 'cc'}), [
      const Combination('bb', 'aa'),
      const Combination('cc', 'aa'),
      const Combination('cc', 'bb')
    ]);
  });

  test('detects most popular priority combination', () {
    var winList = WinListShortData([
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p1', 'p2'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p2', 'p3'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p1', 'p2'}))
    ]);

    var priority1 = const PriorityData('p1', 'priority 1', 0, false);
    var priority2 = const PriorityData('p2', 'priority 2', 0, false);
    var priority3 = const PriorityData('p3', 'priority 3', 0, false);

    var priorityList = PriorityListData([priority1, priority2, priority3]);

    expect(getMostPopularPriorityCombination(winList, priorityList),
        [priority1, priority2]);
  });

  test('detects most popular priority combination regardless of the order', () {
    var winList = WinListShortData([
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p1', 'p2'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p2', 'p3'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p3', 'p2'}))
    ]);

    var priority1 = const PriorityData('p1', 'priority 1', 0, false);
    var priority2 = const PriorityData('p2', 'priority 2', 0, false);
    var priority3 = const PriorityData('p3', 'priority 3', 0, false);

    var priorityList = PriorityListData([priority1, priority2, priority3]);

    expect(getMostPopularPriorityCombination(winList, priorityList),
        [priority2, priority3]);
  });

  test(
      'detects most popular priority combination with more than 2 priorities assigned',
      () {
    var winList = WinListShortData([
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p1', 'p2', 'p3'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p2', 'p3'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p1', 'p2'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.gotMyWin, {'p2', 'p3'})),
    ]);

    var priority1 = const PriorityData('p1', 'priority 1', 0, false);
    var priority2 = const PriorityData('p2', 'priority 2', 0, false);
    var priority3 = const PriorityData('p3', 'priority 3', 0, false);

    var priorityList = PriorityListData([priority1, priority2, priority3]);

    expect(getMostPopularPriorityCombination(winList, priorityList),
        [priority2, priority3]);
  });

  test('detects most awesome days', () {
    var winList = WinListShortData([
      WinOnDayShortData(DateTime(2022, 02, 14),
          const WinShortData(OverallDayResult.gotMyWin, {})),
      WinOnDayShortData(DateTime(2022, 02, 15),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
      WinOnDayShortData(DateTime(2022, 02, 21),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
      WinOnDayShortData(DateTime(2022, 02, 22),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
      WinOnDayShortData(DateTime(2022, 02, 23),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
    ]);

    expect(getAwesomeWeekDays(winList), [
      LabeledValue('Tuesday', 50),
      LabeledValue('Monday', 25),
      LabeledValue('Wednesday', 25)
    ]);
  });

  test('awesome days sorted by day of week when tie', () {
    var winList = WinListShortData([
      WinOnDayShortData(DateTime(2022, 02, 21),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
      WinOnDayShortData(DateTime(2022, 02, 24),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
      WinOnDayShortData(DateTime(2022, 02, 23),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
      WinOnDayShortData(DateTime(2022, 02, 22),
          const WinShortData(OverallDayResult.awesomeAchievement, {})),
    ]);

    expect(getAwesomeWeekDays(winList), [
      LabeledValue('Monday', 25),
      LabeledValue('Tuesday', 25),
      LabeledValue('Wednesday', 25),
      LabeledValue('Thursday', 25)
    ]);
  });

  test('detects awesome priorities', () {
    var winList = WinListShortData([
      WinOnDayShortData(
          DateTime(2022),
          const WinShortData(
              OverallDayResult.awesomeAchievement, {'p1', 'p2', 'p3'})),
      WinOnDayShortData(
          DateTime(2022),
          const WinShortData(
              OverallDayResult.awesomeAchievement, {'p2', 'p3'})),
      WinOnDayShortData(
          DateTime(2022),
          const WinShortData(
              OverallDayResult.awesomeAchievement, {'p1', 'p2'})),
      WinOnDayShortData(DateTime(2022),
          const WinShortData(OverallDayResult.awesomeAchievement, {'p1'}))
    ]);

    var priority1 = const PriorityData('p1', 'priority 1', 0, false);
    var priority2 = const PriorityData('p2', 'priority 2', 0, false);
    var priority3 = const PriorityData('p3', 'priority 3', 0, false);

    var priorityList = PriorityListData([priority1, priority2, priority3]);

    expect(getAwesomePriorities(winList, priorityList), [
      LabeledValue('priority 1', 37.5),
      LabeledValue('priority 2', 37.5),
      LabeledValue('priority 3', 25)
    ]);
  });
}
