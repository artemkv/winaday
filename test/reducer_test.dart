import 'package:test/test.dart';
import 'package:winaday/domain.dart';
import 'package:winaday/model.dart';
import 'package:winaday/reducer.dart';

void main() {
  test('Link win to priority', () {
    PriorityListData priorityList = const PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win =
        const WinData("My win", OverallDayResult.gotMyWin, <String>{});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, const PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p001"});
  });

  test('Unlink win from priority', () {
    PriorityListData priorityList = const PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win = const WinData("My win", OverallDayResult.gotMyWin, {"p001"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, const PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, <String>{});
  });

  test('Link win with priorities to priority', () {
    PriorityListData priorityList = const PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win =
        const WinData("My win", OverallDayResult.gotMyWin, <String>{"p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, const PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p001", "p002"});
  });

  test('Unlink win with priorities from priority', () {
    PriorityListData priorityList = const PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win = const WinData(
        "My win", OverallDayResult.gotMyWin, <String>{"p001", "p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, const PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p002"});
  });

  test('Drop non-existing and deleted priorities from win when linking', () {
    PriorityListData priorityList = const PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("deleted", "priority 3", 1, true)
    ]);

    WinData win = const WinData("My win", OverallDayResult.gotMyWin,
        <String>{"non-existing", "deleted", "p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, const PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p001", "p002"});
  });

  test('Drop non-existing and deleted priorities from win when unlinking', () {
    PriorityListData priorityList = const PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("deleted", "priority 3", 1, true)
    ]);

    WinData win = const WinData("My win", OverallDayResult.gotMyWin,
        <String>{"non-existing", "deleted", "p001", "p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, const PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p002"});
  });

  test('Convert wins to win list items', () {
    var dateJan1 = DateTime(2022, 1, 1);
    var dateJan2 = DateTime(2022, 1, 2);
    var dateJan3 = DateTime(2022, 1, 3);

    var winJan1 = const WinData("Jan 1", OverallDayResult.gotMyWin, <String>{});

    List<WinOnDayData> wins = <WinOnDayData>[
      WinOnDayData(dateJan1, winJan1),
    ];

    List<WinListItem> expected = <WinListItem>[
      WinListItemLoadMoreTrigger(),
      WinListItemWin(dateJan1, winJan1),
      WinListItemNoWin(dateJan2),
      WinListItemNoWin(dateJan3)
    ];

    var winListItems = toWinListItems(dateJan1, dateJan3, wins);

    expect(expected, winListItems);
  });

  test('Convert no wins to win list items', () {
    var dateJan1 = DateTime(2022, 1, 1);
    var dateJan2 = DateTime(2022, 1, 2);
    var dateJan3 = DateTime(2022, 1, 3);

    List<WinOnDayData> wins = <WinOnDayData>[];

    List<WinListItem> expected = <WinListItem>[
      WinListItemLoadMoreTrigger(),
      WinListItemNoWin(dateJan1),
      WinListItemNoWin(dateJan2),
      WinListItemNoWin(dateJan3)
    ];

    var winListItems = toWinListItems(dateJan1, dateJan3, wins);

    expect(expected, winListItems);
  });

  test('Convert wins on month border to win list items', () {
    var dateNov29 = DateTime(2021, 11, 29);
    var dateNov30 = DateTime(2021, 11, 30);
    var dateDec1 = DateTime(2021, 12, 1);

    var winNov30 =
        const WinData("Nov 30", OverallDayResult.gotMyWin, <String>{});

    List<WinOnDayData> wins = <WinOnDayData>[
      WinOnDayData(dateNov30, winNov30),
    ];

    List<WinListItem> expected = <WinListItem>[
      WinListItemLoadMoreTrigger(),
      WinListItemNoWin(dateNov29),
      WinListItemWin(dateNov30, winNov30),
      const WinListItemMonthSeparator(12),
      WinListItemNoWin(dateDec1)
    ];

    var winListItems = toWinListItems(dateNov29, dateDec1, wins);

    expect(expected, winListItems);
  });

  test('Convert wins on month and year border to win list items', () {
    var dateDec31 = DateTime(2021, 12, 31);
    var dateJan1 = DateTime(2022, 1, 1);
    var dateJan2 = DateTime(2022, 1, 2);

    var winJan1 = const WinData("Jan 1", OverallDayResult.gotMyWin, <String>{});

    List<WinOnDayData> wins = <WinOnDayData>[
      WinOnDayData(dateJan1, winJan1),
    ];

    List<WinListItem> expected = <WinListItem>[
      WinListItemLoadMoreTrigger(),
      WinListItemNoWin(dateDec31),
      const WinListItemYearSeparator(2022),
      const WinListItemMonthSeparator(1),
      WinListItemWin(dateJan1, winJan1),
      WinListItemNoWin(dateJan2)
    ];

    var winListItems = toWinListItems(dateDec31, dateJan2, wins);

    expect(expected, winListItems);
  });
}
