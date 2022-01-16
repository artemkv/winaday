import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:winaday/theme.dart';
import 'package:winaday/view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:uuid/uuid.dart';

import 'domain.dart';
import 'messages.dart';
import 'model.dart';

var uuid = const Uuid();

class DailyWinView extends StatefulWidget {
  final DailyWinModel model;
  final void Function(Message) dispatch;

  const DailyWinView({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<DailyWinView> createState() => _DailyWinViewState();
}

class _DailyWinViewState extends State<DailyWinView> {
  static const yesterday = 1;
  static const today = 2;
  static const tomorrow = 3;

  final PageController _controller = PageController(initialPage: today);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('One win a day'),
          elevation: 0.0,
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'List',
              onPressed: () {
                widget.dispatch(NavigateToWinListRequested(
                    widget.model.date, widget.model.today));
              },
            )
          ],
        ),
        drawer: drawer(
            context, widget.model.date, widget.model.today, widget.dispatch),
        body: Column(children: [
          Material(
              elevation: 4.0,
              child: calendarStripe(context, widget.model.date,
                  widget.model.today, widget.dispatch)),
          Expanded(
              child: Center(
                  child: PageView.builder(
                      onPageChanged: (page) {
                        if (page == yesterday) {
                          widget.dispatch(MoveToPrevDay(
                              widget.model.date, widget.model.today));
                        } else if (page == tomorrow) {
                          widget.dispatch(MoveToNextDay(
                              widget.model.date, widget.model.today));
                        }
                      },
                      scrollDirection: Axis.horizontal,
                      controller: _controller,
                      itemBuilder: (context, index) {
                        return dailyWinPage(
                            widget.model, index, today, widget.dispatch);
                      })))
        ]),
        floatingActionButton: (widget.model.editable
            ? FloatingActionButton(
                onPressed: () {
                  widget.dispatch(EditWinRequested(
                      widget.model.date,
                      widget.model.today,
                      widget.model.priorityList,
                      widget.model.win));
                },
                child: const Icon(Icons.edit),
                backgroundColor: crayolaBlue,
              )
            : null));
  }
}

class WinEditor extends StatefulWidget {
  final WinEditorModel model;
  final void Function(Message) dispatch;

  const WinEditor({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<WinEditor> createState() => _WinEditorState();
}

class _WinEditorState extends State<WinEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.win.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit win'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: () {
              // TODO: consider passing updated values to the message and then constructing new win in the reducer
              var updatedWin = WinData(_controller.text,
                  widget.model.win.overallResult, widget.model.win.priorities);
              widget.dispatch(WinChangesConfirmed(widget.model.date,
                  widget.model.today, widget.model.priorityList, updatedWin));
            },
          )
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            widget.dispatch(CancelEditingWinRequested(
                widget.model.date, widget.model.today));
            return false;
          },
          child: Column(children: [
            dayOverallResult(_controller, widget.model, widget.dispatch),
            const Divider(
              height: 12,
              thickness: 1,
              indent: 12,
              endIndent: 12,
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: TEXT_PADDING,
                        left: TEXT_PADDING * 2,
                        right: TEXT_PADDING * 2,
                        bottom: TEXT_PADDING),
                    child: TextField(
                      maxLength: 1000,
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(fontSize: TEXT_FONT_SIZE),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write down you win here'),
                    )))
          ])),
    );
  }
}

class PriorityEditor extends StatefulWidget {
  final PriorityEditorModel model;
  final void Function(Message) dispatch;

  const PriorityEditor({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<PriorityEditor> createState() => _PriorityEditorState();
}

class _PriorityEditorState extends State<PriorityEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.priority.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit priority'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: () {
              PriorityData priority = PriorityData(
                  widget.model.priority.id,
                  _controller.text,
                  widget.model.priority.color,
                  widget.model.priority.deleted);
              widget.dispatch(PrioritySaveRequested(
                  widget.model.date, widget.model.priorityList, priority));
            },
          )
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            widget.dispatch(CancelEditingPriorityRequested(
                widget.model.date, widget.model.today));
            return false;
          },
          child: Column(children: [
            priorityBoxColorPicker(_controller, widget.model, widget.dispatch),
            const Divider(
              // TODO: single-source
              height: 12,
              thickness: 1,
              indent: 12,
              endIndent: 12,
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: TEXT_PADDING,
                        left: TEXT_PADDING * 2,
                        right: TEXT_PADDING * 2,
                        bottom: TEXT_PADDING),
                    child: TextField(
                      maxLength: 100,
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(fontSize: TEXT_FONT_SIZE),
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write down you priority here'),
                    )))
          ])),
    );
  }
}

class DraggablePriorityGrid extends StatefulWidget {
  final EditPrioritiesModel model;
  final void Function(Message) dispatch;

  const DraggablePriorityGrid(
      {Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<DraggablePriorityGrid> createState() => _DraggablePriorityGridState();
}

class _DraggablePriorityGridState extends State<DraggablePriorityGrid> {
  PriorityData? _exchangeWith;

  void onWillAccept(PriorityData? priority) {
    setState(() {
      _exchangeWith = priority;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        children: widget.model.priorityList.items
            .where((element) => !element.deleted)
            .map((e) => draggablePriorityBox(
                widget.model, e, _exchangeWith, widget.dispatch, onWillAccept))
            .toList());
  }
}

class WinList extends StatefulWidget {
  final WinListModel model;
  final void Function(Message) dispatch;

  const WinList({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<WinList> createState() => _WinListState();
}

class _WinListState extends State<WinList> {
  final ItemScrollController _controller = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('One win a day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Calendar',
            onPressed: () {
              widget.dispatch(NavigateToCalendarRequested(
                  widget.model.date, widget.model.today));
            },
          )
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            widget.dispatch(BackToDailyWinViewRequested(
                widget.model.date, widget.model.today));
            return false;
          },
          child: ScrollablePositionedList.separated(
            reverse: true,
            itemScrollController: _controller,
            itemCount: widget.model.items.length,
            separatorBuilder: (BuildContext context, int index) {
              int reverseIndex = widget.model.items.length - index - 1;
              if (reverseIndex > 0) {
                var prevItem = widget.model.items[reverseIndex - 1];
                if (prevItem is WinListItemYearSeparator) {
                  return Container();
                }
              }
              return const Divider(
                height: 12,
                thickness: 1,
                indent: 72,
                endIndent: 24,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              int reverseIndex = widget.model.items.length - index - 1;
              var item = widget.model.items[reverseIndex];
              if (item is WinListItemLoadMoreTrigger) {
                return ListTile(
                    title: WinListItemLoadMore(dispatch: widget.dispatch));
              }
              if (item is WinListItemLoadingMore) {
                return ListTile(title: winListItemLoadingMore());
              }
              if (item is WinListItemRetryLoadMore) {
                return ListTile(
                    title: winListItemRetryLoadMore(
                        widget.model, item.reason, widget.dispatch));
              }
              if (item is WinListItemMonthSeparator) {
                return ListTile(title: winListItemMonthSeparator(item.month));
              }
              if (item is WinListItemYearSeparator) {
                return ListTile(title: winListItemYearSeparator(item.year));
              }
              if (item is WinListItemWin) {
                return ListTile(
                  title: winListItem(widget.model.priorityList, item.date,
                      widget.model.today, item.win, widget.dispatch),
                );
              }
              if (item is WinListItemNoWin) {
                return ListTile(
                  title: noWinListItem(
                      item.date, widget.model.today, widget.dispatch),
                );
              }
              throw "Unknown type of WinListItem";
            },
          )),
    );
  }
}

class CalendarView extends StatefulWidget {
  final CalendarViewModel model;
  final void Function(Message) dispatch;

  const CalendarView({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final ItemScrollController _controller = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('One win a day'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'List',
              onPressed: () {
                widget.dispatch(NavigateToWinListRequested(
                    widget.model.date, widget.model.today));
              },
            )
          ],
        ),
        body: WillPopScope(
            onWillPop: () async {
              widget.dispatch(BackToDailyWinViewRequested(
                  widget.model.date, widget.model.today));
              return false;
            },
            child: ScrollablePositionedList.builder(
              reverse: true,
              itemScrollController: _controller,
              itemCount: widget.model.items.length,
              itemBuilder: (BuildContext context, int index) {
                int reverseIndex = widget.model.items.length - index - 1;
                var item = widget.model.items[reverseIndex];
                if (item is CalendarViewListItemNextPageTrigger) {
                  return ListTile(
                    title: CalendarListItemNextPageTrigger(
                        dispatch: widget.dispatch),
                  );
                }
                if (item is CalendarViewListItemYearSeparator) {
                  return ListTile(
                      title: calendarListItemYearSeparator(item.year));
                }
                if (item is CalendarViewListItemMonth) {
                  return ListTile(
                    title: calendarMonth(context, widget.model.today,
                        item.month, item.winDays, widget.dispatch),
                  );
                }
                throw "Unknown type of WinListItem";
              },
            )));
  }
}

class CalendarListItemNextPageTrigger extends StatefulWidget {
  final void Function(Message) dispatch;

  const CalendarListItemNextPageTrigger({Key? key, required this.dispatch})
      : super(key: key);

  @override
  State<CalendarListItemNextPageTrigger> createState() =>
      _CalendarListItemNextPageTriggerState();
}

class _CalendarListItemNextPageTriggerState
    extends State<CalendarListItemNextPageTrigger> {
  final String widgetKey = uuid.v4();

  bool fired = false;

  void setFired() {
    setState(() {
      fired = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(widgetKey),
        onVisibilityChanged: (visibilityInfo) {
          if (!fired) {
            if (visibilityInfo.visibleFraction > 0.0) {
              widget.dispatch(CalendarViewNextPageRequested());
              setFired();
            }
          }
        },
        child: Row(children: [
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: const EdgeInsets.all(12.0), child: spinner()))),
        ]));
  }
}

class WinListItemLoadMore extends StatefulWidget {
  final void Function(Message) dispatch;

  const WinListItemLoadMore({Key? key, required this.dispatch})
      : super(key: key);

  @override
  State<WinListItemLoadMore> createState() => _WinListItemLoadMoreState();
}

class _WinListItemLoadMoreState extends State<WinListItemLoadMore> {
  final String widgetKey = uuid.v4();

  bool fired = false;

  void setFired() {
    setState(() {
      fired = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(widgetKey),
        onVisibilityChanged: (visibilityInfo) {
          if (!fired) {
            if (visibilityInfo.visibleFraction > 0.0) {
              widget.dispatch(LoadWinListNextPageRequested());
              setFired();
            }
          }
        },
        child: Row(children: [
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: const EdgeInsets.all(12.0), child: spinner()))),
        ]));
  }
}

class MonthlyStatsView extends StatefulWidget {
  final MonthlyStatsModel model;
  final void Function(Message) dispatch;

  const MonthlyStatsView(
      {Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<MonthlyStatsView> createState() => _MonthlyStatsViewState();
}

class _MonthlyStatsViewState extends State<MonthlyStatsView> {
  static const prev = 1;
  static const cur = 2;
  static const next = 3;

  final PageController _controller = PageController(initialPage: cur);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Your Statistics'),
          elevation: 0.0,
        ),
        body: WillPopScope(
            onWillPop: () async {
              widget.dispatch(
                  ExitStatsRequested(widget.model.date, widget.model.today));
              return false;
            },
            child: Column(children: [
              monthlyStatsHeader(widget.model.date, widget.model.today,
                  widget.model.from, widget.dispatch),
              Expanded(
                  child: Center(
                      child: PageView.builder(
                          onPageChanged: (page) {
                            if (page == prev) {
                              widget.dispatch(MoveToPrevMonthStats(
                                  widget.model.date, widget.model.today));
                            } else if (page == next) {
                              widget.dispatch(MoveToNextMonthStats(
                                  widget.model.date, widget.model.today));
                            }
                          },
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          itemBuilder: (context, index) {
                            if (index == cur) {
                              return monthlyStats(
                                  widget.model, widget.dispatch);
                            } else {
                              return Container();
                            }
                          })))
            ])));
  }
}
