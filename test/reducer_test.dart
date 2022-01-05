// @dart=2.9
// The directive above disables sound null safety.
// This is required because Google didn't update their sign-in package to null safery.
import 'package:test/test.dart';
import 'package:winaday/domain.dart';
import 'package:winaday/reducer.dart';

void main() {
  test('Link win to priority', () {
    PriorityListData priorityList = PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win = WinData("My win", OverallDayResult.gotMyWin, <String>{});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p001"});
  });

  test('Unlink win from priority', () {
    PriorityListData priorityList = PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win = WinData("My win", OverallDayResult.gotMyWin, {"p001"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, <String>{});
  });

  test('Link win with priorities to priority', () {
    PriorityListData priorityList = PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win =
        WinData("My win", OverallDayResult.gotMyWin, <String>{"p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p001", "p002"});
  });

  test('Unlink win with priorities from priority', () {
    PriorityListData priorityList = PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("p003", "priority 3", 1, false)
    ]);

    WinData win =
        WinData("My win", OverallDayResult.gotMyWin, <String>{"p001", "p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p002"});
  });

  test('Drop non-existing and deleted priorities from win when linking', () {
    PriorityListData priorityList = PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("deleted", "priority 3", 1, true)
    ]);

    WinData win = WinData("My win", OverallDayResult.gotMyWin,
        <String>{"non-existing", "deleted", "p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p001", "p002"});
  });

  test('Drop non-existing and deleted priorities from win when unlinking', () {
    PriorityListData priorityList = PriorityListData([
      PriorityData("p001", "priority 1", 1, false),
      PriorityData("p002", "priority 2", 1, false),
      PriorityData("deleted", "priority 3", 1, true)
    ]);

    WinData win = WinData("My win", OverallDayResult.gotMyWin,
        <String>{"non-existing", "deleted", "p001", "p002"});

    Set<String> updatedPriorities = getUpdatedWinPriorities(
        win, PriorityData("p001", "priority 1", 1, false), priorityList);

    expect(updatedPriorities, {"p002"});
  });
}
